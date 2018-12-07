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

    private var _consolidationTimer: Timer!
    private var _windArray: [Wind]
    private var _windAggregateArray: [WindAggregate]

    public init() {
        _windArray = []
        _windAggregateArray = []
        _consolidationTimer = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(self.consolidateLatestData), userInfo: nil, repeats: true)
    }
    
    // when a new wind object is generated it must be added to the history with a time stamp
    // everything that is older then x hours (from settings) will be deleted
    
    public func add(_ wind: Wind) {
        concurrentWindHistoryQueue.sync {
            let lastWind = self._windArray.last
            if lastWind != nil {
                if wind.timeStamp.timeIntervalSince(lastWind!.timeStamp) >= 5 {
                    self._windArray.append(wind)
                }
            } else {
                self._windArray.append(wind)
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
        var aggregate: [WindAggregate] = []
        
        concurrentWindHistoryQueue.sync {
            
            aggregate.append(contentsOf: self._windAggregateArray)

            let wind = self._windArray.first

            let(avgTWS, maxTWS, minTWS, avgTWD) = self.calcuateValues(windArray: self._windArray)

            aggregate.append(WindAggregate(timeStamp: wind?.timeStamp ?? Date(), avgTWS: avgTWS, maxTWS: maxTWS, minTWS: minTWS, TWD: avgTWD))
            aggregate.append(WindAggregate(timeStamp: Date(), avgTWS: avgTWS, maxTWS: maxTWS, minTWS: minTWS, TWD: avgTWD))
        }
        
        return aggregate
    }
    
    @objc public func consolidateLatestData() {
        concurrentWindHistoryQueue.async (flags: .barrier) {
            
            let(avgTWS, maxTWS, minTWS, avgTWD) = self.calcuateValues(windArray: self._windArray)
            let timeStamp = self._windArray.first?.timeStamp ?? Date()
            
            self._windAggregateArray.append(WindAggregate(timeStamp: timeStamp, avgTWS: avgTWS, maxTWS: maxTWS, minTWS: minTWS, TWD: avgTWD))
            
            self._windArray.removeAll()
        }
    }
    
    private func calcuateValues(windArray: [Wind]) -> (avgTWS: Double, maxTWS: Double, minTWS: Double, avgTWD: Double) {

        let count = Double(windArray.count)
        
        let avgTWS = (windArray.map{$0.TWS}.reduce(0, +) / count).rounded(toPlaces: 2)

        let maxTWS = (windArray.max { (w1, w2) -> Bool in
            return w1.TWS < w2.TWS
            }?.TWS ?? 0.0).rounded(toPlaces: 1)

        let minTWS = (windArray.min { (w1, w2) -> Bool in
            return w1.TWS < w2.TWS
            }?.TWS ?? 0.0).rounded(toPlaces: 1)

        let avgTWD = (windArray.map{$0.TWD}.reduce(0, +) / count).rounded(toPlaces: 0)

        return (avgTWS, maxTWS, minTWS, avgTWD)
    }
   
    public func clear() {
        concurrentWindHistoryQueue.async(flags: .barrier) {
            self._windArray.removeAll()
            self._windAggregateArray.removeAll()
        }
    }
}
