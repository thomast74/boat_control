//
//  WindHistory.swift
//  Boat Control
//
//  Created by Thomas Trageser on 30/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

class WindHistory {
    
    var _history: [Wind] = []
    
    init() {
    }
    
    // when a new wind object is generated it must be added to the history with a time stamp
    // everything that is older then x hours (from settings) will be deleted
    
    public func add(_ wind: Wind) {
        _history.append(wind)
    }
    
    public var history: [Wind] {
        _history.sort(by: { $0.timeStamp > $1.timeStamp} )
        
        return _history
    }
    
    public func clear() {
        _history.removeAll()
    }
}
