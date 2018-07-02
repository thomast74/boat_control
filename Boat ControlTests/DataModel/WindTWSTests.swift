//
//  WindTWSTests.swift
//  Boat ControlTests
//
//  Created by Thomas Trageser on 01/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import XCTest
@testable import Boat_Control

class WindTWSTests: XCTestCase {
    
    func testTWSWithReferenceRelativePort() {
        let wind = Wind(windAngle: 300.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.TWS, 4.27)
    }

    func testTWSWithReferenceRelativeStarboard() {
        let wind = Wind(windAngle: 180.0, windSpeed: 8.0, reference: "R", cog: 0.0, sog: 4.0, hdg: 0.0)
        
        XCTAssertEqual(wind.TWS, 12.0)
    }

    func testTWSWithReferenceRelativeNoCurrentPort() {
        let wind = Wind(windAngle: 300.0, windSpeed: 8.0, reference: "R", cog: 70.0, sog: 7.50, hdg: 70.0)
        
        XCTAssertEqual(wind.TWS, 7.76)
    }

    func testTWSWithReferenceRelativeNoCurrentStartboard() {
        let wind = Wind(windAngle: 60.0, windSpeed: 8.0, reference: "R", cog: 70.0, sog: 7.50, hdg: 70.0)
        
        XCTAssertEqual(wind.TWS, 7.76)
    }

}
