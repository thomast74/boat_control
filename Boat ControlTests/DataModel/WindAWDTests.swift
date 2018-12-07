//
//  WindAWDTests.swift
//  Boat ControlTests
//
//  Created by Thomas Trageser on 01/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import XCTest
@testable import Boat_Control

class WindAWDTests: XCTestCase {

    func testAWDWithReferenceRelativeIntoWind0AndWind() {
        let wind = Wind(windAngle: 0.0, windSpeed: 8.0, reference: "R", cog: 0.0, sog: 4.54, hdg: 0.0)
        
        XCTAssertEqual(wind.AWD, 360.0)
    }

    func testAWDWithReferenceRelativeIntoWind0AndNoWind() {
        let wind = Wind(windAngle: 0.0, windSpeed: 0.0, reference: "R", cog: 0.0, sog: 4.54, hdg: 0.0)
        
        XCTAssertEqual(wind.AWD, 0.0)
    }

    func testAWDWithReferenceRelativeIntoWind360WithWind() {
        let wind = Wind(windAngle: 360.0, windSpeed: 8.0, reference: "R", cog: 0.0, sog: 4.54, hdg: 0.0)
        
        XCTAssertEqual(wind.AWD, 360.0)
    }
    
    func testAWDWithReferenceRelativeIntoWind360WithNoWind() {
        let wind = Wind(windAngle: 360.0, windSpeed: 0.0, reference: "R", cog: 0.0, sog: 4.54, hdg: 0.0)
        
        XCTAssertEqual(wind.AWD, 0.0)
    }

    
    func testAWDWithReferenceRelativePort() {
        let wind = Wind(windAngle: 300.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWD, 10.0)
    }
    
    func testAWDWithReferenceRelativeStarboard() {
        let wind = Wind(windAngle: 60.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWD, 130.0)
    }

    func testAWDWithReferenceTruePort() {
        let wind = Wind(windAngle: 10.0, windSpeed: 8.0, reference: "T", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWD, 10.0)
    }

    func testAWDWithReferenceTrueStarboard() {
        let wind = Wind(windAngle: 130.0, windSpeed: 8.0, reference: "T", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWD, 130.0)
    }
    
    func testAWDWithCOGReferenceTruePort() {
        let wind = Wind(windAngle: 10.0, windSpeed: 8.0, reference: "T", cog: 34.0, sog: 4.54, hdg: -1)
        
        XCTAssertEqual(wind.AWD, 10.0)
    }
    
    func testAWDWithCOGReferenceTrueStarboard() {
        let wind = Wind(windAngle: 130.0, windSpeed: 8.0, reference: "T", cog: 34.0, sog: 4.54, hdg: -1)
        
        XCTAssertEqual(wind.AWD, 130.0)
    }
}
