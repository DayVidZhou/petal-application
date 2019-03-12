//
//  AppliancesController.swift
//  Petal
//
//  Created by David Zhou on 2019-03-12.
//  Copyright © 2019 David Zhou. All rights reserved.
//

import UIKit

class AppliancesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var applianceTable: UITableView!
    @IBOutlet weak var scanBtn: UIButton!
    
    private let refreshControl = UIRefreshControl()
    
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
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scanBtn.layer.borderWidth = 1
        scanBtn.layer.borderColor = UIColor(red: 30/255, green: 209/255, blue: 140/255, alpha: 1).cgColor
        scanBtn.layer.cornerRadius = 20
    }
    
    @objc func refreshPage() {
        print("pulled to refresh")
        applianceTable.reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func scanForAppliances(_ sender: Any) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appliances.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "applianceCell") as! ApplianceViewCell
        cell.applduration.text = "Used for " + String(appliances[indexPath.row].duration) + "min"
        cell.applname.text = appliances[indexPath.row].appliance
        cell.applimage.image = appliances[indexPath.row].image
        cell.applpower.text = String(appliances[indexPath.row].power)
        cell.layer.borderWidth = CGFloat(10)
        cell.layer.cornerRadius = 15
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
        return cell
    }
}
