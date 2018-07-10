//
//  Navigation.swift
//  Boat Control
//
//  Created by Thomas Trageser on 03/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

public class Navigation {
    
    public var speedOverWater: Double
    public var speedOverGround: Double
    public var headingMagnetic: Double
    public var headingTrue: Double
    public var courseOverGround: Double
    public var courseOverGroundMagnetic: Double
    public var latitude: Double
    public var latitudeDirection: String
    public var longitude: Double
    public var longitudeDirection: String
    public var gpsTimeStamp: Date
    public var baromericPressure: Double
    public var timeStamp: Date
    
    public init(speedOverWater: Double, speedOverGround: Double, headingMagnetic: Double, headingTrue: Double, courseOverGround: Double, courseOverGroundMagnetic: Double, latitude: Double, latitudeDirection: String, longitude: Double, longitudeDirection: String, gpsTimeStamp: Date) {
        self.speedOverWater = speedOverWater
        self.speedOverGround = speedOverGround
        self.headingMagnetic = headingMagnetic
        self.headingTrue = headingTrue
        self.courseOverGround = courseOverGround
        self.courseOverGroundMagnetic = courseOverGroundMagnetic
        self.latitude = latitude
        self.latitudeDirection = latitudeDirection
        self.longitude = longitude
        self.longitudeDirection = longitudeDirection
        self.gpsTimeStamp = gpsTimeStamp
        self.baromericPressure = 0.0
        self.timeStamp = Date()
    }
    
    public var hoursSince: Double {
        return (timeStamp.timeIntervalSinceNow / 60 / 60 * (-1)).rounded(toPlaces: 3)
    }
    
    public func clone() -> Navigation {
        let navigation = Navigation(speedOverWater: speedOverWater, speedOverGround: speedOverGround, headingMagnetic: headingMagnetic, headingTrue: headingTrue, courseOverGround: courseOverGround, courseOverGroundMagnetic: courseOverGroundMagnetic, latitude: latitude, latitudeDirection: latitudeDirection, longitude: longitude, longitudeDirection: longitudeDirection, gpsTimeStamp: gpsTimeStamp)
        
        navigation.baromericPressure = self.baromericPressure
        navigation.timeStamp = self.timeStamp
        
        return navigation
    }
    
}

public struct NavigationAggregate {
    public var hoursSince: Double
    public var COG: Double
    public var HDG: Double
    public var SOG: Double
    public var BPR: Double
}
