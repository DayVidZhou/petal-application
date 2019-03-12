//
//  ApplianceViewCell.swift
//  Petal
//
//  Created by David Zhou on 2019-03-12.
//  Copyright © 2019 David Zhou. All rights reserved.
//

import UIKit

struct Appliance  {
    let appliance: String
    let image: UIImage
    let power: Double
    let duration: Int
}

class ApplianceViewCell: UITableViewCell {
    @IBOutlet weak var applimage: UIImageView!
    @IBOutlet weak var applname: UILabel!
    @IBOutlet weak var applduration: UILabel!
    @IBOutlet weak var applpower: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
