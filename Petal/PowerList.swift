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
    let monthCount: [Int]
    let weekList: [Double]
    let weekCount: [Int]
    let roundedPwr: Double
    let price: Double
}
