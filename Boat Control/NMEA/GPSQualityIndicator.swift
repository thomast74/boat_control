//
//  GPSQualityIndicator.swift
//  Boat Control
//
//  Created by Thomas Trageser on 28/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


enum GPSQualityIndicator: Int {
    case FixNotAvailable = 0
    case GPSFix = 1
    case DifferentialGPSFix = 2
    case PPSFix = 3
    case RealTimeKinematic = 4
    case FloatRTK = 5
    case Estimated = 6
    case ManualnputMode = 7
    case SimulationMode = 8
}
