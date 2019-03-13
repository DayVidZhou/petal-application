//
//  TipTableViewCell.swift
//  Petal
//
//  Created by David Zhou on 2019-01-16.
//  Copyright © 2019 David Zhou. All rights reserved.
//

import UIKit

class TipTableViewCell: UITableViewCell {

    @IBOutlet weak var tipText: UILabel!
    @IBOutlet weak var tipImage: UIImageView!
    @IBOutlet weak var linkbtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
