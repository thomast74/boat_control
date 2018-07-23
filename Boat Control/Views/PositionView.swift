//
//  PositionView.swift
//  Boat Control
//
//  Created by Thomas Trageser on 14/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit

@IBDesignable class PositionView: UIView {
    
    @IBOutlet private weak var latitude: UILabel!
    @IBOutlet private weak var longitude: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let view = Bundle(for: PositionView.self).loadNibNamed("PositionView", owner: self, options: nil)![0] as! UIView
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    public func set(latitude: Double, direction: String) {
        let degree = Int(latitude / 100)
        let minutes = Int(latitude - (Double(degree)*100.0))
        let decimal = Int((latitude - Double(Int(latitude))) * 1000)
        
        self.latitude.text = "\(degree < 10 ? "0" : "")\(degree)° \(minutes < 10 ? "0" : "")\(minutes).\(decimal < 100 ? "0" : "")\(decimal < 10 ? "0" : "")\(decimal)' \(direction)"
        //print("\(latitude) => \(self.latitude.text) => \(degree);\(minutes);\(decimal)")
    }

    public func set(longitude: Double, direction: String) {
        let degree = Int(longitude / 100)
        let minutes = Int(longitude - (Double(degree)*100.0))
        let decimal = Int((longitude - Double(Int(longitude))) * 1000)
        
        
        self.longitude.text = "\(degree < 100 ? "0" : "")\(degree < 10 ? "0" : "")\(degree)° \(minutes < 10 ? "0" : "")\(minutes).\(decimal < 100 ? "0" : "")\(decimal < 10 ? "0" : "")\(decimal)' \(direction)"

        //print("\(longitude) => \(self.longitude.text) => \(degree);\(minutes);\(decimal)")
    }

}
