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
    
    private let maxValue: Double
    
    public init(maxValue: Double) {
        self.maxValue = maxValue
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let labelValue = (maxValue - value)
        return String(labelValue.rounded(toPlaces: 2))
    }

}
