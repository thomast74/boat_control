//
//  ModelManagerDelegate.swift
//  Boat Control
//
//  Created by Thomas Trageser on 03/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

public protocol ModelManagerDelegate {
    func modelManager(didReceiveWind wind: Wind)
    func modelManager(didReceiveWindHistory windHistory: [Wind])
    func modelManager(didReceiveNavigation navigation: Navigation)
    func modelManager(didReceiveSentence nmeaObj: NMEA_BASE)
}


public class ModelManagerDelegateImpl: ModelManagerDelegate {

    public func modelManager(didReceiveWind wind: Wind) {

    }
    
    public func modelManager(didReceiveWindHistory windHistory: [Wind]) {

    }
    
    public func modelManager(didReceiveNavigation navigation: Navigation) {

    }
    
    public func modelManager(didReceiveSentence nmeaObj: NMEA_BASE) {

    }

}
