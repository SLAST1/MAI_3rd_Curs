//
//  BufferProvider.swift
//  CG2
//
//  Created by Илья Ильин on 18.10.2021.
//

import Foundation
import Metal
import simd


/// Helper class for reusing Uniform Buffers
class BufferProvider: NSObject {
    
    let inflightBuffersCount: Int
    private var uniformsBuffers: [MTLBuffer]
    private var avaliableBufferIndex: Int = 0
    
    var avaliableResourcesSemaphore: DispatchSemaphore
    
    
    /// Creates an object of BufferProvider, that can be used to get available reusable buffer
    /// - Parameters:
    ///   - device: metal device to use
    ///   - inflightBuffersCount: number of buffers stored by BufferProvider
    ///   - sizeOfUniformsBuffer: size of buffer in bytes
    init(device: MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {
        self.avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)
        
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        
        for _ in 0...inflightBuffersCount-1 {
            guard let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: []) else {
                fatalError("Could not make buffer")
            }
            uniformsBuffers.append(uniformsBuffer)
        }
    }
    
    deinit{
        for _ in 0...self.inflightBuffersCount{
            self.avaliableResourcesSemaphore.signal()
        }
    }
    
    
    /// Fetching next available buffer and copy data into it
    /// - Parameters:
    /// - Returns: next available uniform buffer
    func nextUniformsBuffer(projectionMatrix: float4x4, modelViewMatrix: float4x4) -> MTLBuffer {
        let buffer = uniformsBuffers[avaliableBufferIndex]
        let bufferPointer = buffer.contents()
        
        // 1
        var projectionMatrix = projectionMatrix
        var modelViewMatrix = modelViewMatrix
        
        // 2
        memcpy(bufferPointer,
               &modelViewMatrix,
               MemoryLayout<Float>.size * float4x4.numberOfElements()
        )
        memcpy(bufferPointer + MemoryLayout<Float>.size*float4x4.numberOfElements(),
               &projectionMatrix,
               MemoryLayout<Float>.size * float4x4.numberOfElements()
        )
        
        avaliableBufferIndex += 1
        if avaliableBufferIndex == inflightBuffersCount{
            avaliableBufferIndex = 0
        }
        
        return buffer
    }
    
}

