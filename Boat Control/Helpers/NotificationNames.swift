//
//  NotificationNames.swift
//  Boat Control
//
//  Created by Thomas Trageser on 26/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

class NotificationNames {

    static let SETTINGS_UPDATED = NSNotification.Name("Settings.Updated")

    static let NMEA_CONNECTION_ERROR = NSNotification.Name("NMEA.Connection.Error")
    static let NMEA_RECEIVED_SENTENCE = NSNotification.Name("NMEA.Received.Sentence")
}

