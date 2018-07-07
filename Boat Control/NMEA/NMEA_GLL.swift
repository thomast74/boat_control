//
//  NMEA_GLL.swift
//  Boat Control
//
//  Created by Thomas Trageser on 27/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


public class NMEA_GLL: NMEA_BASE {
    
    public required init(sentence: String) {
        super.init(sentence: sentence)
    }
    
    public var Latitude: Double {
        return Double(_data[0]) ?? 0.0
    }
    
    public var LatitudeDirection: String {
        return String(_data[1])
    }
    
    public var Longitude: Double {
        return Double(_data[2]) ?? 0.0
    }
    
    public var LongitudeDirection: String {
        return String(_data[3])
    }
    
    public var TimeUTC: Date {
        return super.convertUTCTime(utcTime: String(_data[4]))
    }
    
    public var Status: String {
        return String(_data[5])
    }
    
    override public func toString() -> String {
        return super.toString() + "Latitude: \(Latitude)\(LatitudeDirection); Longitude: \(Longitude)\(LongitudeDirection); Time: \(TimeUTC); Status: \(Status);"
    }
}

