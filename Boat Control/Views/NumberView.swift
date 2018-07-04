//
//  NumberView.swift
//  Boat Control
//
//  Created by Thomas Trageser on 04/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit

class NumberView: UIView {

    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var measurement: UILabel!
    @IBOutlet weak var number: UILabel!
    
    
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
}
