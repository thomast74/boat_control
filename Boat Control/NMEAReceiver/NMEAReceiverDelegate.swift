//
//  NMEAReceiverDelegate.swift
//  Boat Control
//
//  Created by Thomas Trageser on 02/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


public protocol NMEAReceiverDelegate {
    func nmeaReceived(data: NMEA_BASE)
    func socket(received message: String, of type: MessageType)
}

public enum MessageType {
    case Information
    case Error
}
