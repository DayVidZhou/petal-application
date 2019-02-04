//
//  BillTableViewCell.swift
//  Petal
//
//  Created by David Zhou on 2019-01-16.
//  Copyright © 2019 David Zhou. All rights reserved.
//

import UIKit

class BillTableViewCell: UITableViewCell {

    @IBOutlet weak var billText: UILabel!
    @IBOutlet weak var pointsText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
