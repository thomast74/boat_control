//
//  WindHistory.swift
//  Boat Control
//
//  Created by Thomas Trageser on 30/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

public class WindHistory {
    
    fileprivate let concurrentWindHistoryQueue = DispatchQueue(label: "com.arohanui.boat_control.WindHistory", attributes: .concurrent)

    private var _windArray: [Wind]

    public init() {
        _windArray = []
    }
    
    // when a new wind object is generated it must be added to the history with a time stamp
    // everything that is older then x hours (from settings) will be deleted
    
    public func add(_ wind: Wind) {
        concurrentWindHistoryQueue.async(flags: .barrier) {
            let lastWind = self._windArray.last
            if lastWind != nil {
                if wind.timeStamp.timeIntervalSince(lastWind!.timeStamp) > 60 {
                    self._windArray.append(wind)
                }
            } else {
                self._windArray.append(wind)
            }

            //self._windArray.sort(by: { $0.timeStamp > $1.timeStamp} )
        }
    }
    
    public var history: [Wind] {
        var windArrayyCopy: [Wind]!
        concurrentWindHistoryQueue.sync {
            windArrayyCopy = _windArray
        }
        return windArrayyCopy
    }
    
    public func clear() {
        concurrentWindHistoryQueue.async(flags: .barrier) {
            self._windArray.removeAll()
        }
    }
}
