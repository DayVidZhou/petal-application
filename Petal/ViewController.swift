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
    
    var baseURL = "https://flask-petal.herokuapp.com/"
    
    // initializing variables used for date objects
    let dateFormatter = DateFormatter()
    let today = Date()
    let calendar = Calendar(identifier: .gregorian)
    var totalpower: Double = 0.0
    let startdate: String = "03-01-2019-00"
    
    override func viewDidLoad() {
        print("testing print")
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks.
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.allowsSelection = false
        weekBtn.titleLabel?.textColor = UIColor.white
        weekBtn.addTarget(self, action: #selector(weekMonthPressed), for: .touchUpInside)
        monthBtn.addTarget(self, action: #selector(weekMonthPressed), for: .touchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
        setButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dateFormatter.dateFormat = "MM-dd-yyyy-HH"
        populateData(type: "THIS WEEK")
    }
    
    // setting the button for when button is selected and when it is normal
    func setButtonState() {
        //let fontColor = UIColor(red: 211, green: 242, blue: 232, alpha: 1)
        monthBtn.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        weekBtn.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        monthBtn.setTitleColor(UIColor.white, for: .selected)
        weekBtn.setTitleColor(UIColor.white, for: .selected)
        weekBtn.tintColor = UIColor(white: 0, alpha: 0)
        monthBtn.tintColor = UIColor(white: 0, alpha: 0)
    }
    
    // action button for week and month button
    @objc func weekMonthPressed(sender:UIButton) {
        let button = sender
        print(button.titleLabel?.text as Any)
        print("the state is ", button.isSelected)
        if !button.isSelected {
            button.isSelected = true
        }
        
        switch button.titleLabel?.text {
        case "THIS WEEK":
            monthBtn.isSelected = false
        case "MONTH":
            weekBtn.isSelected = false
        default:
            monthBtn.isSelected = false
        }
        populateData(type: (button.titleLabel?.text)!)
    }
    
    // This function handles the http request and passes the jsonarray to processdata
    func populateData(type: String) {
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: today)
        let endday = components.day! + 1
        
        let link: String = baseURL + "measurements?start=" + startdate + "&end=03-" + String(endday) + "-2019-00"
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
        var powerList = [Double](repeating: 0.0, count: numDays)
        totalpower = 0
        for x in data {
            let power = x["power"] as? Double
            totalpower += power!
            let dateStr = x["time"] as? String
            let date = dateFormatter.date(from: dateStr!)
            let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: date!)
            powerList[components.day! - 1] += power!
        }
        var finalList = [Double]()
        if type == "THIS WEEK" {
            let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: today)
            let startindex = components.day! - dayofweek!
            let endindex = components.day! + 7 - dayofweek! - 1
            print("The startindex is ", startindex, " the day is ", components.day!, " day of week is ", dayofweek!, " the end index is ", endindex)
            finalList = Array<Double>(powerList[startindex...endindex])
        } else {
            finalList = powerList
        }
        let maxpower = finalList.max()
        print("The total power is ", totalpower, " the max power is", maxpower!)
        DispatchQueue.main.async {
            self.powerlabel.text = String(self.totalpower)
        }
        populateBarChart(data: finalList, maxpower: maxpower!)
        
    }
    
    // gets the day of week
    func getDayOfWeek(_ today: Date) -> Int? {
        let weekDay = calendar.component(.weekday, from: today)
        return weekDay
    }
    
    func populateBarChart(data: [Double], maxpower: Double) {
        let dataEntries = generateDataEntries(data: data, maxpower: maxpower)
        DispatchQueue.main.async {
            self.barChart.dataEntries = dataEntries
        }
    }
    
    func generateDataEntries(data: [Double], maxpower: Double) -> [BarEntry] {
        print("THe data gotten for chart is ", data)
        let barColor = #colorLiteral(red: 0.8274509804, green: 0.9490196078, blue: 0.9098039216, alpha: 1)
        var result: [BarEntry] = []
        let weeklabel = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        
        for i in 0..<data.count {
            let value = (data[i]/maxpower)*80
            let height: Float = Float(value) / 100.0
            var title = ""
            if data.count == 7 {
                title = weeklabel[i]
            }
            result.append(BarEntry(color: barColor, height: height, textValue: "\(data[i])", title: title))
        }
        return result
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

