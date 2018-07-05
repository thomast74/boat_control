//
//  GeomagnetismTests.swift
//  Boat ControlTests
//
//  Created by Thomas Trageser on 05/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//
/*
 
 Usage
 
 // Create instance with only location and without altitude & date
 let gm:Geomagnetism = Geomagnetism(longitude: 123.45678, latitude: 76.54321)
 print("Declination: \(gm.declination)")
 
 // Create a date for calculation
 let dateComponents:DateComponents = DateComponents(year: 2017, month: 7, day: 1)
 var date:Date = Calendar.init(identifier: .gregorian).date(from: dateComponents)!
 // Update instance with altitude and date apart from location
 gm.calculate(longitude: 98.76543, latitude: 12.34567, altitude: 1234, date: date)
 print("Declination: \(gm.declination)")
 
 latitude + is N
 latitude - is S
 longitude + is E
 longitude - is W
 */


import Foundation
import XCTest
@testable import Boat_Control

class GeoMagneticFieldTests: XCTestCase {
    
    var july2018: Date?
    
    override func setUp() {
        super.setUp()

        let gregorianCalendar = Calendar(identifier: .gregorian)
        var march2018dateComponents = DateComponents()
        march2018dateComponents.year = 2018
        march2018dateComponents.month = 7
        march2018dateComponents.day = 1
        july2018 = gregorianCalendar.date(from: march2018dateComponents)!
    }

    func testDeclinationForCroatia() {
        let latitude = 43.123
        let longitude = 16.696
        let altitude = 0.0
        
        let magneticField = GeomagneticField(gdLatitudeDeg: latitude, gdLongitudeDeg: longitude, altitudeMeters: altitude, time: july2018!)
        
        XCTAssertEqual(magneticField.declination.rounded(toPlaces: 2), 3.93)
    }
    
    func testDeclinationForCenter() {
        let latitude = 0.0
        let longitude = 0.0
        let altitude = 0.0
        
        let magneticField = GeomagneticField(gdLatitudeDeg: latitude, gdLongitudeDeg: longitude, altitudeMeters: altitude, time: july2018!)
        
        XCTAssertEqual(magneticField.declination.rounded(toPlaces: 2), -5.02)
    }
    
    func testDeclinationForNorthWest() {
        let latitude = 43.0
        let longitude = -16.0
        let altitude = 0.0
        
        let magneticField = GeomagneticField(gdLatitudeDeg: latitude, gdLongitudeDeg: longitude, altitudeMeters: altitude, time: july2018!)
        
        XCTAssertEqual(magneticField.declination.rounded(toPlaces: 2), -5.05)
    }

}
