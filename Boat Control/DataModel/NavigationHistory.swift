//
//  NavigationHistory.swift
//  Boat Control
//
//  Created by Thomas Trageser on 09/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

public class NavigationHistory {

    fileprivate let concurrentNavHistoryQueue = DispatchQueue(label: "com.arohanui.boat_control.NavHistory", attributes: .concurrent)
    
    private var _navHistoryInterval: Double = 60.0
    private var _navArray: [Navigation]
    
    public init() {
        _navArray = []
    }
    
    public func add(_ navigation: Navigation)  {
        concurrentNavHistoryQueue.sync {
            let lastNav = self._navArray.last
            if lastNav != nil {
                if navigation.timeStamp.timeIntervalSince(lastNav!.timeStamp) >= self._navHistoryInterval {
                    self._navArray.insert(navigation, at: 0)
                }
            } else {
                self._navArray.append(navigation)
            }
        }
    }
    
    public var count: Int {
        var navHistoryCount: Int = 0
        concurrentNavHistoryQueue.sync {
            navHistoryCount = _navArray.count
        }
        return navHistoryCount
    }

    
    public var navHistoryInterval: Double {
        get {
            var navHistoryIntervalCopy: Double = 60.0
            concurrentNavHistoryQueue.sync {
                navHistoryIntervalCopy = Double(self._navHistoryInterval)
            }
            return navHistoryIntervalCopy
        }
        set(newInterval) {
            concurrentNavHistoryQueue.sync {
                self._navHistoryInterval = newInterval
            }
        }
    }
    
    public var history: [Navigation] {
        var navArrayyCopy: [Navigation]!
        concurrentNavHistoryQueue.sync {
            navArrayyCopy = _navArray
        }
        return navArrayyCopy
    }
    
    public var historyAggregate: [NavigationAggregate] {
        var before: [NavigationAggregate] = []
        var aggregate: [NavigationAggregate] = []
        let denominator = 50.0

        concurrentNavHistoryQueue.sync {
            for nav in _navArray {
                let hoursSince = round(nav.hoursSince.rounded(toPlaces: 3)*denominator)/denominator

                before.append(NavigationAggregate(hoursSince: hoursSince, COG: nav.courseOverGroundMagnetic, HDG: nav.headingMagnetic, SOG: nav.speedOverGround, BPR: nav.baromericPressure))
            }
        }
        
        let allHoursSince = Set<Double>(before.map{$0.hoursSince}).sorted()
        for hourSince in allHoursSince {
            let filter = before.filter({$0.hoursSince == hourSince})
            let avgCOG = (filter.map{$0.COG}.reduce(0, +) / Double(filter.count)).rounded(toPlaces: 0)
            let avgHDG = (filter.map{$0.HDG}.reduce(0, +) / Double(filter.count)).rounded(toPlaces: 0)
            let avgSOG = (filter.map{$0.SOG}.reduce(0, +) / Double(filter.count)).rounded(toPlaces: 1)
            let avgBPR = (filter.map{$0.BPR}.reduce(0, +) / Double(filter.count)).rounded(toPlaces: 2) * 10.0
            aggregate.append(NavigationAggregate(hoursSince: hourSince, COG: avgCOG, HDG: avgHDG, SOG: avgSOG, BPR: avgBPR))
        }
        
        return aggregate
    }

    
    public func clear() {
        concurrentNavHistoryQueue.async(flags: .barrier) {
            self._navArray.removeAll()
        }
    }

}
