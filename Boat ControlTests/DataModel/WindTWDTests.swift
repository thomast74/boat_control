//
//  windTWDTests.swift
//  Boat ControlTests
//
//  Created by Thomas Trageser on 01/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import XCTest
@testable import Boat_Control

class WindTWDTests: XCTestCase {
    
    func testTWD0() {
        let wind = Wind(windAngle: 250.00, windSpeed: 10.0, reference: "R", cog: 45.0, sog: 5.0, hdg: 30.0)
        
        XCTAssertEqual(wind.AWS, 10.00)
        XCTAssertEqual(wind.AWD, 280.00)
        XCTAssertEqual(wind.TWS, 13.50)
        XCTAssertEqual(wind.TWD, 262.34)
    }

    func testTWD1() {
        let wind = Wind(windAngle: 90.00, windSpeed: 5.0, reference: "R", cog: 0.0, sog: 0.0, hdg: 0.0)
        
        XCTAssertEqual(wind.AWS, 5.00)
        XCTAssertEqual(wind.AWD, 90.00)
        XCTAssertEqual(wind.TWS, 5.0)
        XCTAssertEqual(wind.TWD, 90.00)
    }

    func testTWD2() {
        let wind = Wind(windAngle: 90.00, windSpeed: 5.0, reference: "R", cog: 0.0, sog: 0.0, hdg: 90.0)
        
        XCTAssertEqual(wind.AWS, 5.00)
        XCTAssertEqual(wind.AWD, 180.00)
        XCTAssertEqual(wind.TWS, 5.00)
        XCTAssertEqual(wind.TWD, 180.00)
    }

    func testTWD3() {
        let wind = Wind(windAngle: 360.0, windSpeed: 5.0, reference: "R", cog: 0.0, sog: 5.0, hdg: 0.0)
        
        XCTAssertEqual(wind.AWS, 5.00)
        XCTAssertEqual(wind.AWD, 360.00)
        XCTAssertEqual(wind.TWS, 0.00)
        XCTAssertEqual(wind.TWD, 0.00)
    }

    func testTWD4() {
        let wind = Wind(windAngle: 0.0, windSpeed: 0.0, reference: "R", cog: 0.0, sog: 5.0, hdg: 0.0)
        
        XCTAssertEqual(wind.AWS, 0.00)
        XCTAssertEqual(wind.AWD, 0.00)
        XCTAssertEqual(wind.TWS, 5.00)
        XCTAssertEqual(wind.TWD, 180.00)
    }

    func testTWD5() {
        let wind = Wind(windAngle: 180.0, windSpeed: 5.0, reference: "R", cog: 180.0, sog: 5.0, hdg: 180.0)
        
        XCTAssertEqual(wind.AWS, 5.00)
        XCTAssertEqual(wind.AWD, 360.00)
        XCTAssertEqual(wind.TWS, 10.00)
        XCTAssertEqual(wind.TWD, 360.00)
    }

    func testTWD6() {
        let wind = Wind(windAngle: 90.0, windSpeed: 5.0, reference: "R", cog: 90.0, sog: 5.0, hdg: 90.0)
        
        XCTAssertEqual(wind.AWS, 5.00)
        XCTAssertEqual(wind.AWD, 180.00)
        XCTAssertEqual(wind.TWS, 7.07)
        XCTAssertEqual(wind.TWD, 225.0)
    }

    func testTWD7() {
        let wind = Wind(windAngle: 135.0, windSpeed: 5.0, reference: "R", cog: 90.0, sog: 5.0, hdg: 45.0)
        
        XCTAssertEqual(wind.AWS, 5.00)
        XCTAssertEqual(wind.AWD, 180.00)
        XCTAssertEqual(wind.TWS, 7.07)
        XCTAssertEqual(wind.TWD, 225.0)
    }

    func testTWD8() {
        let wind = Wind(windAngle: 270.0, windSpeed: 5.0, reference: "R", cog: 225.0, sog: 5.0, hdg: 225.0)
        
        XCTAssertEqual(wind.AWS, 5.00)
        XCTAssertEqual(wind.AWD, 135.00)
        XCTAssertEqual(wind.TWS, 7.07)
        XCTAssertEqual(wind.TWD, 90.00)
    }

    func testTWD9() {
        let wind = Wind(windAngle: 90.0, windSpeed: 4.0, reference: "R", cog: 270.0, sog: 3.0, hdg: 270.0)
        
        XCTAssertEqual(wind.AWS, 4.00)
        XCTAssertEqual(wind.AWD, 360.00)
        XCTAssertEqual(wind.TWS, 5.0)
        XCTAssertEqual(wind.TWD, 36.87)
    }

    func testTWD10() {
        let wind = Wind(windAngle: 0.0, windSpeed: 0.0, reference: "R", cog: 0.0, sog: 0.0, hdg: 0.0)
        
        XCTAssertEqual(wind.AWS, 0.00)
        XCTAssertEqual(wind.AWD, 0.00)
        XCTAssertEqual(wind.TWS, 0.00)
        XCTAssertEqual(wind.TWD, 0.00)
    }

    
    func testTWDWithReferenceRelativeNoCurrentPort() {
        let wind = Wind(windAngle: 300.0, windSpeed: 8.0, reference: "R", cog: 70.0, sog: 7.50, hdg: 70.0)
        
        XCTAssertEqual(wind.TWD, 313.20)
    }

    func testTWDWithReferenceRelativeNoCurrentStarboard() {
        let wind = Wind(windAngle: 60.0, windSpeed: 8.0, reference: "R", cog: 70.0, sog: 7.50, hdg: 70.0)
        
        XCTAssertEqual(wind.TWD, 186.80)
    }

}
