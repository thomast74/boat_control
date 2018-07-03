//
//  ModelManager.swift
//  Boat Control
//
//  Created by Thomas Trageser on 30/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

class ModelManager: NMEAReceiverDelegate {
    
    var lastGGA: NMEA_GGA?
    var lastGLL: NMEA_GLL?
    var lastMWV: NMEA_MWV?
    var lastMWVDate: Date
    var lastRMC: NMEA_RMC?

    var lastHDG: NMEA_HDG?
    var lastHDGDate: Date
    var lastVHW: NMEA_VHW?
    var lastVHWDate: Date
    
    //var lastDBT: NMEA_DBT?
    //var lastMTW: NMEA_MTW?
    //var lastVLW: NMEA_VLW?
     
     
    var wind: Wind
    var windHistory: WindHistory
        
    // object should be singleton so when notificaton is received it is easy to get the data
    // must be thread safe sooo!!!!!!
    
    init() {
        windHistory = WindHistory()

        wind = Wind(windAngle: 0.0, windSpeed: 0.0, reference: "R", cog: 0.0, sog: 0.0, hdg: 0.0)
        windHistory.add(wind)
        
        lastMWVDate = Date()
        lastHDGDate = Date()
        lastVHWDate = Date()
    }
    
    func nmeaReceived(data: NMEA_BASE) {
        switch(data.identifier) {
        case "MWV":
            processNmea(data: data as! NMEA_MWV)
            break
        case "GGA":
            processNmea(data: data as! NMEA_GGA)
            break
        case "GLL":
            processNmea(data: data as! NMEA_GLL)
            break
        case "RMC":
            processNmea(data: data as! NMEA_RMC)
            break
        case "HDG":
            processNmea(data: data as! NMEA_HDG)
            break
        case "VHW":
            processNmea(data: data as! NMEA_VHW)
            break
        default:
            print("Not known data object received")
        }
    }

    func processNmea(data: NMEA_MWV) {
        lastMWV = data
        lastMWVDate = Date()
        
        createWind()
    }
    
    func processNmea(data: NMEA_GGA) {
        updateGPS()
    }
    
    func processNmea(data: NMEA_GLL) {
        updateGPS()
    }
    
    func processNmea(data: NMEA_RMC) {
        lastRMC = data
        
        createWind()
        updateGPS()
    }
    
    func processNmea(data: NMEA_HDG) {
        lastHDG = data
        lastMWVDate = Date()
        
        createWind()
    }
    
    func processNmea(data: NMEA_VHW) {
        lastVHW = data
        lastVHWDate = Date()
        
        createWind()
    }
    
    func createWind() {
        if lastMWV == nil {
            return
        }
        
        let hdg: Double
        let cog: Double
        let sog: Double
        
        if lastRMC != nil {
            cog = lastRMC!.CourseOverGround
            sog = lastRMC!.SpeedOverGround
        } else {
            cog = 0.0
            sog = 0.0
        }
        
        if lastHDG != nil && lastMWVDate > lastVHWDate {
            hdg = lastHDG!.MagneticHeading // TODO: convert to true
        } else if lastVHW != nil {
            hdg = lastVHW!.MagneticHeading // TODO: convert to true
        } else {
            hdg = cog
        }
        
        wind = Wind(windAngle: lastMWV!.WindAngle, windSpeed: lastMWV!.WindSpeed, reference: lastMWV!.Reference, cog: cog, sog: sog, hdg: hdg)
        windHistory.add(wind)
        
        // TODO: call new wind delegate
    }
    
    func updateGPS() {
        // TODO: implement GPS object
    }
    
}
