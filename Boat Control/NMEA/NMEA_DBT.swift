//
//  NMEA_DBT.swift
//  Boat Control
//
//  Created by Thomas Trageser on 01/09/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


public class NMEA_DBT: NMEA_BASE {
    
    public required init(sentence: String) {
        super.init(sentence: sentence)
    }
    
    public var DepthFeet: Double {
        return _data[0].isEmpty
            ? -1.0
            : Double(_data[0])!
    }
    
    public var DepthFeetDesc: String {
        return String(_data[1])
    }
    
    public var DepthMeters: Double {
        return _data[2].isEmpty
            ? -1.0
            : Double(_data[2])!
    }
    
    public var DepthMetersDesc: String {
        return String(_data[3])
    }
    
    public var DepthFathoms: Double {
        return _data[4].isEmpty
            ? -1.0
            : Double(_data[4])!
    }
    
    public var DepthFathomsDesc: String {
        return String(_data[5])
    }

    override public func toString() -> String {
        return super.toString() + "DepthFeet: \(DepthFeet); DepthMeters: \(DepthMeters); DepthFathoms: \(DepthFathoms)"
    }
}
