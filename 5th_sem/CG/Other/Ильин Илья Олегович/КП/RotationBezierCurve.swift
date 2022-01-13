//
//  RotationBezierCurve.swift
//  CG_KP
//
//  Created by Илья Ильин on 25.12.2021.
//

import Foundation
import simd

class RotationBezierCurve : Node {
    
    var controlPoints: [simd_float3] {
        didSet {
            self.needRecount = true
        }
    }
    var rotations: Int {
        didSet {
            self.needRecount = true
        }
    }
    
    init(name: String, material: Material, controlPoints: [simd_float3], approximation: Float, rotations: Int) {
        self.controlPoints = controlPoints
        self.rotations = rotations < 3 ? 3 : rotations
        
        super.init(name: name, material: material, approximation: approximation)
    }
    
    
    override func countVertices() {
        let bezierCurve = countBezierCurvePoints()
        (self.vertices, self.indices) = countSurfaceVertices(bezierCurvePoints: bezierCurve)
        print(">>> \(bezierCurve.first?.description ?? "none") \(bezierCurve.last?.description ?? "none")")
    }
    
    private func countSurfaceVertices(bezierCurvePoints: [simd_float4]) -> ([Vertex], [[UInt16]]) {
        guard bezierCurvePoints.count >= 3 else { return ([], []) }
        var resultVertices = [Vertex]()
        var resultIndices = [UInt16]()
        var shift: UInt16 = 0
        
        let rotationMatrix = makeRotationMatrixAroundY(degrees: Double(360 / rotations))
        var prevCurve = bezierCurvePoints
        
        for rotation in 1...rotations {
            let curve: [simd_float4]
            if rotation == rotations {
                curve = bezierCurvePoints
            } else {
                curve = prevCurve.map { rotationMatrix * $0 }
            }
            
            ///top triangle
            let normal = countNormal(v1: prevCurve[0], v2: prevCurve[1], v3: curve[1])
            let v0 = Vertex(point: prevCurve[0], normal: normal)
            let v1 = Vertex(point: prevCurve[1], normal: normal)
            let v2 = Vertex(point: curve[1], normal: normal)
            
            resultVertices += [v0, v1, v2]
            resultIndices += [shift, shift+1, shift+2]
            shift += 3
            
            /// others triangles
            var prevLPoint = prevCurve[1]
            var prevRPoint = curve[1]
            for (lPoint, rPoint) in zip( prevCurve[2...], curve[2...] ) {
                let normal1 = countNormal(v1: prevLPoint, v2: lPoint, v3: prevRPoint)
                let normal2 = countNormal(v1: prevRPoint, v2: lPoint, v3: rPoint)
                
                let v11 = Vertex(point: prevLPoint, normal: normal1)
                let v12 = Vertex(point: lPoint, normal: normal1)
                let v13 = Vertex(point: prevRPoint, normal: normal1)
                
                let v21 = Vertex(point: prevRPoint, normal: normal2)
                let v22 = Vertex(point: lPoint, normal: normal2)
                let v23 = Vertex(point: rPoint, normal: normal2)
                
                resultVertices += [v11, v12, v13, v21, v22, v23]
                resultIndices += [shift+0, shift+1, shift+2, shift+3, shift+4, shift+5]
                shift += 6
                
                prevLPoint = lPoint
                prevRPoint = rPoint
            }
            
            prevCurve = curve
        }
        
        return (resultVertices, [resultIndices])
    }
    
    private func countBinomial(n: Int, k: Int) -> Float {
        var result: Float = 1.0
        if (n == k || k < 1) {
            return result
        }
        
        for i in 1...k {
            result *= Float( (n + 1 - i) / i )
        }
        return result
    }
    
    private func countBezierCurvePoints() -> [simd_float4] {
        
        let n = controlPoints.count - 1
        var bezierCurve = [simd_float4]()
        
        for t in stride(from: Float(0.0), to: Float(1.0), by: approximation) {
            var point = simd_float3()
            for i in 0...n {
                point.x += countBinomial(n: n, k: i) * pow(1 - t, Float(n - i)) * pow(t, Float(i)) * controlPoints[i].x
                point.y += countBinomial(n: n, k: i) * pow(1 - t, Float(n - i)) * pow(t, Float(i)) * controlPoints[i].y
                point.z += countBinomial(n: n, k: i) * pow(1 - t, Float(n - i)) * pow(t, Float(i)) * controlPoints[i].z
            }
            bezierCurve.append( simd_float4(point, 1.0) )
        }
        let t: Float = 1.0
        var point = simd_float3()
        for i in 0...n {
            point.x += countBinomial(n: n, k: i) * pow(1 - t, Float(n - i)) * pow(t, Float(i)) * controlPoints[i].x
            point.y += countBinomial(n: n, k: i) * pow(1 - t, Float(n - i)) * pow(t, Float(i)) * controlPoints[i].y
            point.z += countBinomial(n: n, k: i) * pow(1 - t, Float(n - i)) * pow(t, Float(i)) * controlPoints[i].z
        }
        bezierCurve.append( simd_float4(point, 1.0) )

        
        return bezierCurve
    }
}
