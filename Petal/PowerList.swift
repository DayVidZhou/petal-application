//
//  PowerList.swift
//  Petal
//
//  Created by David Zhou on 2019-03-10.
//  Copyright © 2019 David Zhou. All rights reserved.
//

import Foundation

struct PowerStruct: Codable {
    let time: Date
    let monthList: [Double]
    let monthPwr: Double
    let weekList: [Double]
    let weekPwr: Double
    let price: Double
}
