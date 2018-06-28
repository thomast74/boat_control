//
//  NMEAParser.swift
//  Boat Control
//
//  Created by Thomas Trageser on 26/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


class NMEAParser {
    
    static func convert(sentence: String) -> NMEA_BASE {
        // get identifier
        let identifierRange = sentence.index(sentence.startIndex, offsetBy: 3)..<sentence.index(sentence.startIndex, offsetBy: 6)
        let identifier = String(sentence[identifierRange])

        let nmeaClass = classFromIdentifier(identifier) as! NMEA_BASE.Type
        let nmeaObj = nmeaClass.init(sentence: sentence)
        
        return nmeaObj
    }
    
    static func classFromIdentifier(_ identifier: String) -> AnyClass! {
        print("Get class for Boat_Control.NMEA_\(identifier)")
        let cls: AnyClass = NSClassFromString("Boat_Control.NMEA_" + identifier)!
        
        return cls
    }
}
