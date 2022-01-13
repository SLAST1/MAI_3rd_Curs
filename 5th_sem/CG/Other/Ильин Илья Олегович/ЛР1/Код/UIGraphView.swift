//
//  UIGraphView.swift
//  CG1
//
//  Created by Илья Ильин on 21.09.2021.
//

/*
 - Мб здеь хранить только массив точек, а высчитывать их  в контроллере???
 */

import UIKit

@IBDesignable
class UIGraphView: UIView {
    
    var points = [CGPoint]() {
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

        // Рамка по периметру
        do {
            let viewHeight = self.bounds.size.height
            let viewWidth = self.bounds.size.width
            
            let borderLine = UIBezierPath()
            borderLine.move(to: CGPoint(x: 0, y: 0))
            borderLine.addLine(to: CGPoint(x: viewWidth, y: 0))
            borderLine.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
            borderLine.addLine(to: CGPoint(x: 0, y: viewHeight))
            borderLine.addLine(to: CGPoint(x: 0, y: 0))
            
            UIColor.lightGray.setStroke()
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
        
        let graphLine = UIBezierPath()

        var isFirst = true
        for point in points {
            if isFirst {
                isFirst = false
                graphLine.move(to: convertPoint(point))
            }
            graphLine.addLine(to: convertPoint(point))
        }
        
        UIColor.blue.setStroke()
        graphLine.stroke()
    }

}
