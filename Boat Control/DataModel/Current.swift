//
//  Current.swift
//  Boat Control
//
//  Created by Thomas Trageser on 18/09/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation


class Current {
    
    public static func calculate(heading: Double, courseOverGround: Double, speedThroughWater: Double, speedOverGround: Double) -> (speed: Double, direction: Double) {

        let (alpha, sign) = getAlpha(heading, courseOverGround)
        let alphaRadiant = alpha * (Double.pi/180)
        
        let speed = sqrt(pow(speedThroughWater, 2) + pow(speedOverGround, 2) - (2 * speedOverGround * speedThroughWater * cos(alphaRadiant)))
        
        var direction = acos((pow(speed, 2) + pow(speedThroughWater, 2) - pow(speedOverGround, 2)) / (2 * speed * speedThroughWater)) / (Double.pi/180)
        direction *= sign
        
        return (speed, direction)
    }
    
    public static func getAlpha(_ heading: Double, _ courseOverGround: Double) -> (alpha: Double, sign: Double) {
        let difference = courseOverGround - heading
        let phi = abs(difference).truncatingRemainder(dividingBy: 360.0)
        let alpha = phi > 180 ? 360 - phi : phi
        let sign = (difference >= 0 && difference <= 180) || (difference <= -180 && difference >= -360) ? 1.0 : -1.0

        return (alpha, sign)
    }
 
}
