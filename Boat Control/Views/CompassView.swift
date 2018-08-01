//
//  CompassView.swift
//  Boat Control
//
//  Created by Thomas Trageser on 15/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit

@IBDesignable class CompassView: UIView {

    private var _view: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        _view = Bundle(for: CompassView.self).loadNibNamed("CompassView", owner: self, options: nil)![0] as? UIView
        _view!.frame = self.bounds
        _view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(_view!)
    }
    
    public var headingMagnetic: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var cogMagnetic: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var awa: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var twd: Double = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    private func degreeConvert(_ degree: Double) -> Double {
        var toConvert = degree
        if toConvert > 360 {
            toConvert -= 360
        }
        if toConvert < 0 {
            toConvert += 360
        }
        return toConvert
    }
    
    private var cogMagneticRelative: Double {
        return degreeConvert((cogMagnetic - headingMagnetic))
    }
    
    private var awaRelative: Double {
        return awa < 0
            ? (360.0 - awa) + 90
            : -awa + 90
    }
    
    private var isIntoWind: Bool {
        return awa <= -45.0 || awa >= 45.0 ? false : true
    }
    
    override func draw(_ rect: CGRect) {
        
        _view?.layer.sublayers?.removeAll()
        
        let viewCenter =  CGPoint(x: rect.width/2, y: rect.height/2)
        let maxRadius = (rect.width < rect.height ? rect.width : rect.height) / 2
        
        let outerGreyRingRadius = maxRadius * 0.9
        let outerGreyRingWidth = 25.0

        let compassRingRadius = maxRadius * 0.75
        let compassRingWidth = 25.0

        
        drawBoatShape(viewCenter, compassRingRadius)
        drawOuterGreyRing(rect, viewCenter, outerGreyRingRadius, outerGreyRingWidth)
        drawCompassRing(viewCenter, compassRingRadius, compassRingWidth)
        drawCOGMarker(viewCenter, compassRingRadius)
        drawAWAMarker(viewCenter, compassRingRadius, outerGreyRingRadius)
        drawTWDMarker(viewCenter, compassRingRadius, outerGreyRingRadius)
        //drawLaylines(viewCenter, compassRingRadius)
        drawHDGField(viewCenter, compassRingRadius)
    }
    
    private func drawBoatShape(_ viewCenter: CGPoint, _ compassRingRadius: CGFloat) {

        let compassRingOffset = CGFloat(50)
        let outsidePoint = CGFloat(100)
        let lowerYPoints = CGFloat(150)
        
        let shape = UIBezierPath()
        shape.move(to: CGPoint(x: viewCenter.x-outsidePoint, y: viewCenter.y+lowerYPoints))
        shape.addCurve(to: CGPoint(x: viewCenter.x, y: viewCenter.y-compassRingRadius+compassRingOffset),
                       controlPoint1: CGPoint(x: viewCenter.x-outsidePoint, y: viewCenter.y),
                       controlPoint2: CGPoint(x: viewCenter.x-outsidePoint, y: viewCenter.y-compassRingRadius+lowerYPoints))
        shape.addCurve(to: CGPoint(x: viewCenter.x+outsidePoint, y: viewCenter.y+lowerYPoints),
                       controlPoint1: CGPoint(x: viewCenter.x+outsidePoint, y: viewCenter.y-compassRingRadius+lowerYPoints),
                       controlPoint2: CGPoint(x: viewCenter.x+outsidePoint, y: viewCenter.y))
        shape.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = shape.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.darkGray.cgColor
        shapeLayer.lineWidth = CGFloat(5)
        _view?.layer.addSublayer(shapeLayer)
    }
    
    private func drawOuterGreyRing(_ rect: CGRect, _ viewCenter: CGPoint, _ outerGreyRingRadius: CGFloat, _ outerGreyRingWidth: Double) {
        let outerGreyRingPath = UIBezierPath(arcCenter: viewCenter, radius: outerGreyRingRadius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let outerGreyShapeLayer = CAShapeLayer()
        outerGreyShapeLayer.path = outerGreyRingPath.cgPath
        outerGreyShapeLayer.fillColor = UIColor.clear.cgColor
        outerGreyShapeLayer.strokeColor = UIColor.darkGray.cgColor
        outerGreyShapeLayer.lineWidth = CGFloat(outerGreyRingWidth)
        _view?.layer.addSublayer(outerGreyShapeLayer)
        
        // draw green and red area on outer ring
        let greenStartAngle: Float = 0.0 - 90
        let greenEndAngle: Float = 90.0 - 90
        let outerGreenRingPath = UIBezierPath(arcCenter: viewCenter, radius: outerGreyRingRadius, startAngle: greenStartAngle.degreesToRadians, endAngle: greenEndAngle.degreesToRadians, clockwise: true)
        
        let greenColour = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        let outerGreenShapeLayer = CAShapeLayer()
        outerGreenShapeLayer.path = outerGreenRingPath.cgPath
        outerGreenShapeLayer.fillColor = UIColor.clear.cgColor
        outerGreenShapeLayer.strokeColor = greenColour.cgColor
        outerGreenShapeLayer.lineWidth = CGFloat(outerGreyRingWidth)
        
        let greenGradientLayer = CAGradientLayer()
        greenGradientLayer.frame = rect
        greenGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        greenGradientLayer.endPoint = CGPoint(x: 0.5, y: 0.30)
        greenGradientLayer.colors = [greenColour.cgColor, UIColor.clear.cgColor]
        greenGradientLayer.mask = outerGreenShapeLayer
        _view?.layer.addSublayer(greenGradientLayer)
        
        
        let redStartAngle: Float = 0.0 - 90
        let redEndAngle: Float = 270.0 - 90
        let outerRedRingPath = UIBezierPath(arcCenter: viewCenter, radius: outerGreyRingRadius, startAngle: redStartAngle.degreesToRadians, endAngle: redEndAngle.degreesToRadians, clockwise: false)
        
        let outerRedShapeLayer = CAShapeLayer()
        outerRedShapeLayer.path = outerRedRingPath.cgPath
        outerRedShapeLayer.fillColor = UIColor.clear.cgColor
        outerRedShapeLayer.strokeColor = UIColor.red.cgColor
        outerRedShapeLayer.lineWidth = CGFloat(outerGreyRingWidth)
        
        let redGradientLayer = CAGradientLayer()
        redGradientLayer.frame = CGRect(x: 0, y: 0, width: rect.width/2, height: rect.height)
        redGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        redGradientLayer.endPoint = CGPoint(x: 0.5, y: 0.30)
        redGradientLayer.colors = [UIColor.red.cgColor, UIColor.clear.cgColor]
        redGradientLayer.mask = outerRedShapeLayer
        _view?.layer.addSublayer(redGradientLayer)
        
        // add 10 degree dots
        for i in stride(from: 10.0, to: 360.0, by: 10.0) {
            if i.truncatingRemainder(dividingBy: 30.0) != 0 {
                let theta = Double.pi * Double(i) / 180.0
                let x = Double(viewCenter.x) + Double(outerGreyRingRadius) * cos(theta)
                let y = Double(viewCenter.y) - Double(outerGreyRingRadius) * sin(theta)
                
                let dotPath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: 3, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
                let dotLayer = CAShapeLayer()
                dotLayer.path = dotPath.cgPath
                dotLayer.fillColor = UIColor.lightGray.cgColor
                _view?.layer.addSublayer(dotLayer)
            }
        }
        
        // add 30 degree lines
        for i in stride(from: 0.0, to: 360.0, by: 30.0) {
            let theta = Double.pi * Double(i) / 180.0
            let x1 = Double(viewCenter.x) + Double(outerGreyRingRadius+8) * cos(theta)
            let y1 = Double(viewCenter.y) - Double(outerGreyRingRadius+8) * sin(theta)
            let x2 = Double(viewCenter.x) + Double(outerGreyRingRadius-8) * cos(theta)
            let y2 = Double(viewCenter.y) - Double(outerGreyRingRadius-8) * sin(theta)
            
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: x1, y: y1))
            linePath.addLine(to: CGPoint(x: x2, y: y2))
            linePath.close()
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineWidth = 4.0
            lineLayer.strokeColor = UIColor.lightGray.cgColor
            _view?.layer.addSublayer(lineLayer)
        }
    }
    
    private func drawCompassRing(_ viewCenter: CGPoint, _ compassRingRadius: CGFloat, _ compassRingWidth: Double) {
        let compassRingPath = UIBezierPath(arcCenter: viewCenter, radius: compassRingRadius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let compassRingShapeLayer = CAShapeLayer()
        compassRingShapeLayer.path = compassRingPath.cgPath
        compassRingShapeLayer.fillColor = UIColor.clear.cgColor
        compassRingShapeLayer.strokeColor = UIColor.white.cgColor
        compassRingShapeLayer.lineWidth = CGFloat(compassRingWidth)
        _view?.layer.addSublayer(compassRingShapeLayer)
        
        
        // add 10 degree dots
        for i in stride(from: 10.0, to: 360.0, by: 10.0) {
            if i.truncatingRemainder(dividingBy: 30.0) != 0 {
                let angle = degreeConvert(i + 360 - headingMagnetic)
                let theta = Double.pi * Double(angle) / 180.0
                let x = Double(viewCenter.x) + Double(compassRingRadius) * sin(theta)
                let y = Double(viewCenter.y) - Double(compassRingRadius) * cos(theta)
                
                let dotPath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: 3, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
                let dotLayer = CAShapeLayer()
                dotLayer.path = dotPath.cgPath
                dotLayer.fillColor = UIColor.lightGray.cgColor
                _view?.layer.addSublayer(dotLayer)
            }
        }
        
        // add 30 degree number
        for i in stride(from: 0.0, to: 360.0, by: 30.0) {
            let angle = degreeConvert(i + 360 - headingMagnetic)
            let theta = Double.pi * Double(angle) / 180.0
            let x = Double(viewCenter.x) + (Double(compassRingRadius) * sin(theta))
            let y = Double(viewCenter.y) - Double(compassRingRadius) * cos(theta)
            
            let textLayer = LCTextLayer()
            textLayer.bounds = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 20.0)
            textLayer.position = CGPoint(x: x, y: y)
            textLayer.font = UIFont.systemFont(ofSize: 16)
            textLayer.fontSize = 16.0
            textLayer.foregroundColor = UIColor.black.cgColor
            textLayer.backgroundColor = UIColor.white.cgColor
            textLayer.string = "\(Int(i))"
            textLayer.transform = CATransform3DMakeRotation(CGFloat(theta), 0.0, 0.0, 1.0)
            
            _view?.layer.addSublayer(textLayer)
        }
    }
    
    private func drawCOGMarker(_ viewCenter: CGPoint, _ outerRadius: CGFloat) {
        
        let radius1 = outerRadius + 4
        let radius2 = outerRadius - 4

        var theta = Double.pi * Double(cogMagneticRelative) / 180.0
        let x1 = Double(viewCenter.x) + Double(radius1) * sin(theta)
        let y1 = Double(viewCenter.y) - Double(radius1) * cos(theta)
        theta = Double.pi * Double(cogMagneticRelative - 2.5) / 180.0
        let x2 = Double(viewCenter.x) + Double(radius1 + 35) * sin(theta)
        let y2 = Double(viewCenter.y) - Double(radius1 + 35) * cos(theta)
        theta = Double.pi * Double(cogMagneticRelative + 2.5) / 180.0
        let x3 = Double(viewCenter.x) + Double(radius1 + 35) * sin(theta)
        let y3 = Double(viewCenter.y) - Double(radius1 + 35) * cos(theta)
        
        theta = Double.pi * Double(cogMagneticRelative) / 180.0
        let x4 = Double(viewCenter.x) + Double(radius2) * sin(theta)
        let y4 = Double(viewCenter.y) - Double(radius2) * cos(theta)
        theta = Double.pi * Double(cogMagneticRelative - 3) / 180.0
        let x5 = Double(viewCenter.x) + Double(radius2 - 35) * sin(theta)
        let y5 = Double(viewCenter.y) - Double(radius2 - 35) * cos(theta)
        theta = Double.pi * Double(cogMagneticRelative + 3) / 180.0
        let x6 = Double(viewCenter.x) + Double(radius2 - 35) * sin(theta)
        let y6 = Double(viewCenter.y) - Double(radius2 - 35) * cos(theta)
        theta = Double.pi * Double(cogMagneticRelative - 3) / 180.0

        let orangeColour = UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1.0)
        
        var linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: x1, y: y1))
        linePath.addLine(to: CGPoint(x: x2, y: y2))
        linePath.addLine(to: CGPoint(x: x3, y: y3))
        linePath.close()
        
        var lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 2.0
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.fillColor = orangeColour.cgColor
        _view?.layer.addSublayer(lineLayer)
        
        linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: x4, y: y4))
        linePath.addLine(to: CGPoint(x: x5, y: y5))
        linePath.addLine(to: CGPoint(x: x6, y: y6))
        linePath.close()
        
        lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 2.0
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.fillColor = orangeColour.cgColor
        _view?.layer.addSublayer(lineLayer)
    }
    
    private func drawHDGField(_ viewCenter: CGPoint, _ compassRadius: CGFloat) {

        let text = "\(headingMagnetic < 100 ? " " : "")\(headingMagnetic < 10 ? " " : "")\(Int(headingMagnetic))"
        
        let textLayer = LCTextLayer()
        textLayer.bounds = CGRect(x: 0.0, y: 0.0, width: 65.0, height: 40.0)
        textLayer.position = CGPoint(x: viewCenter.x , y: (viewCenter.y - compassRadius))
        textLayer.font = UIFont.systemFont(ofSize: 24)
        textLayer.fontSize = 24.0
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.string = text
        textLayer.backgroundColor = UIColor.white.cgColor
        textLayer.cornerRadius = 5.0
        textLayer.borderWidth = 3.0
        textLayer.borderColor = UIColor.black.cgColor
        
        _view?.layer.addSublayer(textLayer)
    }
    
    private func drawAWAMarker(_ viewCenter: CGPoint, _ compassRadius: CGFloat, _ outerRadius: CGFloat) {
        
        let radius = outerRadius + 4
        
        var theta = Double.pi * Double(awaRelative) / 180.0
        let x1 = Double(viewCenter.x) + Double(compassRadius-10) * cos(theta)
        let y1 = Double(viewCenter.y) - Double(compassRadius-10) * sin(theta)
        theta = Double.pi * Double(awaRelative - 4) / 180.0
        let x2 = Double(viewCenter.x) + Double(radius + 10) * cos(theta)
        let y2 = Double(viewCenter.y) - Double(radius + 10) * sin(theta)
        theta = Double.pi * Double(awaRelative + 4) / 180.0
        let x3 = Double(viewCenter.x) + Double(radius + 10) * cos(theta)
        let y3 = Double(viewCenter.y) - Double(radius + 10) * sin(theta)
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: x1, y: y1))
        linePath.addLine(to: CGPoint(x: x2, y: y2))
        linePath.addLine(to: CGPoint(x: x3, y: y3))
        linePath.close()
        
        let lightBlue = UIColor(red: 0.6, green: 0.6, blue: 1.0, alpha: 1.0)
        let lightGreen = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        let darkBlue = UIColor(red: 0.36, green: 0.36, blue: 0.6, alpha: 1.0)
        let darkGreen = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)

        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 2.0
        lineLayer.strokeColor = isIntoWind ? darkBlue.cgColor : darkGreen.cgColor
        lineLayer.fillColor = isIntoWind ? lightBlue.cgColor : lightGreen.cgColor
        _view?.layer.addSublayer(lineLayer)
    }

    private func drawTWDMarker(_ viewCenter: CGPoint, _ compassRadius: CGFloat, _ outerRadius: CGFloat) {
        
        let radius = outerRadius + 4
        let angle = degreeConvert(twd + 360 - headingMagnetic)

        var theta = Double.pi * Double(angle) / 180.0
        let x1 = Double(viewCenter.x) + Double(compassRadius + 13) * sin(theta)
        let y1 = Double(viewCenter.y) - Double(compassRadius + 13) * cos(theta)
        theta = Double.pi * Double(angle - 2) / 180.0
        let x2 = Double(viewCenter.x) + Double(radius + 10) * sin(theta)
        let y2 = Double(viewCenter.y) - Double(radius + 10) * cos(theta)
        theta = Double.pi * Double(angle + 2) / 180.0
        let x3 = Double(viewCenter.x) + Double(radius + 10) * sin(theta)
        let y3 = Double(viewCenter.y) - Double(radius + 10) * cos(theta)
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: x1, y: y1))
        linePath.addLine(to: CGPoint(x: x2, y: y2))
        linePath.addLine(to: CGPoint(x: x3, y: y3))
        linePath.close()
        
        let lightBlue = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let darkBlue = UIColor(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0)

        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 2.0
        lineLayer.strokeColor = darkBlue.cgColor
        lineLayer.fillColor = lightBlue.cgColor
        _view?.layer.addSublayer(lineLayer)
    }
    
    private func drawLaylines(_ viewCenter: CGPoint, _ compassRadius: CGFloat) {
        // TODO: this needs to be adjusted to reflect current and heading differences to cog, hdg, sog, awa and twd
        let portLaylineDegree = degreeConvert((twd-45.0))
        let starboardLaylineDegree = degreeConvert((twd+45.0))
        
        var theta = Double.pi * Double(portLaylineDegree) / 180.0
        var x = Double(viewCenter.x) + Double(compassRadius - 15) * sin(theta)
        var y = Double(viewCenter.y) - Double(compassRadius - 15) * cos(theta)

        var linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
        linePath.addLine(to: CGPoint(x: x, y: y))
        linePath.close()

        var lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 4.0
        lineLayer.strokeColor = UIColor.red.cgColor
        lineLayer.fillColor = UIColor.red.cgColor
        _view?.layer.addSublayer(lineLayer)

        theta = Double.pi * Double(starboardLaylineDegree) / 180.0
        x = Double(viewCenter.x) + Double(compassRadius - 15) * sin(theta)
        y = Double(viewCenter.y) - Double(compassRadius - 15) * cos(theta)
        
        linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
        linePath.addLine(to: CGPoint(x: x, y: y))
        linePath.close()
        
        lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 4.0
        lineLayer.strokeColor = UIColor.green.cgColor
        lineLayer.fillColor = UIColor.green.cgColor
        _view?.layer.addSublayer(lineLayer)
    }

}
