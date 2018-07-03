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
    public var latitude: Double
    public var latitudeDirection: String
    public var longitude: Double
    public var longitudeDirection: String
    public var gpsTimeStamp: Date
    
    public init(speedOverWater: Double, speedOverGround: Double, headingMagnetic: Double, headingTrue: Double, courseOverGround: Double, latitude: Double, latitudeDirection: String, longitude: Double, longitudeDirection: String, gpsTimeStamp: Date) {
        self.speedOverWater = speedOverWater
        self.speedOverGround = speedOverGround
        self.headingMagnetic = headingMagnetic
        self.headingTrue = headingTrue
        self.courseOverGround = courseOverGround
        self.latitude = latitude
        self.latitudeDirection = latitudeDirection
        self.longitude = longitude
        self.longitudeDirection = longitudeDirection
        self.gpsTimeStamp = gpsTimeStamp
    }
    
    public func clone() -> Navigation {
        return Navigation(speedOverWater: speedOverWater, speedOverGround: speedOverGround, headingMagnetic: headingMagnetic, headingTrue: headingTrue, courseOverGround: courseOverGround, latitude: latitude, latitudeDirection: latitudeDirection, longitude: longitude, longitudeDirection: longitudeDirection, gpsTimeStamp: gpsTimeStamp)
    }
    
}
