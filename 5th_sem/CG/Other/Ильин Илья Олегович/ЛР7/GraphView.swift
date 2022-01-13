//
//  UIGraphView.swift
//  CG1
//
//  Created by Илья Ильин on 21.09.2021.
//

import UIKit

import Foundation

@IBDesignable
class GraphView: UIView {
    
    var linePoints = [CGPoint]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var dotPoints = [CGPoint]() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    // Преобразует точку из системы координат где центр находится посередине View в обычную систему координат
    func getPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        let viewHeight = self.bounds.size.height
        let viewWidth = self.bounds.size.width
        return CGPoint(x: x + (viewWidth / 2),
                       y: (-1) * y + (viewHeight / 2))
    }
    
    func convertPoint(_ point: CGPoint) -> CGPoint {
        let viewHeight = self.bounds.size.height
        let viewWidth = self.bounds.size.width
        return CGPoint(x: point.x + (viewWidth / 2),
                       y: (-1) * point.y + (viewHeight / 2))
    }
    
    override func draw(_ rect: CGRect) {

        drawBorderLine()
        drawCircles()
        drawGraph()
        drawPoints()
        
    }
    
    func drawGraph() {
        let graphLine = UIBezierPath()

        var isFirst = true
        for point in linePoints {
            if isFirst {
                isFirst = false
                graphLine.move(to: convertPoint(point))
            }
            graphLine.addLine(to: convertPoint(point))
        }
        
        UIColor.blue.setStroke()
        graphLine.stroke()
    }
    
    func drawPoints() {
        UIColor.red.setStroke()
        for point in dotPoints {
            let pointPath = UIBezierPath(arcCenter: convertPoint(point), radius: 3.0, startAngle: 0.0, endAngle: CGFloat.pi*2, clockwise: true)
            pointPath.stroke()
        }
    }
    
    func drawBorderLine() {
        let viewHeight = self.bounds.size.height
        let viewWidth = self.bounds.size.width
        
        let borderLine = UIBezierPath()
        borderLine.move(to: CGPoint(x: 0, y: 0))
        borderLine.addLine(to: CGPoint(x: viewWidth, y: 0))
        borderLine.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        borderLine.addLine(to: CGPoint(x: 0, y: viewHeight))
        borderLine.addLine(to: CGPoint(x: 0, y: 0))
        
        UIColor.gray.setStroke()
        borderLine.stroke()
        
        let oX = UIBezierPath()
        oX.move(to: CGPoint(x: 0, y: viewHeight / 2))
        oX.addLine(to: CGPoint(x: viewWidth, y: viewHeight / 2))
        
        UIColor.black.setStroke()
        oX.stroke()
        
        let oY = UIBezierPath()
        oY.move(to: CGPoint(x: viewWidth / 2, y: viewHeight))
        oY.addLine(to: CGPoint(x: viewWidth / 2, y: 0))
        oY.stroke()
    }
    
    func drawCircles() {
        let viewHeight = self.bounds.size.height
        let viewWidth = self.bounds.size.width
        let centerPoint = getPoint(x: 0, y: 0)
        
        let maxCircleRadius = sqrt(viewHeight * viewHeight + viewWidth * viewWidth) / 2
        let circleStep = viewWidth / 12
        for radius in stride(from: circleStep, through: maxCircleRadius, by: circleStep) {
            let circlePath : UIBezierPath = UIBezierPath(
                arcCenter: centerPoint,
                radius: CGFloat(radius),
                startAngle: 0,
                endAngle: CGFloat(Double.pi * 2),
                clockwise: true
            )
            UIColor.lightGray.setStroke()
            circlePath.stroke()
        }
    }

}
