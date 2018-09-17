//
//  NMEA_WMV.swift
//  Boat Control
//
//  Created by Thomas Trageser on 26/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


public class NMEA_MWV: NMEA_BASE {
    
    public required init(sentence: String) {
        super.init(sentence: sentence)
    }
    
    public var WindAngle: Double {
        return _data[0].isEmpty
            ? 0.0
            : Double(_data[0])!
    }
    
    public var Reference: String {
        return String(_data[1])
    }
    
    public var WindSpeed: Double {
        return _data[2].isEmpty
            ? -1.0
            : (Double(_data[2])?.rounded(toPlaces: 1))!
    }
    
    public var SpeedUnits: WindSpeedUnits {
        return WindSpeedUnits(rawValue: String(_data[3]))!
    }
    
    public var Status: String {
        return String(_data[4])
    }
    
    override public func toString() -> String {
        return super.toString() + "WindAngle: \(WindAngle); Reference: \(Reference); WindSpeed: \(WindSpeed); SpeedUnits: \(SpeedUnits); Status: \(Status)"
    }
}
