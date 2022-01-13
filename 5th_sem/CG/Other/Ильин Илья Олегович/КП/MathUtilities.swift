//
//  MathUtilities.swift
//  CG3-4
//
//  Created by Илья Ильин on 01.11.2021.
//

import Foundation
import simd

import GLKit

extension simd_float4 {
    var xyz: simd_float3 {
        return simd_float3(x, y, z)
    }
}

extension float4x4 {
    // MARK: init
    init(scaleBy s: Float) {
        self.init(simd_float4(s, 0, 0, 0),
                  simd_float4(0, s, 0, 0),
                  simd_float4(0, 0, s, 0),
                  simd_float4(0, 0, 0, 1))
    }
    
    init(rotationAbout axis: simd_float3, by angleRadians: Float) {
        let x = axis.x, y = axis.y, z = axis.z
        let c = cosf(angleRadians)
        let s = sinf(angleRadians)
        let t = 1 - c
        self.init(simd_float4( t * x * x + c,     t * x * y + z * s, t * x * z - y * s, 0),
                  simd_float4( t * x * y - z * s, t * y * y + c,     t * y * z + x * s, 0),
                  simd_float4( t * x * z + y * s, t * y * z - x * s,     t * z * z + c, 0),
                  simd_float4(                 0,                 0,                 0, 1))
    }
    
    init(translationBy t: simd_float3) {
        self.init(simd_float4(   1,    0,    0, 0),
                  simd_float4(   0,    1,    0, 0),
                  simd_float4(   0,    0,    1, 0),
                  simd_float4(t[0], t[1], t[2], 1))
    }
    
    init(perspectiveProjectionFov fovRadians: Float, aspectRatio aspect: Float, nearZ: Float, farZ: Float) {
        let yScale = 1 / tan(fovRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = farZ - nearZ
        let zScale = -(farZ + nearZ) / zRange
        let wzScale = -2 * farZ * nearZ / zRange
        
        let xx = xScale
        let yy = yScale
        let zz = zScale
        let zw = Float(-1)
        let wz = wzScale
        
        self.init(simd_float4(xx,  0,  0,  0),
                  simd_float4( 0, yy,  0,  0),
                  simd_float4( 0,  0, zz, zw),
                  simd_float4( 0,  0, wz,  1))
    }
    
    var normalMatrix: float3x3 {
        let upperLeft = float3x3(self[0].xyz, self[1].xyz, self[2].xyz)
        return upperLeft.transpose.inverse
    }
}

func countNormal(v1: simd_float4, v2: simd_float4, v3: simd_float4) -> simd_float3 {
    let diff1 = simd_float3(x: v2.x, y: v2.y, z: v2.z) - simd_float3(x: v3.x, y: v3.y, z: v3.z)
    let diff2 = simd_float3(x: v2.x, y: v2.y, z: v2.z) - simd_float3(x: v1.x, y: v1.y, z: v1.z)
    return simd_normalize(simd_cross(diff1, diff2))
}

func makeRotationMatrixAroundZ(degrees: Double) -> float4x4 {
    let angle = Measurement(value: degrees,
                            unit: UnitAngle.degrees)
    let radians = Float(angle.converted(to: .radians).value)
    
    let rows = [
        simd_float4(cos(radians), -sin(radians), 0,      0),
        simd_float4(sin(radians), cos(radians),  0,      0),
        simd_float4(0,            0,             1,      0),
        simd_float4(0,            0,             0,      1)
    ]
    
    return float4x4(rows: rows)
}

func makeRotationMatrixAroundX(degrees: Double) -> float4x4 {
    let angle = Measurement(value: degrees,
                            unit: UnitAngle.degrees)
    let radians = Float(angle.converted(to: .radians).value)
    
    let rows = [
        simd_float4(1,   0,            0,               0),
        simd_float4(0,   cos(radians), -sin(radians),   0),
        simd_float4(0,   sin(radians), cos(radians),    0),
        simd_float4(0,   0,            0,               1)
    ]
    
    return float4x4(rows: rows)
}

func makeRotationMatrixAroundY(degrees: Double) -> float4x4 {
    let angle = Measurement(value: degrees,
                            unit: UnitAngle.degrees)
    let radians = Float(angle.converted(to: .radians).value)
    
    let rows = [
        simd_float4(cos(radians),  0,   sin(radians),  0),
        simd_float4(0,             1,   0,             0),
        simd_float4(-sin(radians), 0 ,  cos(radians),  0),
        simd_float4(0,             0,   0,             1)
    ]
    
    return float4x4(rows: rows)
}

func makeTranslationMatrix(tx: Float, ty: Float, tz: Float) -> float4x4 {
    var matrix = matrix_identity_float4x4

    matrix[3, 0] = tx
    matrix[3, 1] = ty
    matrix[3, 2] = tz

    return matrix
}

func translateVector(vector: simd_float4, tx: Float, ty: Float, tz: Float) -> simd_float4 {
    let translationMatrix = makeTranslationMatrix(tx: tx, ty: ty, tz: tz)
    return translationMatrix * vector
}

func makeStretchMatrix(sx: Float, sy: Float, sz: Float) -> float4x4 {
    var matrix = matrix_identity_float4x4

    matrix[0, 0] = sx
    matrix[1, 1] = sy
    matrix[2, 2] = sz

    return matrix
}
