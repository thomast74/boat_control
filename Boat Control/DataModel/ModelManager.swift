//
//  ModelManager.swift
//  Boat Control
//
//  Created by Thomas Trageser on 30/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

class ModelManager {
    
    /*
    var lastGGA: NMEA_GGA
    var lastGLL: NMEA_GLL
    var lastMWV: NMEA_MWV
    var lastRMC: NMEA_RMC
    
    var wind: Wind
    var windHistory: WindHistory
    */
    
    // when new MWV received check if RMC exists and create new WIND and add it into WINDHISTORY
    // when new RMC received check if MVW exists and create new WIND and add it into WINDHOSTORY
    // => send new Wind Data notifcation
    
    // when GGA, GLL or RMC received create new GPS object with new data
    // send new GPS Data notification
    
    // object should be singleton so when notificaton is received it is easy to get the data
    // must be thread safe sooo!!!!!!
    
    
}
