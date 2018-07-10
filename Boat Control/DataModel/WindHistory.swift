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

    private var _windHistoryInterval: Double = 60.0
    private var _windArray: [Wind]

    public init() {
        _windArray = []
    }
    
    // when a new wind object is generated it must be added to the history with a time stamp
    // everything that is older then x hours (from settings) will be deleted
    
    public func add(_ wind: Wind) {
        concurrentWindHistoryQueue.sync {
            let lastWind = self._windArray.last
            if lastWind != nil {
                if wind.timeStamp.timeIntervalSince(lastWind!.timeStamp) >= self._windHistoryInterval {
                    self._windArray.append(wind)
                }
            } else {
                self._windArray.append(wind)
            }
        }
    }
    
    public var count: Int {
        var windHistoryCount: Int = 0
        concurrentWindHistoryQueue.sync {
            windHistoryCount = _windArray.count
        }
        return windHistoryCount
    }
    
    public var windHistoryInterval: Double {
        get {
            var windHistoryIntervalCopy: Double = 60.0
            concurrentWindHistoryQueue.sync {
                windHistoryIntervalCopy = Double(self._windHistoryInterval)
            }
            return windHistoryIntervalCopy
        }
        set(newInterval) {
            concurrentWindHistoryQueue.sync {
                self._windHistoryInterval = newInterval
            }
        }
    }
    
    public var history: [Wind] {
        var windArrayCopy: [Wind]!
        concurrentWindHistoryQueue.sync {
            windArrayCopy = _windArray
        }
        return windArrayCopy
    }

    public var historyAggregate: [WindAggregate] {
        var before: [WindAggregate] = []
        var aggregate: [WindAggregate] = []
        let denominator = 50.0
        
        concurrentWindHistoryQueue.sync {
            for wind in _windArray {
                let hoursSince = round(wind.hoursSince.rounded(toPlaces: 3)*denominator)/denominator
                
                before.append(WindAggregate(hoursSince: hoursSince, TWS: wind.TWS, maxTWS: 0.0, TWD: wind.TWD))
            }
        }
        
        let allHoursSince = Set<Double>(before.map{$0.hoursSince})
        for hourSince in allHoursSince {
            let filter = before.filter({$0.hoursSince == hourSince})
            let avgTWS = filter.map{$0.TWS}.reduce(0, +) / Double(filter.count)
            let maxTWS = filter.max { (w1, w2) -> Bool in
                return w1.TWS < w2.TWS
            }?.TWS ?? 0.0
            let avgTWD = filter.map{$0.TWD}.reduce(0, +) / Double(filter.count)
            aggregate.append(WindAggregate(hoursSince: hourSince, TWS: avgTWS.rounded(toPlaces: 1), maxTWS: maxTWS.rounded(toPlaces: 1), TWD: avgTWD.rounded(toPlaces: 0)))
        }
        
        return aggregate
    }
   
    public func clear() {
        concurrentWindHistoryQueue.async(flags: .barrier) {
            self._windArray.removeAll()
        }
    }
}
