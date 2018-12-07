//
//  NumberView.swift
//  Boat Control
//
//  Created by Thomas Trageser on 04/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit


@IBDesignable class NumberView: UIView {

    @IBOutlet private weak var type: UILabel!
    @IBOutlet private weak var measurement: UILabel!
    @IBOutlet private weak var number: UILabel!
    
    private var _roundingPlaces: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let view = Bundle(for: NumberView.self).loadNibNamed("NumberView", owner: self, options: nil)![0] as! UIView
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBInspectable public var typeName: String {
        get {
            return self.type.text ?? ""
        }
        set(name) {
            self.type.text = name
        }
    }
    
    @IBInspectable public var measurementShortCut: String {
        get {
            return self.measurement.text ?? ""
        }
        set(shortCut) {
            self.measurement.text = shortCut
        }
    }

    @IBInspectable public var value: Double {
        get {
            return Double(self.number.text ?? "0.0")!
        }
        set(newValue) {
            let valueString = _roundingPlaces == 0
                ? String(Int(newValue))
                : String(newValue.rounded(toPlaces: _roundingPlaces))
            self.number.text = valueString
        }
    }
    
    @IBInspectable public var roundingPlaces: Int {
        get {
            return _roundingPlaces
        }
        set(newPlaces) {
            _roundingPlaces = newPlaces
        
            var value = Double(self.number.text ?? "0.0") ?? 0.0
            value = value.rounded(toPlaces: _roundingPlaces)
            self.number.text = String(value)
        }
    }

}
