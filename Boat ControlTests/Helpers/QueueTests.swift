//
//  QueueTests.swift
//  Boat ControlTests
//
//  Created by Thomas Trageser on 24/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import XCTest
@testable import Boat_Control

class QueueTests: XCTestCase {
    
    func testAdd1ToQueue() {
        let sut = Queue<String>()
        sut.enqueue("1")
    }
    
    func testAddSeveralToQueue() {
        let sut = Queue<String>()
        XCTAssert(sut.isEmpty())
        sut.enqueue("1")
        sut.enqueue("1")
        XCTAssertFalse(sut.isEmpty())
        sut.enqueue("1")
        sut.enqueue("1")
        sut.enqueue("1")
    }
    
    func testRemoveOne() {
        let sut = Queue<String>()
        sut.enqueue("1")
        sut.enqueue("")
        sut.enqueue("")
        sut.enqueue("")
        
        let theFirstOne = sut.dequeue()
        
        XCTAssertNotNil(theFirstOne)
        XCTAssertEqual(theFirstOne!, "1")
    }
    
    func testRemoveAll() {
        let sut = Queue<String>()
        sut.enqueue("1")
        sut.enqueue("2")
        sut.enqueue("3")
        sut.enqueue("4")
        
        XCTAssertEqual(sut.dequeue()!, "1")
        XCTAssertEqual(sut.dequeue()!, "2")
        XCTAssertEqual(sut.dequeue()!, "3")
        XCTAssertEqual(sut.dequeue()!, "4")
        XCTAssert(sut.isEmpty())
        XCTAssertNil(sut.dequeue())
        XCTAssertNil(sut.dequeue())
        XCTAssert(sut.isEmpty())
    }
}
