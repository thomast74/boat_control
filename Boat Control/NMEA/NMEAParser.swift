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
        let identifierRange = sentence.index(sentence.startIndex, offsetBy: 2)..<sentence.index(sentence.startIndex, offsetBy: 5)
        let identifier = String(sentence[identifierRange])
        
        if NMEASentences.ALL.contains(identifier) {
            let nmeaClass = classFromIdentifier(identifier) as! NMEA_BASE.Type
            let nmeaObj = nmeaClass.init(sentence: sentence)
            return nmeaObj
        } else {
            return NMEA_BASE(sentence: sentence)
        }
    }
    
    static func classFromIdentifier(_ identifier: String) -> AnyClass! {
        //print("Get class for Boat_Control.NMEA_\(identifier)")
        let cls: AnyClass = NSClassFromString("Boat_Control.NMEA_" + identifier)!
        
        return cls
    }
}
