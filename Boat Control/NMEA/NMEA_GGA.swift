//
//  NMEA_GGA.swift
//  Boat Control
//
//  Created by Thomas Trageser on 27/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

class NMEA_GGA: NMEA_BASE {
    
    required init(sentence: String) {
        super.init(sentence: sentence)
    }
    
    public var TimeUTC: Date {
        return super.convertUTCTime(utcTime: String(_data[0]))
    }
    
    public var Latitude: Double {
        return Double(_data[1])!
    }
    
    public var LatitudeDirection: String {
        return String(_data[2])
    }
    
    public var Longitude: Double {
        return Double(_data[3])!
    }
    
    public var LongitudeDirection: String {
        return String(_data[4])
    }
    
    /*
     GPS Quality Indicator
         0 - fix not available,
         1 - GPS fix,
         2 - Differential GPS fix (values above 2 are 2.3 features)
         3 = PPS fix
         4 = Real Time Kinematic
         5 = Float RTK
         6 = estimated (dead reckoning)
         7 = Manual input mode
         8 = Simulation mode
     */
    public var GPSQualityIndicator: GPSQualityIndicator {
        return Boat_Control.GPSQualityIndicator(rawValue: Int(_data[5])!)!
    }

    public var NumberOfSatalites: Int {
        return Int(_data[6])!
    }
    
    public var HorizontalDilution: Double {
        return Double(_data[7])!
    }
    
    public var AntennaAltitude: Double {
        return Double(_data[8])!
    }
    
    public var UnitsOfAntennaAltitude: String {
        return String(_data[9])
    }

    public var GeoidalSeparation: Double {
        return Double(_data[10])!
    }
    
    public var UnitsOfGeoidalSeparation: String {
        return String(_data[11])
    }
    
    public var AgeOfDifferential: Double {
        return _data[12].isEmpty
            ? 0.0
            : Double(_data[12])!
    }
    
    public var DifferentialReferenceStationID: String {
        return String(_data[13])
    }
    
    override public func toString() -> String {
        return super.toString() + "Time: \(TimeUTC); Latitude: \(Latitude)\(LatitudeDirection); Longitude: \(Longitude)\(LongitudeDirection); GPSQualityIndicator: \(GPSQualityIndicator); NumberOfSatalites: \(NumberOfSatalites); HorizontalDilution: \(HorizontalDilution); AntennaAltitude: \(AntennaAltitude); UnitsOfAntennaAltitude: \(UnitsOfAntennaAltitude); GeoidalSeparation: \(GeoidalSeparation); UnitsOfGeoidalSeparation: \(UnitsOfGeoidalSeparation); AgeOfDifferential: \(AgeOfDifferential); DifferentialReferenceStationID: \(DifferentialReferenceStationID);"
    }
}
