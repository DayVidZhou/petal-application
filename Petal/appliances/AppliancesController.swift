//
//  AppliancesController.swift
//  Petal
//
//  Created by David Zhou on 2019-03-12.
//  Copyright © 2019 David Zhou. All rights reserved.
//
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

import UIKit

class AppliancesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var applianceTable: UITableView!
    @IBOutlet weak var scanBtn: UIButton!
    
    private let refreshControl = UIRefreshControl()
    let baseURL = "https://flask-petal.herokuapp.com/"
    
    var appliances: [Appliance] = [
        Appliance(appliance: "Blender", image: UIImage(named: "blender")!, power: 52.0, duration: 10),
        Appliance(appliance: "Hair iron", image: UIImage(named: "hairiron")!, power: 52.0, duration: 10),
        Appliance(appliance: "Heater fan", image: UIImage(named: "heater")!, power: 52.0, duration: 10)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applianceTable.allowsSelection = false
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        applianceTable.refreshControl = refreshControl
        getAppliances()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func refreshPage() {
        print("pulled to refresh")
        getAppliances()
        refreshControl.endRefreshing()
    }
    
    @IBAction func scanForAppliances(_ sender: Any) {
        getAppliances()
    }
    
    func getAppliances() {
        
        let link: String = baseURL + "appliancesData"
        let linkURL = URL(string: link)!
        let task = URLSession.shared.dataTask(with: linkURL) { (data, response, error) in
            if error == nil {
                do {
                    let jsonresponse = try JSONSerialization.jsonObject(with: data!, options: [])
                    let jsonArray = jsonresponse as! [[String: Any]]
                    self.processAppliances(data: jsonArray)
                } catch let e{
                    print("ERROR IS ,", e)
                }
            }
        }
        task.resume()
    }
    
    func processAppliances(data: [[String: Any]]) {
        var tempappliances = [Appliance]()
        for x in data {
            var picture: UIImage
            switch x["name"] as? String {
            case "blender":
                picture = UIImage(named: "blender")!
            case "toaster":
                picture = UIImage(named: "Toaster")!
            case "hair dryer":
                picture = UIImage(named: "dryer")!
            case "hair iron":
                picture = UIImage(named: "hairiron")!
            case "heater":
                picture = UIImage(named: "heater")!
            default:
                picture = UIImage(named: "blender")!
            }
            let tempappliance = Appliance(appliance: x["name"] as! String, image: picture, power: (x["power"] as! Double)/3600, duration: (x["duration"] as! Int))
            tempappliances.append(tempappliance)
        }
        tempappliances.sort{
            $0.power > $1.power
        }
        appliances = tempappliances
        
        DispatchQueue.main.async {
            self.applianceTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appliances.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let interval = appliances[indexPath.row].duration
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .brief
        
        let formattedString = formatter.string(from: TimeInterval(interval))!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "applianceCell") as! ApplianceViewCell
        cell.applduration.text = "Used for " + formattedString
        cell.applname.text = appliances[indexPath.row].appliance.capitalizingFirstLetter()
        cell.applimage.image = appliances[indexPath.row].image
        cell.applpower.text = String(format: "%.2f", appliances[indexPath.row].power)
        cell.layer.borderWidth = CGFloat(10)
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
        return cell
    }
    
    
}
