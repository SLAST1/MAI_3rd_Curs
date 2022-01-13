//
//  TiltCylinder.swift
//  CG3
//
//  Created by Илья Ильин on 17.10.2021.
//

import Foundation
import Metal
import simd
import UIKit

class TiltCylinder: Node {
    
    private var color: (Float, Float, Float) = (0.5, 0.5, 0.5)
    
    init(device: MTLDevice){
        
        let a: Float     = 2
        let b: Float     = 1
        let delta: Float = 0.01
        
        let ellipseVertices = TiltCylinder.countEllipseVertices(a: a, b: b, delta: delta)
        ellipseVertices.forEach { print("(\($0.x), \($0.y))") }
        
        /// bottom ellipse
        let bottomEllipseMatrix = makeRotationMatrixAroundX(degrees: 90)
        let bottomEllipse = ellipseVertices.map { bottomEllipseMatrix * $0 }
        let bottomCenter = bottomEllipseMatrix * simd_float4(x: 0, y: 0, z: 0, w: 1)
        
        /// upped ellipse
        let upperEllipseMatrix = makeTranslationMatrix(tx: 0, ty: 2, tz: 0) * makeRotationMatrixAroundZ(degrees: 30) * makeRotationMatrixAroundX(degrees: 90)
        let upperEllipse = ellipseVertices.map { upperEllipseMatrix * $0 }
        let upperCenter = upperEllipseMatrix * simd_float4(x: 0, y: 0, z: 0, w: 1)
        
        /// count mesh
        var verticesArray = [Vertex]()
        verticesArray += TiltCylinder.makeEllipseMesh(ellipseVectors: bottomEllipse.reversed(), center: bottomCenter, color: color)
        verticesArray += TiltCylinder.makeEllipseMesh(ellipseVectors: upperEllipse, center: upperCenter, color: color)
        verticesArray += TiltCylinder.makeSideSurfaceMesh(upperEllipse: upperEllipse.reversed(), bottomEllipse: bottomEllipse.reversed(), color: color)
        
        // debug log
        print("total \(verticesArray.count) vertices as \(verticesArray.count / 3) triangles")
        
        super.init(name: "Ellipse", vertices: verticesArray, device: device)
    }
    
    class func makeSideSurfaceMesh(upperEllipse: [simd_float4], bottomEllipse: [simd_float4], color: (Float, Float, Float)) -> [Vertex] {
        
        if upperEllipse.isEmpty || bottomEllipse.isEmpty {
            return []
        }
        
        let circledUpperEllipse = upperEllipse + [upperEllipse.first!]
        let circledBottomEllipse = bottomEllipse + [bottomEllipse.first!]
        var vertices = [Vertex]()
        
        var prevVectors: (simd_float4, simd_float4)? = nil
        for (upVector, bottomVector) in zip(circledUpperEllipse, circledBottomEllipse) {
            if let prevVectors = prevVectors {
                /// divide in 2 triangles
                let prevUpVector = prevVectors.0
                let prevBottomVector = prevVectors.1
                
                let normal1 = countNormal(v1: prevBottomVector, v2: prevUpVector, v3: upVector)
                let normal2 = countNormal(v1: prevBottomVector, v2: upVector, v3: bottomVector)
                
                let v11 = Vertex(vector: prevBottomVector, color: color, normal: normal1)
                let v12 = Vertex(vector: prevUpVector, color: color, normal: normal1)
                let v13 = Vertex(vector: upVector, color: color, normal: normal1)
                
                let v21 = Vertex(vector: prevBottomVector, color: color, normal: normal2)
                let v22 = Vertex(vector: upVector, color: color, normal: normal2)
                let v23 = Vertex(vector: bottomVector, color: color, normal: normal2)
                
                vertices += [v11, v12, v13]
                vertices += [v21, v22, v23]
            }
            prevVectors = (upVector, bottomVector)
        }

        return vertices
    }
    
    class func makeEllipseMesh(ellipseVectors: [simd_float4], center: simd_float4, color: (Float, Float, Float)) -> [Vertex] {
        var vertices = [Vertex]()
         
        if !ellipseVectors.isEmpty {
            
            var prevVector: simd_float4? = nil
            for vector in ellipseVectors + [ellipseVectors.first!] {
                if let prevVector = prevVector {
                    /// as triangles
                    let normal = countNormal(v1: center, v2: prevVector, v3: vector)
                    
                    let prevVertex = Vertex(vector: prevVector, color: color, normal: normal)
                    let vertex = Vertex(vector: vector, color: color, normal: normal)
                    let centerVertex = Vertex(vector: center, color: color, normal: normal)
                    
                    vertices.append(centerVertex)
                    vertices.append(prevVertex)
                    vertices.append(vertex)
                }
                prevVector = vector
            }
        }

        return vertices
    }
    
    /// Count Ellipse points, located in Oxz plane
    /// - Parameters:
    ///   - a: semi-major axis
    ///   - b: semi-minor axis
    ///   - delta: approximation accuracy
    ///   - color: color of ellipse
    /// - Returns: array of ellipse vertexes
    class func countEllipseVertices(a: Float, b: Float, delta: Float) -> [simd_float4] {
        let a2: Float = a * a
        let b2: Float = b * b
        var x: Float = 0
        var y: Float = b
        
        func f(x: Float, y: Float) -> Float {
            return b2*x*x + a2*y*y - a2*b2
        }
        
        var vertices = [simd_float4]()
        /// upper arc
        while (a2 * (y - delta/2)) > (b2 * (x+delta)) {
            let vertex = simd_float4(x: x, y: y, z: 0, w: 1)
            vertices.append(vertex)
            
            /// choose next point between (x + delta, y) and (x + delta, y - delta)
            if (f(x: x + delta, y: y - delta/2) >= 0) {
                y -= delta
            }
            x += delta
        }
        
        /// bottom arc
        while y >= 0 {
            let vertex = simd_float4(x: x, y: y, z: 0, w: 1)
            vertices.append(vertex)
            
            /// choose between (x + delta, y - delta) and (x, y - delta)
            if (f(x: x + delta/2, y: y - delta) <= 0) {
                x += delta
            }
            y -= delta
        }
        if let prevVertex = vertices.last {
            let endVertex = simd_float4(x: a, y: 0, z: 0, w: 1)
            if endVertex != prevVertex {
                vertices.append(endVertex)
            }
        }
        
        /// plot other arcs using symmetry
        let arc2: [simd_float4]
        let arc3: [simd_float4]
        let arc4: [simd_float4]
        
        if vertices.count > 2 {
            arc2 = vertices[1..<vertices.count-1].map { (v) -> simd_float4 in
                var newV = v
                newV.x = v.x * -1
                return newV
            }.reversed()
        } else {
            arc2 = []
        }
        
        if vertices.count > 1 {
            arc3 = vertices[1...].map { (v) -> simd_float4 in
                var newV = v
                newV.x = v.x * -1
                newV.y = v.y * -1
                return newV
            }
            
            arc4 = vertices[0..<vertices.count-1].map { (v) -> simd_float4 in
                var newV = v
                newV.y = v.y * -1
                return newV
            }.reversed()
        } else {
            arc3 = []
            arc4 = []
        }
        
        vertices += arc4 + arc3 + arc2
        
        return vertices
    }
}
