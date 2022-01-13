//
//  Vertex.swift
//  CG3
//
//  Created by Илья Ильин on 30.11.2021.
//

import Darwin
import simd

struct Vertex{
    
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
    var nX,nY,nZ: Float  // normal
    
    
    init(x: Float, y: Float, z: Float, r: Float, g: Float, b: Float, a: Float, nX: Float, nY: Float, nZ: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        self.nX = nX
        self.nY = nY
        self.nZ = nZ
    }
    
    init(vector: simd_float4, color: (Float, Float, Float), normal: simd_float3) {
        self.x = vector.x
        self.y = vector.y
        self.z = vector.z
        self.r = color.0
        self.g = color.1
        self.b = color.2
        self.a = 1.0
        self.nX = normal.x
        self.nY = normal.y
        self.nZ = normal.z
    }
    
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a,nX,nY,nZ]
    }
    
    func apply(transformMatrix: float4x4) -> Vertex {
        var vector = simd_float4(x: x, y: y, z: z, w: 1)
        vector = transformMatrix * vector
        var vertex = self
        vertex.x = vector.x
        vertex.y = vector.y
        vertex.z = vector.z
        return vertex
    }
    
    static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        let diff1 = fabsf(lhs.x - rhs.x)
        let diff2 = fabsf(lhs.y - rhs.y)
        let diff3 = fabsf(lhs.z - rhs.z)
        
        let sum1 = fabsf(lhs.x + rhs.x)
        let sum2 = fabsf(lhs.y + rhs.y)
        let sum3 = fabsf(lhs.z + rhs.z)
        
        let K: Float = pow(10.0, 3.0)
        
        return ( (diff1 < K * Float.ulpOfOne * sum1) || diff1 < Float.leastNormalMagnitude ) &&
               ( (diff2 < K * Float.ulpOfOne * sum2) || diff2 < Float.leastNormalMagnitude ) &&
               ( (diff3 < K * Float.ulpOfOne * sum3) || diff3 < Float.leastNormalMagnitude )
    }
    
    static func != (lhs: Vertex, rhs: Vertex) -> Bool {
        return !(lhs == rhs)
    }
}
