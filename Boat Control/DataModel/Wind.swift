//
//  Wind.swift
//  Boat Control
//
//  Created by Thomas Trageser on 30/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


class Wind {

    var timeStamp: Date
    var _awa: Double
    var _aws: Double
    var _cog: Double
    var _sog: Double
    var _hdg: Double
    
    init(windAngle: Double, windSpeed: Double, reference: String, cog: Double, sog: Double, hdg: Double) {
        timeStamp = Date()
        
        _cog = cog
        _sog = sog
        _hdg = hdg
        
        if reference == "R" {
            if windAngle <= 180.0 {
                _awa = windAngle
            } else {
                _awa = windAngle - 360.0
            }
        } else {
            _awa = windAngle - _hdg
            if _awa > 360.0 {
                _awa -= 360.0
            }
            if (_awa > 180.0) {
                _awa -= 360.0
            }
        }
        
        _aws = windSpeed
    }
    
    public var TimeStamp: Date {
        return timeStamp
    }
    
    // get from NMEA MWV sentence
    public var AWA: Double {
        return _awa
    }
    
    // get from NMEA MWV sentence
    public var AWS: Double {
        return _aws
    }

    // get from NMEA HDG and MWV sentence
    public var AWD: Double {
        var awd = _hdg + _awa
        if awd > 360.0 {
            awd -= 360.0
        } else if awd < 0.0 {
            awd += 360
        }
        
        if awd == 0.0 && AWS > 0.0 {
            awd = 360.00
        }
        
        return awd
    }
    
    // calculation from SOG, COG and HDG and AWx data
    public var TWA: Double {
        var twa = TWD - _hdg
        if twa > 360.0 {
            twa -= 360.0
        }
        if (twa > 180.0) {
            twa -= 360.0
        }
        
        return twa.rounded(toPlaces: 2)
    }
    
    // calculation from SOG, COG and HDG and AWx data
    public var TWS: Double {
        return sqrt(tu*tu+tv*tv).rounded(toPlaces: 2)
    }
    
    // calculation from SOG, COG and HDG and AWx data
    public var TWD: Double {
        var twd: Double
        
        if AWA == 0 && AWS == _sog && _hdg == _cog {
            twd = 0
        } else {
            twd = (270.0 - (tu == 0 ? 270 : fromRadiant(radiant: atan2(tv, tu))))
        }
        
        if twd > 360.0 {
            twd -= 360.0
        }
        
        print("A1=\(270 - (_hdg + AWA)); A2=\((90 - _cog)); Tv=\(tv); Tu=\(tu); atan2=\(atan2(tv, tu)) => \(twd)")
        
        return twd.rounded(toPlaces: 2)
    }
    
    private var tu: Double {
        return _sog * cos(cogRadiant) + AWS * cos(awdRadiant)
    }
    
    private var tv: Double {
        return _sog * sin(cogRadiant) + AWS * sin(awdRadiant)
    }
    
    private var cogRadiant: Double {
        return radiantAngle(angle: (90 - _cog))
    }

    private var awdRadiant: Double {
        return radiantAngle(angle: (270 - (_hdg + AWA)))
    }

    private func radiantAngle(angle: Double) -> Double {
        return angle*(Double.pi/180)
    }
    
    private func fromRadiant(radiant: Double) -> Double {
        return radiant/(Double.pi/180)
    }
}
