//
//  WindAWSTests.swift
//  Boat ControlTests
//
//  Created by Thomas Trageser on 01/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import XCTest
@testable import Boat_Control

class WindAWSTests: XCTestCase {
    
    func testAWS() {
        let wind = Wind(windAngle: 300.0, windSpeed: 8.0, reference: "R", cog: 34.0, sog: 4.54, hdg: 70.0)
        
        XCTAssertEqual(wind.AWS, 8.0)
    }
}
