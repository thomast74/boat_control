//
//  NMEA_RMC.swift
//  Boat Control
//
//  Created by Thomas Trageser on 27/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

public class NMEA_RMC: NMEA_BASE {
    
    public required init(sentence: String) {
        super.init(sentence: sentence)
    }
 
    public var TimeUTC: Date {
        return super.convertUTCTime(utcTime: String(_data[0]))
    }
    
    public var Status: String {
        return String(_data[1])
    }
    
    public var Latitude: Double {
        return Double(_data[2])!
    }
    
    public var LatitudeDirection: String {
        return String(_data[3])
    }
    
    public var Longitude: Double {
        return Double(_data[4])!
    }
    
    public var LongitudeDirection: String {
        return String(_data[5])
    }
    
    public var SpeedOverGround: Double {
        return Double(_data[6])!
    }
    
    public var CourseOverGround: Double {
        return _data[7].isEmpty
            ? 0.0
            : Double(_data[7])!
    }

    public var Date: Date {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "ddMMyy"
        dataFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dataFormatter.date(from: String(_data[8]))!
    }
    
    public var MagneticVariation: Double {
        return _data[9].isEmpty
            ? 0.0
            : Double(_data[9])!
    }
    
    public var VariationDirection: String {
        return String(_data[10].isEmpty ? "?" : _data[10])
    }
    
    public var FAAModeIndicator: String {
        return String(_data[11])
    }
    
    override public func toString() -> String {
        return super.toString() + "Time: \(TimeUTC); Status: \(Status); Latitude: \(Latitude)\(LatitudeDirection); Longitude: \(Longitude)\(LongitudeDirection); SpeedOverGround: \(SpeedOverGround); CourseOverGround: \(CourseOverGround); Date: \(Date); MagneticVariation: \(MagneticVariation); VariationDirection: \(VariationDirection); FAAModeIndicator: \(FAAModeIndicator);"
    }

}
