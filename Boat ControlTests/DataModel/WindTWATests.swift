//
//  WindTWATests.swift
//  Boat ControlTests
//
//  Created by Thomas Trageser on 01/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import XCTest
@testable import Boat_Control

class WindTWATests: XCTestCase {
    
    func testTWAWithReferenceRelativePort() {
        let wind = Wind(windAngle: 300.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWA, -60.00)
        XCTAssertEqual(wind.TWA, -85.61)
    }

    func testTWAWithReferenceRelativeStarboard() {
        let wind = Wind(windAngle: 60.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWA, 60.00)
        XCTAssertEqual(wind.TWA, 88.05)
    }
    
    func testTWAWithReferenceRelativeNoCurrentPort() {
        let wind = Wind(windAngle: 300.0, windSpeed: 8.0, reference: "R", cog: 70.0, sog: 7.50, hdg: 70.0)
        
        XCTAssertEqual(wind.TWA, -116.80)
    }

    func testTWAWithReferenceRelativeNoCurrentStarboard() {
        let wind = Wind(windAngle: 60.0, windSpeed: 8.0, reference: "R", cog: 70.0, sog: 7.50, hdg: 70.0)
        
        XCTAssertEqual(wind.TWA, 116.8)
    }
    
    func testRoundToHalf() {
        let denominator = 20.0
        var value = 0.06
        var roundedValue = round(value*denominator)/denominator
        
        XCTAssertEqual(roundedValue, 0.05)
        
        value = 0.12
        roundedValue = round(value*denominator)/denominator

        XCTAssertEqual(roundedValue, 0.10)

    }

}
