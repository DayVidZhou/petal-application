//
//  ViewController.swift
//  Petal
//
//  Created by David Zhou on 2019-01-14.
//  Copyright © 2019 David Zhou. All rights reserved.
//
import SafariServices
import UIKit

class homeController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var barChart: BarChart!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var powerlabel: UILabel!
    @IBOutlet weak var nowBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var kwhLabel: UILabel!
    @IBOutlet weak var energyUsedLabel: UILabel!
    
    // initializing variables used for date objects
    var baseURL = "https://flask-petal.herokuapp.com/"
    let dateFormatter = DateFormatter()
    let today = Date()
    let calendar = Calendar(identifier: .gregorian)
    var totalpower: Double = 0.0
    let startdate: String = "03-01-2019-00"
    var powerCount = [Int]()
    var powerList = [Double]()
    let repeattask = RepeatingTimer(timeInterval: 2)
    var livebars: [BarEntry] = []
    var barLayer = CALayer()
    var refreshControl = UIRefreshControl()
//    override func loadView() {
//        view = webView
//    }
    
    override func viewDidLoad() {
        Storage.remove("power.json", from: .caches)
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks.
        homeTableView.delegate = self
        homeTableView.dataSource = self
        weekBtn.titleLabel?.textColor = UIColor.white
        weekBtn.addTarget(self, action: #selector(powerBtnsPressed), for: .touchUpInside)
        monthBtn.addTarget(self, action: #selector(powerBtnsPressed), for: .touchUpInside)
        nowBtn.addTarget(self, action: #selector(powerBtnsPressed), for: .touchUpInside)
//        barChart.scrollView.addSubview(refreshControl)
        // Do any additional setup after loading the view, typically from a nib.
        initialize()
        repeattask.eventHandler = {
            self.getLastMeasurement()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        repeattask.suspend()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        barChart.screenWidth = barChart.bounds.width
        dateFormatter.dateFormat = "MM-dd-yyyy-HH"
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
        var temp = [BarEntry]()
        for _ in 0..<30 {
            let barColor = UIColor(white: 1, alpha: 0.5)
            temp.append(BarEntry(color: barColor, height: 0.025, textValue: "", title: ""))
        }
        livebars = temp
        
        // adding the bar beneath the selected button
        barLayer.backgroundColor = UIColor.white.cgColor
        barLayer.cornerRadius = 2
        if weekBtn.isSelected {
            updatekwhLabel(text: "kWh")
            barLayer.frame = CGRect(x: weekBtn.frame.minX+49.5, y: weekBtn.frame.maxY+43, width: weekBtn.frame.width, height: 4)
            checkSavedTime(type: "THIS WEEK")
            repeattask.suspend()
            energyUsedLabel.text = "Energy used"
        } else if monthBtn.isSelected {
            updatekwhLabel(text: "kWh")
            barLayer.frame = CGRect(x: monthBtn.frame.minX+49.5, y: monthBtn.frame.maxY+43, width: monthBtn.frame.width, height: 4)
            checkSavedTime(type: "THIS MONTH")
            repeattask.suspend()
            energyUsedLabel.text = "Energy used"
        } else {
            updatekwhLabel(text: "W")
            barLayer.frame = CGRect(x: nowBtn.frame.minX+49.5, y: nowBtn.frame.maxY+43, width: nowBtn.frame.width, height: 4)
            repeattask.resume()
            getLastMeasurement()
            energyUsedLabel.text = "Currently using"
        }
        mainView.layer.addSublayer(barLayer)
    }
    
    func getLastMeasurement() {
        let link: String = baseURL + "lastmeasurement"
        let linkURL = URL(string: link)!
        let task = URLSession.shared.dataTask(with: linkURL) { (data, response, error) in
            if error == nil {
                do {
                    let jsonresponse = try JSONSerialization.jsonObject(with: data!, options: [])
                    let json = jsonresponse as! [String: Any]
                    let data = (json["power"] as! Double)
//                    print("The data is ", data)
                    self.updatePwrLabel(text: String(format: "%.2f", data))
                    self.updateLiveBars(newValue: data)
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
        var height = newValue/1000
        height += 0.025
        livebars.append(BarEntry(color: barColor, height: Float(height), textValue: "", title: ""))
        DispatchQueue.main.async {
            self.barChart.dataEntries = self.livebars
        }
    }
    
    func updateBill(price: Double) {
        let indexPath = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            let cell = self.homeTableView.cellForRow(at: indexPath) as! BillTableViewCell
            cell.billText.text = "$" + String(format: "%.2f", price)
        }
    }
    
    func updatePwrLabel(text: String) {
        DispatchQueue.main.async {
            self.powerlabel.text = text
        }
    }
    
    func updatekwhLabel(text: String) {
        DispatchQueue.main.async {
            self.kwhLabel.text = text
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
            barLayer.frame = CGRect(x: weekBtn.frame.minX+49.5, y: weekBtn.frame.maxY+43, width: weekBtn.frame.width, height: 4)
            updatekwhLabel(text: "kWh")
            energyUsedLabel.text = "Energy used"
            monthBtn.isSelected = false
            nowBtn.isSelected = false
            repeattask.suspend()
            checkSavedTime(type: (button.titleLabel?.text)!)
        case "THIS MONTH":
            barLayer.frame = CGRect(x: monthBtn.frame.minX+49.5, y: monthBtn.frame.maxY+43, width: monthBtn.frame.width, height: 4)
            updatekwhLabel(text: "kWh")
            energyUsedLabel.text = "Energy used"
            weekBtn.isSelected = false
            nowBtn.isSelected = false
            repeattask.suspend()
            checkSavedTime(type: (button.titleLabel?.text)!)
        case "NOW":
            barLayer.frame = CGRect(x: nowBtn.frame.minX+49.5, y: nowBtn.frame.maxY+43, width: nowBtn.frame.width, height: 4)
            updatekwhLabel(text: "W")
            energyUsedLabel.text = "Currently using"
            weekBtn.isSelected = false
            monthBtn.isSelected = false
            repeattask.resume()
            getLastMeasurement()
        default:
            updatekwhLabel(text: "kWh")
            energyUsedLabel.text = "Energy Used"
            monthBtn.isSelected = false
            nowBtn.isSelected = false
            checkSavedTime(type: (button.titleLabel?.text)!)
        }
    }
    
    func checkSavedTime(type: String) {
        if Storage.fileExists("power.json", in: .caches) {
            print("power json found")
            let savedPower = Storage.retrieve("power.json", from: .caches, as: PowerStruct.self)
            let hourLater = calendar.date(byAdding: .minute, value: 1, to: savedPower.time)
            if hourLater! < Date() {
                print("ITS been over an hour")
                populateData(type: type)
            } else {
                if type == "THIS WEEK" {
                    populateBarChart(data: savedPower.weekList)
                    updatePwrLabel(text: String(format: "%.2f", savedPower.weekPwr))
                } else {
                    populateBarChart(data: savedPower.monthList)
                    updatePwrLabel(text: String(format: "%.2f", savedPower.monthPwr))
                }
                updateBill(price: savedPower.price)
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
        var totalPrice: Double = 0.0
        let comp = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour], from: today)
        print("The hour is ", comp.hour)

        // these are 2d arrays each array is a day and has 24 length which represents the hours
        var monthHourUsage = Array(repeating: Array(repeating: 0.0, count: 24), count: numDays)
        var monthCounter = Array(repeating: Array(repeating: 0, count: 24), count: numDays)
        
        powerList = [Double](repeating: 0.0, count: numDays)
        powerCount = [Int](repeating: 0, count: numDays)
        totalpower = 0
        
        // loop to populate month usage and month counter 2D arrays
        for x in data {
            let power = ((x["power"] as? Double)!)/1000.0
            let dateStr = x["time"] as? String
            let date = dateFormatter.date(from: dateStr!)
            let tempcomp = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour], from: date!)
            monthHourUsage[tempcomp.day! - 1][tempcomp.hour!] += power
            monthCounter[tempcomp.day! - 1][tempcomp.hour!] += 1
            powerCount[tempcomp.day! - 1] += 1
        }
        
        // now the daily kwh will be calculated
        for i in 0..<comp.day! {
            var powerDay = 0.0
            for j in 0..<24 {
                if monthCounter[i][j] != 0 {
                    powerDay += (monthHourUsage[i][j] / Double(monthCounter[i][j]))
//                    print("The day is ", i, " the hour is ", j, " the counter is ", monthCounter[i][j], " the usage is ",monthHourUsage[i][j] )
                    // changing the accumulated kw in the hour to kwh by dividing by the number of samples in that hour
                    monthHourUsage[i][j] = (monthHourUsage[i][j] / Double(monthCounter[i][j]))
                }
            }
            totalpower += powerDay
            powerList[i] = powerDay
        }
        
        totalPrice = getPriceForMonth(month: comp.month!, day: comp.day!, usage: monthHourUsage)
        print("total price is ", totalPrice)
        updateBill(price: totalPrice)
        
        var weekList = [Double]()
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: today)
        let startindex = components.day! - dayofweek!
        let endindex = components.day! + 7 - dayofweek! - 1
//        print("The startindex is ", startindex, " the day is ", components.day!, " day of week is ", dayofweek!, " the end index is ", endindex)
        weekList = Array<Double>(powerList[startindex...endindex])
        let weekPwr = weekList.reduce(0, +)
        let roundedPwr = totalpower
        let tempPower = PowerStruct(time: Date(), monthList: powerList, monthPwr: totalpower, weekList: weekList, weekPwr: weekPwr, price: totalPrice)
        Storage.store(tempPower, to: .caches, as: "power.json")
        if type == "THIS WEEK" {
            populateBarChart(data: weekList)
            updatePwrLabel(text: String(format: "%.2f", weekPwr))
        } else {
            populateBarChart(data: powerList)
            updatePwrLabel(text: String(format: "%.2f", roundedPwr))
        }
    }
    
    func populateBarChart(data: [Double]) {
        let dataEntries = generateDataEntries(data: data)
        DispatchQueue.main.async {
            self.barChart.dataEntries = dataEntries
        }
    }
    
    func generateDataEntries(data: [Double]) -> [BarEntry] {
        print("THe data gotten for chart is ", data)
        let maxpower = data.max()
        var barColor = UIColor(white: 1, alpha: 0.5)
        var result: [BarEntry] = []
        let weeklabel = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        let dayofweek = getDayOfWeek(today)
        let components = calendar.dateComponents([Calendar.Component.day], from: today)
        for i in 0..<data.count {
            var value: Double = 0
            value = (data[i])/maxpower!
            var height: Float = Float(value)*0.6
            height += 0.025
            var textValue = ""
            var title = ""
            if data.count == 7 {
                //\(data[i])
                textValue = ""
                title = weeklabel[i]
                if i == dayofweek! - 1 {
                    barColor = UIColor.white
                }
            } else {
                if i == components.day! - 1 {
                    barColor = UIColor.white
                }
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
//            cell.layer.cornerRadius = 15
            cell.layer.borderColor = tableView.backgroundColor?.cgColor
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell =
            Bundle.main.loadNibNamed("TipTableViewCell", owner: self, options: nil)?.first as! TipTableViewCell
            cell.layer.borderWidth = CGFloat(10)
//            cell.layer.cornerRadius = 15
            cell.isUserInteractionEnabled = true
            cell.selectionStyle = .none
            cell.layer.borderColor = tableView.backgroundColor?.cgColor
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let url = URL(string: "https://www.redenergy.com.au/living-energy/energy-saving/how-to-save-on-your-laundry-energy-bills")
            let safariVC = SFSafariViewController(url: url!)
            present(safariVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

