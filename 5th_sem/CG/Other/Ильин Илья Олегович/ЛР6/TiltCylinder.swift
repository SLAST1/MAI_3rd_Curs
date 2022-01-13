//
//  TiltCylinder.swift
//  CG3-4
//
//  Created by Илья Ильин on 01.11.2021.
//

import Foundation
import simd

class TiltCylinder: Node {
    
    private var a: Float                 /// semi-major axis
    private var b: Float                 /// semi-minor axis
    private var height: Float = 2
    private var upperAngle: Double = 30
    
    init(name: String, material: Material, a: Float, b: Float, delta: Float) {
        self.a = a
        self.b = b
        
        super.init(name: name, material: material, approximation: delta)
    }
    
    // MARK: - Counting points
    
    override func countVertices() { // on parallel threads?
        var resultVertices = [Vertex]()
        var resultIndices = [[UInt16]]()
        var verticesArray = [Vertex]()
        var indicesArray = [UInt16]()
        
        let ellipsePoints = countEllipsePoints(a: a, b: b, delta: approximation)
        
        var shift: UInt16 = 0
        /// bottom ellipse
        let bottomEllipseMatrix = makeRotationMatrixAroundX(degrees: 90)
        let bottomEllipse = ellipsePoints.map { bottomEllipseMatrix * $0 }

        (verticesArray, indicesArray) = countEllipseVertices(ellipsePoints: reverseEllipsePoints(ellipsePoints: bottomEllipse))
        resultVertices += verticesArray
        resultIndices.append(indicesArray.map{ $0 + shift })
        shift += UInt16(verticesArray.count)
        
        /// upper ellipse
        let angleMeasurement = Measurement(value: upperAngle, unit: UnitAngle.degrees)
        let radians = Float(angleMeasurement.converted(to: .radians).value)
        
        let stretchX: Float = 1/cos(radians)
        let upperEllipseMatrix = makeTranslationMatrix(tx: 0, ty: height, tz: 0) * makeRotationMatrixAroundZ(degrees: upperAngle) * makeRotationMatrixAroundX(degrees: 90) * makeStretchMatrix(sx: stretchX, sy: 1, sz: 1)
        let upperEllipse = ellipsePoints.map { upperEllipseMatrix * $0 }

        (verticesArray, indicesArray) = countEllipseVertices(ellipsePoints: upperEllipse)
        resultVertices += verticesArray
        resultIndices.append(indicesArray.map{ $0 + shift })
        shift += UInt16(verticesArray.count)
        
        /// count side surface
        (verticesArray, indicesArray) = countSideSurfaceVertices(upperEllipse: upperEllipse, bottomEllipse: bottomEllipse)
        resultVertices += verticesArray
        resultIndices.append(indicesArray.map{ $0 + shift })
        
        self.vertices = resultVertices
        self.indices = resultIndices
    }
    
    private func reverseEllipsePoints(ellipsePoints: [simd_float4]) -> [simd_float4] {
        return ellipsePoints.isEmpty ? [] : [ellipsePoints.first!] + ellipsePoints.dropFirst().reversed()
    }
    
    private func countSideSurfaceVertices(upperEllipse: [simd_float4], bottomEllipse: [simd_float4]) -> ([Vertex], [UInt16]) {

        if upperEllipse.count < 3 || bottomEllipse.count < 3 || upperEllipse.count != bottomEllipse.count {
            return ([], [])
        }
        
        let circledUpperEllipse = upperEllipse.dropFirst() + [upperEllipse[1]]
        let circledBottomEllipse = bottomEllipse.dropFirst() + [bottomEllipse[1]]
        var verticesArray = [Vertex]()
        var indicesArray  = [UInt16]()

        var prevPoints: (simd_float4, simd_float4)? = nil
        for (upPoint, bottomPoint) in zip(circledUpperEllipse, circledBottomEllipse) {
            if let prevPoints = prevPoints {
                
                let prevUpPoint = prevPoints.0
                let prevBottomPoint = prevPoints.1

                let normal1 = countNormal(v1: prevBottomPoint, v2: prevUpPoint, v3: upPoint)
                let normal2 = countNormal(v1: prevBottomPoint, v2: upPoint, v3: bottomPoint)

                let v11 = Vertex(point: prevBottomPoint, normal: normal1)
                let v13 = Vertex(point: prevUpPoint, normal: normal1)

                let v23 = Vertex(point: upPoint, normal: normal2)
                let v22 = Vertex(point: bottomPoint, normal: normal2)

                let shift = UInt16(verticesArray.count)
                verticesArray += [v11, v22, v23, v13]

                indicesArray += [shift, shift+2, shift+3]
                indicesArray += [shift, shift+1, shift+2]
                
                /// triangles layout
                /// [v11, v22, v13]
                /// [v11, v22, v23]
            }
            prevPoints = (upPoint, bottomPoint)
        }

        return (verticesArray, indicesArray)
    }
    
    private func countEllipseVertices(ellipsePoints: [simd_float4]) -> ([Vertex], [UInt16]) {
        var verticesArray = [Vertex]()
        var indicesArray = [UInt16]()
        
        if ellipsePoints.count >= 3 {
            let centerIdx = 0
            let normal = countNormal(v1: ellipsePoints[0], v2: ellipsePoints[1], v3: ellipsePoints[2])
            
            for (index, point) in ellipsePoints.enumerated() {
                if index != 0 && index - 1 != centerIdx {
                    /// as triangles
                    indicesArray.append(UInt16(centerIdx))
                    indicesArray.append(UInt16(index - 1))
                    indicesArray.append(UInt16(index))
                }
                
                verticesArray.append(Vertex(point: point, normal: normal))
            }
            
            indicesArray.append(UInt16(centerIdx))
            indicesArray.append(UInt16(ellipsePoints.count - 1))
            indicesArray.append(UInt16(1))
        }
        
        return (verticesArray, indicesArray)
    }
    
    /// Count Ellipse points, located in Oxy plane
    /// - Parameters:
    ///   - a: semi-major axis
    ///   - b: semi-minor axis
    ///   - delta: approximation accuracy
    /// - Returns: array of ellipse points, first point is center
    private func countEllipsePoints(a: Float, b: Float, delta: Float) -> [simd_float4] {
        let a2: Float = a * a
        let b2: Float = b * b
        var x: Float = 0
        var y: Float = b
        
        func f(x: Float, y: Float) -> Float {
            return b2*x*x + a2*y*y - a2*b2
        }
        
        var points = [simd_float4]()
        /// upper arc
        while (a2 * (y - delta/2)) > (b2 * (x+delta)) {
            let vertex = simd_float4(x: x, y: y, z: 0, w: 1)
            points.append(vertex)
            
            /// choose next point between (x + delta, y) and (x + delta, y - delta)
            if (f(x: x + delta, y: y - delta/2) >= 0) {
                y -= delta
            }
            x += delta
        }
        
        /// bottom arc
        while y >= 0 && x <= a {
            let vertex = simd_float4(x: x, y: y, z: 0, w: 1)
            points.append(vertex)
            
            /// choose between (x + delta, y - delta) and (x, y - delta)
            if (f(x: x + delta/2, y: y - delta) <= 0) {
                x += delta
            }
            y -= delta
        }
        if let prevVertex = points.last {
            let endVertex = simd_float4(x: a, y: 0, z: 0, w: 1)
            if endVertex != prevVertex {
                points.append(endVertex)
            }
        }
        
        /// plot other arcs using symmetry
        let arc2: [simd_float4]
        let arc3: [simd_float4]
        let arc4: [simd_float4]
        
        if points.count > 2 {
            arc2 = points[1..<points.count-1].map { (v) -> simd_float4 in
                var newV = v
                newV.x = v.x * -1
                return newV
            }.reversed()
        } else {
            arc2 = []
        }
        
        if points.count > 1 {
            arc3 = points[1...].map { (v) -> simd_float4 in
                var newV = v
                newV.x = v.x * -1
                newV.y = v.y * -1
                return newV
            }
            
            arc4 = points[0..<points.count-1].map { (v) -> simd_float4 in
                var newV = v
                newV.y = v.y * -1
                return newV
            }.reversed()
        } else {
            arc3 = []
            arc4 = []
        }
        
        points += arc4 + arc3 + arc2
        let center = simd_float4(x: 0, y: 0, z: 0, w: 1)

        return [center] + points
    }
}
