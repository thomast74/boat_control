//
//  Navigation.swift
//  Boat Control
//
//  Created by Thomas Trageser on 03/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation

public class Navigation {
    
    public var speedThroughWater: Double
    public var speedOverGround: Double
    public var headingMagnetic: Double
    public var headingTrue: Double
    public var courseOverGroundMagnetic: Double
    public var courseOverGroundTrue: Double
    public var currentSpeed: Double
    public var currentDirection: Double
    public var latitude: Double
    public var latitudeDirection: String
    public var longitude: Double
    public var longitudeDirection: String
    public var gpsTimeStamp: Date
    public var baromericPressure: Double
    public var depth: Double
    public var timeStamp: Date
    
    public init(speedThroughWater: Double, speedOverGround: Double, headingMagnetic: Double, headingTrue: Double, courseOverGroundTrue: Double, courseOverGroundMagnetic: Double, latitude: Double, latitudeDirection: String, longitude: Double, longitudeDirection: String, gpsTimeStamp: Date) {
        self.speedThroughWater = speedThroughWater
        self.speedOverGround = speedOverGround
        self.headingMagnetic = headingMagnetic
        self.headingTrue = headingTrue
        self.courseOverGroundTrue = courseOverGroundTrue
        self.courseOverGroundMagnetic = courseOverGroundMagnetic
        self.currentSpeed = 0.0
        self.currentDirection = 0.0
        self.latitude = latitude
        self.latitudeDirection = latitudeDirection
        self.longitude = longitude
        self.longitudeDirection = longitudeDirection
        self.gpsTimeStamp = gpsTimeStamp
        self.baromericPressure = 0.0
        self.depth = 0.0
        self.timeStamp = Date()
    }
    
    public var hoursSince: Double {
        return (timeStamp.timeIntervalSinceNow / 60 / 60 * (-1)).rounded(toPlaces: 3)
    }
    
    public func clone() -> Navigation {
        let navigation = Navigation(speedThroughWater: speedThroughWater, speedOverGround: speedOverGround, headingMagnetic: headingMagnetic, headingTrue: headingTrue, courseOverGroundTrue: courseOverGroundTrue, courseOverGroundMagnetic: courseOverGroundMagnetic, latitude: latitude, latitudeDirection: latitudeDirection, longitude: longitude, longitudeDirection: longitudeDirection, gpsTimeStamp: gpsTimeStamp)
        
        navigation.baromericPressure = self.baromericPressure
        navigation.currentSpeed = self.currentSpeed
        navigation.currentDirection = self.currentDirection
        navigation.depth = self.depth
        navigation.timeStamp = self.timeStamp
        
        return navigation
    }
    
}

public struct NavigationAggregate {
    public var timeStamp: Date
    public var COG: Double
    public var HDG: Double
    public var avgSOG: Double
    public var maxSOG: Double
    public var minSOG: Double
    public var BPR: Double
    
    public var hoursSince: Double {
        return (timeStamp.timeIntervalSinceNow / 60 / 60 * (-1)).rounded(toPlaces: 2) * (-1)
    }
}
