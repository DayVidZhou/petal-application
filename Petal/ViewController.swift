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
    @IBOutlet weak var mainTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks.
        homeTableView.delegate = self
        homeTableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dataEntries = generateDataEntries()
        barChart.dataEntries = dataEntries
    }
    
    func generateDataEntries() -> [BarEntry] {
        let barColor = #colorLiteral(red: 0.8274509804, green: 0.9490196078, blue: 0.9098039216, alpha: 1)
        var result: [BarEntry] = []
        for i in 0..<20 {
            let value = (arc4random() % 90) + 10
            let height: Float = Float(value) / 100.0
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i))
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

