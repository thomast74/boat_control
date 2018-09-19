//
//  CurrentTests.swift
//  Boat ControlTests
//
//  Created by Thomas Trageser on 18/09/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


import Foundation
import XCTest
@testable import Boat_Control

class CurrentTests: XCTestCase {

    func testGetAlpha_1() {
        let heading: Double = 287.0
        let courseOverGround: Double = 290.0
        
        let (alpha, sign) = Current.getAlpha(heading, courseOverGround)
        
        XCTAssertEqual(alpha, 3.0)
        XCTAssertEqual(sign, 1.0)
    }

    func testGetAlpha_2() {
        let heading: Double = 290.0
        let courseOverGround: Double = 287.0
        
        let (alpha, sign) = Current.getAlpha(heading, courseOverGround)
        
        XCTAssertEqual(alpha, 3.0)
        XCTAssertEqual(sign, -1.0)
    }

    func testGetAlpha_3() {
        let heading: Double = 358.0
        let courseOverGround: Double = 3.0
        
        let (alpha, sign) = Current.getAlpha(heading, courseOverGround)
        
        XCTAssertEqual(alpha, 5.0)
        XCTAssertEqual(sign, 1.0)
    }

    func testGetAlpha_4() {
        let heading: Double = 3.0
        let courseOverGround: Double = 358.0
        
        let (alpha, sign) = Current.getAlpha(heading, courseOverGround)
        
        XCTAssertEqual(alpha, 5.0)
        XCTAssertEqual(sign, -1.0)
    }
    
    func testSpeed_1() {
        let heading: Double = 220.0
        let courseOverGround: Double = 250.0
        let speedThroughWater: Double = 5.0
        let speedOverGround: Double = 6.0
        
        let (speed, direction) = Current.calculate(heading: heading, courseOverGround: courseOverGround, speedThroughWater: speedThroughWater, speedOverGround: speedOverGround)
        
        XCTAssertEqual(speed.rounded(toPlaces: 2), 3.01)
    }

    func testSpeed_2() {
        let heading: Double = 250.0
        let courseOverGround: Double = 220.0
        let speedThroughWater: Double = 5.0
        let speedOverGround: Double = 6.0
        
        let (speed, direction) = Current.calculate(heading: heading, courseOverGround: courseOverGround, speedThroughWater: speedThroughWater, speedOverGround: speedOverGround)
        
        XCTAssertEqual(speed.rounded(toPlaces: 2), 3.01)
    }

    func testDirection_1() {
        let heading: Double = 220.0
        let courseOverGround: Double = 250.0
        let speedThroughWater: Double = 5.0
        let speedOverGround: Double = 6.0

        let (speed, direction) = Current.calculate(heading: heading, courseOverGround: courseOverGround, speedThroughWater: speedThroughWater, speedOverGround: speedOverGround)
        
        XCTAssertEqual(direction.rounded(toPlaces: 2), 93.74)
    }

    func testDirection_2() {
        let heading: Double = 250.0
        let courseOverGround: Double = 220.0
        let speedThroughWater: Double = 5.0
        let speedOverGround: Double = 6.0
        
        let (speed, direction) = Current.calculate(heading: heading, courseOverGround: courseOverGround, speedThroughWater: speedThroughWater, speedOverGround: speedOverGround)
        
        XCTAssertEqual(direction.rounded(toPlaces: 2), -93.74)
    }

}
