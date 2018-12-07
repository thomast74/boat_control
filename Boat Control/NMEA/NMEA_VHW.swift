//
//  NMEA_VHW.swift
//  Boat Control
//
//  Created by Thomas Trageser on 02/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//
// Field Number:
//    1. Degress True
//    2. T = True
//    3. Degrees Magnetic
//    4. M = Magnetic
//    5. Knots (speed of vessel relative to the water)
//    6. N = Knots
//    7. Kilometers (speed of vessel relative to the water)
//    8. K = Kilometers

import Foundation


public class NMEA_VHW: NMEA_BASE {
    
    public required init(sentence: String) {
        super.init(sentence: sentence)
    }
    
    public var TrueHeading: Double {
        return _data[0].isEmpty
            ? -1.0
            : Double(_data[0])!
    }

    public var TrueHeadingDesc: String {
        return String(_data[1])
    }

    public var MagneticHeading: Double {
        return _data[2].isEmpty
            ? -1.0
            : Double(_data[2])!
    }

    public var MagneticHeadingDesc: String {
        return String(_data[3])
    }

    public var BoatSpeedKnots: Double {
        return _data[4].isEmpty
            ? 0.0
            : Double(_data[4])!
    }
    
    public var BoatSpeedKnotsDesc: String {
        return String(_data[5])
    }

    public var BoatSpeedKm: Double {
        return _data[6].isEmpty
            ? 0.0
            : Double(_data[6])!
    }
    
    public var BoatSpeedKmDesc: String {
        return String(_data[7])
    }

    override public func toString() -> String {
        return super.toString() + "TrueHeading: \(TrueHeading)\(TrueHeadingDesc); MagneticHeading: \(MagneticHeading)\(MagneticHeadingDesc); BoatSpeedKnots: \(BoatSpeedKnots)\(BoatSpeedKnotsDesc); BoatSpeedKm: \(BoatSpeedKm)\(BoatSpeedKmDesc)"
    }

}
