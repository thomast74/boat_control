//
//  NMEA_WMV.swift
//  Boat Control
//
//  Created by Thomas Trageser on 26/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


class NMEA_MWV: NMEA_BASE {
    
    required init(sentence: String) {
        super.init(sentence: sentence)
    }
    
    public var WindAngle: Double {
        return Double(_data[0])!
    }
    
    public var Reference: String {
        return String(_data[1])
    }
    
    public var WindSpeed: Double {
        return Double(_data[2])!
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
