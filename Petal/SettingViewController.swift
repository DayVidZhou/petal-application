//
//  SettingViewController.swift
//  Petal
//
//  Created by David Zhou on 2019-03-14.
//  Copyright © 2019 David Zhou. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    let baseUrl = "https://flask-petal.herokuapp.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteAppliancePressed(_ sender: Any) {
        let link: String = baseUrl + "/delete_all_appliances"
        let linkURL = URL(string: link)!
        let task = URLSession.shared.dataTask(with: linkURL) { (data, response, error) in
            if error == nil {
                print("all appliances deletedddd")
            }
        }
        task.resume()
    }
    
    @IBAction func deleteCachePressed(_ sender: Any) {
        print("Deleted cache")
        Storage.remove("power.json", from: .caches)
    }
}
