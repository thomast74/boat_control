//
//  DoubleExtensions.swift
//  Boat Control
//
//  Created by Thomas Trageser on 01/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

extension Double {
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}
