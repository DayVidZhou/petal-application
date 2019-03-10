//
//  ViewController.swift
//  Petal
//
//  Created by David Zhou on 2019-01-14.
//  Copyright © 2019 David Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var barChart: BarChart!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var powerlabel: UILabel!
    @IBOutlet weak var nowBtn: UIButton!
    @IBOutlet weak var buttonView: UIView!
    
    // initializing variables used for date objects
    var baseURL = "https://flask-petal.herokuapp.com/"
    let dateFormatter = DateFormatter()
    let today = Date()
    let calendar = Calendar(identifier: .gregorian)
    var totalpower: Double = 0.0
    let startdate: String = "03-01-2019-00"
    var powerCount = [Int]()
    var powerList = [Double]()
    let repeattask = RepeatingTimer(timeInterval: 3)
    var livebars: [BarEntry] = []
    var barLayer = CALayer()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        print("testing print")
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks.
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.allowsSelection = false
        homeTableView.isScrollEnabled = false
        weekBtn.titleLabel?.textColor = UIColor.white
        weekBtn.addTarget(self, action: #selector(powerBtnsPressed), for: .touchUpInside)
        monthBtn.addTarget(self, action: #selector(powerBtnsPressed), for: .touchUpInside)
        nowBtn.addTarget(self, action: #selector(powerBtnsPressed), for: .touchUpInside)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
//        barChart.scrollView.addSubview(refreshControl)
        // Do any additional setup after loading the view, typically from a nib.
        initialize()
        repeattask.eventHandler = {
            self.getLastMeasurement()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dateFormatter.dateFormat = "MM-dd-yyyy-HH"
        barLayer.frame = CGRect(x: weekBtn.frame.minX, y: weekBtn.frame.maxY, width: weekBtn.frame.width, height: 4)
        barLayer.backgroundColor = UIColor.white.cgColor
        barLayer.cornerRadius = 2
        buttonView.layer.addSublayer(barLayer)
        checkSavedTime(type: "THIS WEEK")
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        print("refresh this shit")
    }
    
    func initialize() {
        // setting the button for when button is selected and when it is normal
        monthBtn.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        weekBtn.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        monthBtn.setTitleColor(UIColor.white, for: .selected)
        weekBtn.setTitleColor(UIColor.white, for: .selected)
        weekBtn.tintColor = UIColor(white: 0, alpha: 0)
        monthBtn.tintColor = UIColor(white: 0, alpha: 0)
        nowBtn.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        nowBtn.setTitleColor(UIColor.white, for: .selected)
        nowBtn.tintColor = UIColor(white: 0, alpha: 0)
        
        //initialize bars of 0s
        for _ in 0..<30 {
            let barColor = UIColor(white: 1, alpha: 0.5)
            livebars.append(BarEntry(color: barColor, height: 0.025, textValue: "", title: ""))
        }
        
    }
    
    func getLastMeasurement() {
        let link: String = baseURL + "lastmeasurement"
        let linkURL = URL(string: link)!
        let task = URLSession.shared.dataTask(with: linkURL) { (data, response, error) in
            if error == nil {
                do {
                    let jsonresponse = try JSONSerialization.jsonObject(with: data!, options: [])
                    let json = jsonresponse as! [String: Any]
                    let data = (json["power"] as! Double)/1000.0
                    let rounded = Double(round(100*data)/100)
                    self.updatePwrLabel(text: String(rounded) + " kW")
                    self.updateLiveBars(newValue: rounded)
                } catch let e{
                    print("ERROR IS ,", e)
                }
            }
        }
        task.resume()
    }
    
    func updateLiveBars(newValue: Double) {
        livebars.removeFirst()
        let barColor = UIColor(white: 1, alpha: 0.5)
        var height = newValue/1.0
        height += 0.025
        livebars.append(BarEntry(color: barColor, height: Float(height), textValue: "", title: ""))
        DispatchQueue.main.async {
            self.barChart.dataEntries = self.livebars
        }
    }
    
    func updatePwrLabel(text: String) {
        DispatchQueue.main.async {
            self.powerlabel.text = text
        }
    }
    
    // action button for week and month button
    @objc func powerBtnsPressed(sender:UIButton) {
        let button = sender
        print(button.titleLabel?.text as Any)
        if !button.isSelected {
            button.isSelected = true
        }
        
        switch button.titleLabel?.text {
        case "THIS WEEK":
            barLayer.frame = CGRect(x: weekBtn.frame.minX, y: weekBtn.frame.maxY, width: weekBtn.frame.width, height: 4)
            monthBtn.isSelected = false
            nowBtn.isSelected = false
            repeattask.suspend()
            checkSavedTime(type: (button.titleLabel?.text)!)
        case "MONTH":
            barLayer.frame = CGRect(x: monthBtn.frame.minX, y: monthBtn.frame.maxY, width: monthBtn.frame.width, height: 4)
            weekBtn.isSelected = false
            nowBtn.isSelected = false
            repeattask.suspend()
            checkSavedTime(type: (button.titleLabel?.text)!)
        case "NOW":
            barLayer.frame = CGRect(x: nowBtn.frame.minX, y: nowBtn.frame.maxY, width: nowBtn.frame.width, height: 4)
            weekBtn.isSelected = false
            monthBtn.isSelected = false
            repeattask.resume()
            getLastMeasurement()
        default:
            monthBtn.isSelected = false
            nowBtn.isSelected = false
            checkSavedTime(type: (button.titleLabel?.text)!)
        }
    }
    
    func checkSavedTime(type: String) {
        if Storage.fileExists("power.json", in: .caches) {
            print("power json found")
            let powerSaved = Storage.retrieve("power.json", from: .caches, as: PowerStruct.self)
            let hourLater = calendar.date(byAdding: .hour, value: 1, to: powerSaved.time)
            if hourLater! < Date() {
                print("ITS been over an hour")
                populateData(type: type)
            } else {
                updatePwrLabel(text: String(powerSaved.roundedPwr) + " kWh")
                if type == "THIS WEEK" {
                    powerCount = powerSaved.weekCount
                    let maxpower = powerSaved.weekList.max()
                    populateBarChart(data: powerSaved.weekList, maxpower: maxpower!)
                } else {
                    powerCount = powerSaved.monthCount
                    let maxpower = powerSaved.monthList.max()
                    populateBarChart(data: powerSaved.monthList, maxpower: maxpower!)
                }
            }
        } else {
            print("power json not found")
            populateData(type: type)
        }
    }
    
    // This function handles the http request and passes the jsonarray to processdata
    func populateData(type: String) {
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour], from: today)
        let tomorrow = components.day! + 1
        
        let link: String = baseURL + "measurements?start=" + startdate + "&end=03-" + String(tomorrow) + "-2019-00"
        let linkURL = URL(string: link)!
        let task = URLSession.shared.dataTask(with: linkURL) { (data, response, error) in
            if error == nil {
                do {
                    let jsonresponse = try JSONSerialization.jsonObject(with: data!, options: [])
                    let jsonArray = jsonresponse as! [[String: Any]]
                    self.processData(data: jsonArray, type: type)
                } catch let e{
                    print("ERROR IS ,", e)
                }
            }
        }
        task.resume()
    }
    
    // This function uses the data gotten from the HTTP request and sends the correct power array to generate Data entry
    func processData(data: [[String: Any]], type: String) {
        let dayofweek = getDayOfWeek(today)
        let range = calendar.range(of: .day, in: .month, for: today)!
        let numDays = range.count
        powerList = [Double](repeating: 0.0, count: numDays)
        var sum = 0
        powerCount = [Int](repeating: 0, count: numDays)
//        var powerHour = [AnyObject]()
//        var component = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour], from: date!)
        totalpower = 0
        // loop to populate power list and powercount
        for x in data {
            let power = ((x["power"] as? Double)!)/1000.0
            totalpower += power
            let dateStr = x["time"] as? String
            let date = dateFormatter.date(from: dateStr!)
            let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: date!)
            powerList[components.day! - 1] += power
            powerCount[components.day! - 1] += 1
            sum += 1
            
        }
        
        var weekList = [Double]()
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: today)
        let startindex = components.day! - dayofweek!
        let endindex = components.day! + 7 - dayofweek! - 1
        print("The startindex is ", startindex, " the day is ", components.day!, " day of week is ", dayofweek!, " the end index is ", endindex)
        weekList = Array<Double>(powerList[startindex...endindex])
        let weekCount = Array<Int>(powerCount[startindex...endindex])
        
        if sum == 0 {
            sum = 1
        }
        let pwr = (totalpower)/Double(sum)
        let roundedPwr = round(100*(pwr)/100)
        let tempPower = PowerStruct(time: Date(), monthList: powerList, monthCount: powerCount, weekList: weekList, weekCount: weekCount, roundedPwr: roundedPwr)
        Storage.store(tempPower, to: .caches, as: "power.json")
        updatePwrLabel(text: String(roundedPwr) + " kWh")
        if type == "THIS WEEK" {
            powerCount = weekCount
            let maxpower = weekList.max()
            print("The total power is ", totalpower/Double(sum), " the max power is", maxpower!)
            populateBarChart(data: weekList, maxpower: maxpower!)
        } else {
            let maxpower = powerList.max()
            print("The total power is ", totalpower/Double(sum), " the max power is", maxpower!)
            populateBarChart(data: powerList, maxpower: maxpower!)
        }
    }
    
    func populateBarChart(data: [Double], maxpower: Double) {
        let dataEntries = generateDataEntries(data: data, maxpower: maxpower)
        DispatchQueue.main.async {
            self.barChart.dataEntries = dataEntries
        }
    }
    
    func generateDataEntries(data: [Double], maxpower: Double) -> [BarEntry] {
        print("THe data gotten for chart is ", data)
        var barColor = UIColor(white: 1, alpha: 0.5)
        var result: [BarEntry] = []
        let weeklabel = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        let dayofweek = getDayOfWeek(today)
        
        for i in 0..<data.count {
            var value: Double = 0
            if powerCount[i] == 0 {
                powerCount[i] = 1
            }
            value = ((data[i]/Double(powerCount[i]))/maxpower)*80
            var height: Float = Float(value) / 100.0
            height += 0.025
            var textValue = ""
            var title = ""
            if data.count == 7 {
                textValue = "\(data[i]/Double(powerCount[i]))"
                title = weeklabel[i]
            }
            if i == dayofweek! - 1 {
                barColor = UIColor.white
            }
            result.append(BarEntry(color: barColor, height: height, textValue: textValue, title: title))
            barColor = UIColor(white: 1, alpha: 0.5)
        }
        return result
    }
    
    // gets the day of week
    func getDayOfWeek(_ today: Date) -> Int? {
        let weekDay = calendar.component(.weekday, from: today)
        return weekDay
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    //============================
    // All the table view stuff
    //============================
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell =  Bundle.main.loadNibNamed("BillTableViewCell", owner: self, options: nil)?.first as! BillTableViewCell
            cell.billText.text = "$4234"
            cell.pointsText.text = "123"
            cell.layer.borderWidth = CGFloat(10)
            cell.layer.borderColor = tableView.backgroundColor?.cgColor
            return cell
        } else {
            let cell =
            Bundle.main.loadNibNamed("TipTableViewCell", owner: self, options: nil)?.first as! TipTableViewCell
            cell.layer.borderWidth = CGFloat(10)
            cell.layer.borderColor = tableView.backgroundColor?.cgColor
            return cell
            
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

