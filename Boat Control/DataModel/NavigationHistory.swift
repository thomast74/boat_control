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
    
    private var _consolidationTimer: Timer!
    private var _navArray: [Navigation]
    private var _navAggregateArray: [NavigationAggregate]

    public init() {
        _navArray = []
        _navAggregateArray = []
        _consolidationTimer = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(self.consolidateLatestData), userInfo: nil, repeats: true)
    }
    
    public func add(_ navigation: Navigation)  {
        concurrentNavHistoryQueue.sync {
            let lastNav = self._navArray.last
            if lastNav != nil {
                if navigation.timeStamp.timeIntervalSince(lastNav!.timeStamp) >= 5 {
                    self._navArray.append(navigation)
                }
            } else {
                self._navArray.append(navigation)
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
        var aggregate: [NavigationAggregate] = []
        
        concurrentNavHistoryQueue.sync {
            
            aggregate.append(contentsOf: self._navAggregateArray)
            
            let navigation = self._navArray.first
            
            let (avgCOG, avgHDG, avgSOG, maxSOG, minSOG, avgBPR) = self.calcuateValues(navArray: self._navArray)
            
            aggregate.append(NavigationAggregate(timeStamp: navigation?.timeStamp ?? Date(), COG: avgCOG, HDG: avgHDG, avgSOG: avgSOG, maxSOG: maxSOG, minSOG: minSOG, BPR: avgBPR))
            aggregate.append(NavigationAggregate(timeStamp: Date(), COG: avgCOG, HDG: avgHDG, avgSOG: avgSOG, maxSOG: maxSOG, minSOG: minSOG, BPR: avgBPR))
        }
        
        return aggregate
    }

    @objc public func consolidateLatestData() {
        concurrentNavHistoryQueue.async (flags: .barrier) {
            
            let (avgCOG, avgHDG, avgSOG, maxSOG, minSOG, avgBPR) = self.calcuateValues(navArray: self._navArray)
            let timeStamp = self._navArray.first?.timeStamp ?? Date()
            
            self._navAggregateArray.append(NavigationAggregate(timeStamp: timeStamp, COG: avgCOG, HDG: avgHDG, avgSOG: avgSOG, maxSOG: maxSOG, minSOG: minSOG, BPR: avgBPR))
            
            self._navArray.removeAll()
        }
    }
    
    private func calcuateValues(navArray: [Navigation]) -> (avgCOG: Double, avgHDG: Double, avgSOG: Double, maxSOG: Double, minSOG: Double, avgBPR: Double) {
        
        let count = Double(navArray.count)

        let avgCOG = (navArray.map{$0.courseOverGroundMagnetic}.reduce(0, +) / count).rounded(toPlaces: 0)
        let avgHDG = (navArray.map{$0.headingMagnetic}.reduce(0, +) / count).rounded(toPlaces: 0)
        let avgSOG = (navArray.map{$0.speedOverGround}.reduce(0, +) / count).rounded(toPlaces: 1)
        
        let maxSOG = (navArray.max(by: { (nav1, nav2) -> Bool in
            return nav1.speedOverGround < nav2.speedOverGround
        })?.speedOverGround ?? 0.0).rounded(toPlaces: 1)

        let minSOG = (navArray.min(by: { (nav1, nav2) -> Bool in
            return nav1.speedOverGround < nav2.speedOverGround
        })?.speedOverGround ?? 0.0).rounded(toPlaces: 1)
        
        let avgBPR = (navArray.map{$0.baromericPressure}.reduce(0, +) / count).rounded(toPlaces: 2) * 10.0
        
        return (avgCOG, avgHDG, avgSOG, maxSOG, minSOG, avgBPR)
    }
    
    public func clear() {
        concurrentNavHistoryQueue.async(flags: .barrier) {
            self._navArray.removeAll()
            self._navAggregateArray.removeAll()
        }
    }

}
