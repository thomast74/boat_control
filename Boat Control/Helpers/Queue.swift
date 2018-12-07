//
//  Queue.swift
//  Boat Control
//
//  Created by Thomas Trageser on 24/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

class _QueueItem<T> {
    let value: T!
    var next: _QueueItem?
    
    init(_ newValue: T?) {
        self.value = newValue
    }
}

public class Queue<T> {
    
    public typealias Element = T
    
    var _front: _QueueItem<Element>
    var _back: _QueueItem<Element>
    
    public init() {
        _back = _QueueItem(nil)
        _front = _back
    }
    
    public func enqueue(_ value: Element) {
        _back.next = _QueueItem(value)
        _back = _back.next!
    }
    
    public func dequeue() -> Element? {
        if let newhead = _front.next {
            _front = newhead
            return newhead.value
        } else {
            return nil
        }
    }
    
    public func isEmpty() -> Bool {
        return _front === _back
    }
}
