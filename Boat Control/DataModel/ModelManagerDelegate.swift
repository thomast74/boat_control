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
    func modelManager(didReceiveWindHistory windHistory: [WindAggregate])
    func modelManager(didReceiveNavigation navigation: Navigation)
    func modelManager(didReceiveNavigationHistory navigationHistory: [NavigationAggregate])
    func modelManager(didReceiveSentence nmeaObj: NMEA_BASE)
    func modelManager(didReceiveSystemMessage message: String, of type: MessageType)
}
