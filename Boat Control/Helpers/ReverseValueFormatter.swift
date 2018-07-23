//
//  ReverseValueFormatter.swift
//  Boat Control
//
//  Created by Thomas Trageser on 11/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import Charts

public class ReverseValueFormatter: IAxisValueFormatter {
    
    public init() {
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let hour = Int(value)
        
        var minute = Int((value * 60.0).remainder(dividingBy: 60.0))
        if minute < 0 {
            minute *= -1
        }
        
        return String("\(value < 0 ? "-" : "")\(hour):\(minute < 10 ? "0" : "")\(minute)")
    }

}
