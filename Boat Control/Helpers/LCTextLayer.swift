//
//  LCTextLayer.swift
//  Boat Control
//
//  Created by Thomas Trageser on 18/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit


class LCTextLayer: CATextLayer {
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(layer: aDecoder)
    }
    
    override func draw(in ctx: CGContext) {
    
        let height = self.bounds.size.height
        let width = self.bounds.size.width
        let fontSize = self.fontSize
        let fontAttributes = [
            NSAttributedString.Key.font: self.font as! UIFont
        ]
        let textSize = ((self.string ?? "") as! NSString).size(withAttributes: fontAttributes)
        
        let yDiff = (height-fontSize)/2 - fontSize/10
        let xDiff = (width - textSize.width)/2 - fontSize/20
        
        ctx.saveGState()
        ctx.translateBy(x: xDiff, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
    
}
