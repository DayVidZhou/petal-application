//
//  processData.swift
//  Petal
//
//  Created by David Zhou on 2019-03-10.
//  Copyright © 2019 David Zhou. All rights reserved.
//

import Foundation

func getPriceForMonth(month: Int, day: Int, usage: [[Double]]) -> Double {
    var totalprice = 0.0
    for i in 0..<day{
        for j in 0..<24 {
            if usage[i][j] != 0 {
                if month > 4 || month < 10 {
                    if j >= 20 || j <= 7 {
                        totalprice += usage[i][j]*0.065
                    } else if j >= 12 && j <= 17 {
                        totalprice += usage[i][j]*0.094
                    } else {
                        totalprice += usage[i][j]*0.132
                    }
                } else {
                    if j >= 19 || j <= 6 {
                        totalprice += usage[i][j]*0.065
                    } else if j >= 11 && j <= 16 {
                        totalprice += usage[i][j]*0.132
                    } else {
                        totalprice += usage[i][j]*0.094
                    }
                }
            }
        }
    }
    //
    return totalprice
}
