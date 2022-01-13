//
//  Vertex.swift
//  CG2
//
//  Created by Илья Ильин on 18.10.2021.
//

import Foundation

struct Vertex{
    
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
    
    init(x: Float, y: Float, z: Float, r: Float, g: Float, b: Float, a: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(x: Float, y: Float, z: Float) {
        self.init(x: x, y: y, z: z, r: 0, g: 0, b: 0, a: 1)
    }
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]
    }
    
}

