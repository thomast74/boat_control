//
//  NMEA_MTW.swift
//  Boat Control
//
//  Created by Thomas Trageser on 01/09/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


public class NMEA_MTW: NMEA_BASE {
    
    public required init(sentence: String) {
        super.init(sentence: sentence)
    }
    
    public var Degrees: Double {
        return _data[0].isEmpty
            ? -1.0
            : Double(_data[0])!
    }
    
    public var UnitOfMeasurement: String {
        return String(_data[1])
    }
    
    override public func toString() -> String {
        return super.toString() + "Degrees: \(Degrees) \(UnitOfMeasurement)"
    }
}
