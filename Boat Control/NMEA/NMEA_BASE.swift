//
//  NMEA_BASE.swift
//  Boat Control
//
//  Created by Thomas Trageser on 26/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


public class NMEA_BASE {
    
    var _sentence: String
    
    var _talker: String
    var _identifier: String
    var _data: [Substring.SubSequence]
    var _checksum: String
    
    public required init(sentence: String) {
        _sentence = sentence
        
        let talkerRange = _sentence.index(_sentence.startIndex, offsetBy: 1)..._sentence.index(_sentence.startIndex, offsetBy: 2)
        let identifierRange = _sentence.index(_sentence.startIndex, offsetBy: 3)..._sentence.index(_sentence.startIndex, offsetBy: 5)
        let endOfDataIndex = _sentence.index(of: "*")!
        let dataRange = _sentence.index(_sentence.startIndex, offsetBy: 7)..<endOfDataIndex
        let checksumRange = _sentence.index(_sentence.endIndex, offsetBy: -2)..._sentence.index(_sentence.endIndex, offsetBy: -1)

        _talker = String(_sentence[talkerRange])
        _identifier = String(_sentence[identifierRange])
        
        var dataTuples = _sentence[dataRange].split(separator: ",", maxSplits: 20, omittingEmptySubsequences: false)
        _data = Array(dataTuples[..<dataTuples.endIndex])
        _checksum  = String(_sentence[checksumRange])
    }

    public var raw: String {
        return _sentence
    }
    
    public var talker: String {
        return _talker
    }
    
    public var identifier: String {
        return _identifier
    }

    public var checksum: String {
        return _checksum
    }

    public func toString() -> String{
        return "Talker: \(talker); Identifier: \(identifier); "
    }
    
    public func convertUTCTime(utcTime: String) -> Date {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd HHmmss.sss"
        dataFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let currentFormatter = DateFormatter()
        currentFormatter.dateFormat = "yyyy-MM-dd"
        currentFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let stringDate = currentFormatter.string(from: Date()) + " " + utcTime
        
        return dataFormatter.date(from: stringDate)!
    }

}
