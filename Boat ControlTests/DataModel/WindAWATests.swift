//
//  WindTests.swift
//  Boat ControlTests
//
//  Created by Thomas Trageser on 01/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import XCTest
@testable import Boat_Control

class WindAWATests: XCTestCase {

    func testAWAWithReferenceRelativePort() {
        let wind = Wind(windAngle: 300.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWA, -60.0)
    }

    func testAWAWithReferenceRelativeStarboard() {
        let wind = Wind(windAngle: 60.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWA, 60.0)
    }

    func testAWAWithReferenceRelativeDownwind() {
        let wind = Wind(windAngle: 180.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWA, 180.0)
    }

    func testAWAWithReferenceRelativeCloseReachPort() {
        let wind = Wind(windAngle: 181.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWA, -179.0)
    }

    func testAWAWithReferenceTruePort() {
        let wind = Wind(windAngle: 10.0, windSpeed: 8.0, reference: "T", cog: 34.0, sog: 4.54, hdg: 70.0)

        XCTAssertEqual(wind.AWA, -60.0)
    }

    func testAWAWithReferenceTrueStartboard() {
        let wind = Wind(windAngle: 130.0, windSpeed: 8.0, reference: "T", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWA, 60.0)
    }

    func testAWAWithReferenceTrueDownwind() {
        let wind = Wind(windAngle: 250.0, windSpeed: 8.0, reference: "T", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWA, 180)
    }

    func testAWAWithReferenceTrueCloseReachPort() {
        let wind = Wind(windAngle: 251.0, windSpeed: 8.0, reference: "T", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWA, -179)
    }

}
