//
//  Vertex.swift
//  CG3-4
//
//  Created by Илья Ильин on 10.12.2021.
//

import Foundation
import simd

struct Vertex {
    var x, y, z: Float      // position data
    var nX, nY, nZ: Float   // normal
}

extension Vertex {
    init(point: simd_float4, normal: simd_float3) {
        self.x = point.x
        self.y = point.y
        self.z = point.z
        self.nX = normal.x
        self.nY = normal.y
        self.nZ = normal.z
    }
}
