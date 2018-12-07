//
//  FloatExtensions.swift
//  Boat Control
//
//  Created by Thomas Trageser on 15/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import UIKit


extension Float {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * CGFloat(Double.pi) / 180.0
    }
}
