//
//  Wind.swift
//  Boat Control
//
//  Created by Thomas Trageser on 30/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


public class Wind {

    private var _timeStamp: Date
    private var _awa: Double = 0.0
    private var _aws: Double = 0.0
    private var _awd: Double = 0.0
    private var _twa: Double = 0.0
    private var _tws: Double = 0.0
    private var _twd: Double = 0.0
    
    public init(windAngle: Double, windSpeed: Double, reference: String, cog: Double, sog: Double, hdg: Double) {
        _timeStamp = Date()
        
        _aws = windSpeed
        
        calcAWA(windAngle: windAngle, hdg: hdg, reference: reference)
        calcAWD(hdg: hdg)
        calcTrueWind(hdg: hdg, cog: cog, sog: sog)
    }
    
    private func calcAWA(windAngle: Double, hdg: Double, reference: String) {
        if reference == "R" {
            if windAngle <= 180.0 {
                _awa = windAngle
            } else {
                _awa = windAngle - 360.0
            }
        } else {
            _awa = windAngle - hdg
            if _awa > 360.0 {
                _awa -= 360.0
            }
            if (_awa > 180.0) {
                _awa -= 360.0
            }
        }
    }
    
    private func calcAWD(hdg: Double) {
        _awd = hdg + _awa
        if _awd > 360.0 {
            _awd -= 360.0
        } else if _awd < 0.0 {
            _awd += 360
        }
        
        if _awd == 0.0 && _aws > 0.0 {
            _awd = 360.00
        }
    }
    
    private func calcTrueWind(hdg: Double, cog: Double, sog: Double) {
        let _tu = tu(hdg: hdg, cog: cog, awa: _awa, sog: sog, aws: _aws)
        let _tv = tv(hdg: hdg, cog: cog, awa: _awa, sog: sog, aws: _aws)
        
        _tws = sqrt(_tu*_tu + _tv*_tv).rounded(toPlaces: 2)
        
        if AWA == 0 && AWS == sog && hdg == cog {
            _twd = 0
        } else {
            _twd = _tu == 0 ? AWD : (270 - fromRadiant(radiant: atan2(_tv, _tu)))
        }
        
        if _twd > 360.0 {
            _twd -= 360.0
        }
        if _twd < 0 {
            _twd += 360
        }
        _twd = _twd.rounded(toPlaces: 2)
        
        //print("sog=\(sog); cog=\(cog); AWS=\(AWS); A1=\(270 - (hdg + AWA)); A2=\((90 - cog)); Tv=\(_tv); Tu=\(_tu); atan2=\(atan2(_tv, _tu)) => \(_tws);\(_twd)")
        
        _twa = _twd - hdg
        if _twa > 360.0 {
            _twa -= 360.0
        }
        if (_twa > 180.0) {
            _twa -= 360.0
        }
        _twa = _twa.rounded(toPlaces: 2)
    }
    
    public var timeStamp: Date {
        return _timeStamp
    }
    
    public var hoursSince: Double {
        return (timeStamp.timeIntervalSinceNow / 60 / 60 * (-1)).rounded(toPlaces: 2)
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
        return _awd
    }
    
    // calculation from SOG, COG and HDG and AWx data
    public var TWA: Double {
        return _twa
    }
    
    // calculation from SOG, COG and HDG and AWx data
    public var TWS: Double {
        return _tws
    }
    
    // calculation from SOG, COG and HDG and AWx data
    public var TWD: Double {
        return _twd
    }
    
    public func clone() -> Wind {
        let clone = Wind(windAngle: 0.0, windSpeed: _aws, reference: "R", cog: 0.0, sog: 0.0, hdg: 0.0)
        clone._timeStamp = _timeStamp
        clone._awa = _awa
        clone._aws = _aws
        clone._awd = _awd
        clone._twa = _twa
        clone._tws = _tws
        clone._twd = _twd

        return clone
    }
    
    private func tu(hdg: Double, cog: Double, awa: Double, sog: Double, aws: Double) -> Double {
        return sog * cos(cogRadiant(cog: cog)) + aws * cos(awdRadiant(hdg: hdg, awa: awa))
    }
    
    private func tv(hdg: Double, cog: Double, awa: Double, sog: Double, aws: Double) -> Double {
        return sog * sin(cogRadiant(cog: cog)) + aws * sin(awdRadiant(hdg: hdg, awa: awa))
    }
    
    private func cogRadiant(cog: Double) -> Double {
        return radiantAngle(angle: (90 - cog))
    }

    private func awdRadiant(hdg: Double, awa: Double) -> Double {
        return radiantAngle(angle: (270 - (hdg + awa)))
    }

    private func radiantAngle(angle: Double) -> Double {
        return angle*(Double.pi/180)
    }
    
    private func fromRadiant(radiant: Double) -> Double {
        return radiant/(Double.pi/180)
    }
}

public struct WindAggregate {
    public var hoursSince: Double
    public var TWS: Double
    public var maxTWS: Double
    public var TWD: Double
}
