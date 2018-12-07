//
//  NMEA_HDG.swift
//  Boat Control
//
//  Created by Thomas Trageser on 02/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//
// Field Number:
// 1. Magnetic Sensor heading in degrees
// 2. Magnetic Deviation, degrees
// 3. Magnetic Deviation direction, E = Easterly, W = Westerly
// 4. Magnetic Variation degrees
// 5. Magnetic Variation direction, E = Easterly, W = Westerly


import Foundation


public class NMEA_HDG: NMEA_BASE {
    
    public required init(sentence: String) {
        super.init(sentence: sentence)
    }
    
    public var MagneticHeading: Double {
        return _data[0].isEmpty
            ? -1.0
            : Double(_data[0])!
    }
    
    public var MagneticDeviation: Double {
        return _data[1].isEmpty
            ? 0.0
            : Double(_data[1])!
    }
    
    public var MagneticDeviationDirection: String {
        return String(_data[2])
    }
    
    public var MagneticVariation: Double {
        return _data[3].isEmpty
            ? 0.0
            : Double(_data[3])!
    }
    
    public var MagneticVariationDirection: String {
        return String(_data[4])
    }
    
    override public func toString() -> String {
        return super.toString() + "MagneticHeading: \(MagneticHeading); MagneticDeviation: \(MagneticDeviation); MagneticDeviationDirection: \(MagneticDeviationDirection); MagneticVariation: \(MagneticVariation); MagneticVariationDirection: \(MagneticVariationDirection)"
    }

}
