//
//  Vertex.swift
//  CG3-4
//
//  Created by Илья Ильин on 10.12.2021.
//

import Foundation
import simd

struct Vertex {
    var x,y,z: Float     // position data
    var nX,nY,nZ: Float  // normal
    var tX, tY: Float    // texture coords
    
    init(x: Float, y: Float, z: Float, nX: Float, nY: Float, nZ: Float, tX: Float, tY: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.nX = nX
        self.nY = nY
        self.nZ = nZ
        self.tX = tX
        self.tY = tY
    }
    
    init(point: simd_float4, normal: simd_float3) {
        self.x = point.x
        self.y = point.y
        self.z = point.z
        self.nX = normal.x
        self.nY = normal.y
        self.nZ = normal.z
        self.tX = 0
        self.tY = 0
    }
}
