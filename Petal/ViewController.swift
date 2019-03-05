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
    let dateFormatter = DateFormatter()
    let today = Date()
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
        let dataEntries = generateDataEntries()
        barChart.dataEntries = dataEntries
        dateFormatter.dateFormat = "MM-dd-yyyy-HH"
    }
    
    func setButtonState() {
        //let fontColor = UIColor(red: 211, green: 242, blue: 232, alpha: 1)
        monthBtn.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        weekBtn.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        monthBtn.setTitleColor(UIColor.white, for: .selected)
        weekBtn.setTitleColor(UIColor.white, for: .selected)
        weekBtn.tintColor = UIColor(white: 0, alpha: 0)
        monthBtn.tintColor = UIColor(white: 0, alpha: 0)
    }
    
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
    
    // This function calls the http request
    func populateData(type: String) {
        let calendar = Calendar(identifier: .gregorian)
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
        let calendar = Calendar(identifier: .gregorian)
        let range = calendar.range(of: .day, in: .month, for: today)!
        let numDays = range.count
        var powerList = [Double](repeating: 0.0, count: numDays)
        //print("DATA GOTTE NIS ", data)
        for x in data {
            let power = x["power"] as? Double
            totalpower += power!
            print("The power is ", power!)
            
            let dateStr = x["time"] as? String
            let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: today)
            
        }
    }
    
    func getDayOfWeek(_ today: Date) -> Int? {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: today)
        return weekDay
    }
    
    func generateDataEntries() -> [BarEntry] {
        let barColor = #colorLiteral(red: 0.8274509804, green: 0.9490196078, blue: 0.9098039216, alpha: 1)
        var result: [BarEntry] = []
        for i in 0..<6 {
            let value = (arc4random() % 80) + 10
            let height: Float = Float(value) / 100.0
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60 * -i))
            result.append(BarEntry(color: barColor, height: height, textValue: "\(value)", title: formatter.string(from: date)))
        }
        return result
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cellArr = [UITableViewCell]()
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
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

