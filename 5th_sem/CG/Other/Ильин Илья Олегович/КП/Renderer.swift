//
//  Renderer.swift
//  CG3-4
//
//  Created by Илья Ильин on 01.11.2021.
//

import Foundation
import MetalKit
import simd

struct VertexUniforms {
    var viewProjectionMatrix: float4x4
    var modelMatrix: float4x4
    var normalMatrix: float3x3
}

struct FragmentUniforms {
    var cameraWorldPosition = simd_float3(0, 0, 0)
    var ambientLightColor = simd_float3(0, 0, 0)
    var specularColor = simd_float3(1, 1, 1)
    var specularPower = Float(1)
    var materialColor = simd_float4(1, 1, 1, 1)
    var light0 = Light()
    var light1 = Light()
    var light2 = Light()
}

// MARK: - Renderer

class Renderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var renderPipeline: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    let vertexDescriptor: MDLVertexDescriptor
    let bufferAllocator: MTKMeshBufferAllocator
    
    var time: Float = 0
    let scene: Scene
    
    var cameraWorldPosition = simd_float3(0, 0, 2)
    var viewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
    
    var approximation: Float = 0.4
    
    var rotationX: Float     = 0.0
    var rotationY: Float     = 0.0
    var rotationZ: Float     = 0.0
    var scale: Float         = 1.0
    
    let defaultCull = MTLCullMode.none
    let defaultWiding = MTLWinding.clockwise
    let defaultTriangleFill = MTLTriangleFillMode.fill
    
    // MARK: - Initialization
    
    init(view: MTKView, device: MTLDevice, scene: Scene) {
        self.device = device
        commandQueue = device.makeCommandQueue()!
        vertexDescriptor = Renderer.buildVertexDescriptor()
        renderPipeline = Renderer.buildPipeline(device: device, view: view, vertexDescriptor: vertexDescriptor)
        depthStencilState = Renderer.buildDepthStencilState(device: device)
        self.bufferAllocator = MTKMeshBufferAllocator(device: device)
        self.scene = scene
        
        super.init()
        
        setupNodes()
    }
    
    private func setupNodes() {
        for node in scene.nodes {
            node.delegate = self
            node.update(time: time, approximation: approximation)
        }
    }
    
    private static func buildVertexDescriptor() -> MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0,
                                                            bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                            format: .float3,
                                                            offset: MemoryLayout<Float>.stride * 3,
                                                            bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Vertex>.stride)
        
        return vertexDescriptor
    }
    
    private static func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }
    
    private static func buildPipeline(device: MTLDevice, view: MTKView, vertexDescriptor: MDLVertexDescriptor) -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Could not load default library from main bundle")
        }
        
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add

        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha

        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        pipelineDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat

        let mtlVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        pipelineDescriptor.vertexDescriptor = mtlVertexDescriptor
        
        do {
            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Could not create render pipeline state object: \(error)")
        }
    }
    
    // MARK: - Drawing
    func updateSceneLogic() {
        for node in scene.nodes {
            node.update(time: time, approximation: approximation)
        }
    }
    
    func update(_ view: MTKView) {
        time += 1 / Float(view.preferredFramesPerSecond)
        
        cameraWorldPosition = simd_float3(0, 0, 6)
        viewMatrix = float4x4(translationBy: -cameraWorldPosition)
     
        let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        projectionMatrix = float4x4(perspectiveProjectionFov: Float.pi / 3, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100)
        
        scene.rootNode.modelMatrix = float4x4(rotationAbout: simd_float3(1, 0, 0), by: rotationY) * float4x4(rotationAbout: simd_float3(0, 1, 0), by: rotationX) *  float4x4(scaleBy: scale)
        
        updateSceneLogic()
    }
    
    func drawScene(commandEncoder: MTLRenderCommandEncoder) {
        drawNodeRecursive(scene.rootNode, parentTransform: matrix_identity_float4x4, commandEncoder: commandEncoder)
    }
    
    func drawNodeRecursive(_ node: Node, parentTransform: float4x4, commandEncoder: MTLRenderCommandEncoder) {
        
        commandEncoder.setCullMode(node.material.cullMode ?? defaultCull)
        commandEncoder.setFrontFacing(node.material.frontFacing ?? defaultWiding)
        commandEncoder.setTriangleFillMode(node.material.triangleFillMode ?? defaultTriangleFill)
        
        let modelMatrix = parentTransform * node.modelMatrix
     
        if let mesh = node.mesh {
            let viewProjectionMatrix = projectionMatrix * viewMatrix
            var vertexUniforms = VertexUniforms(viewProjectionMatrix: viewProjectionMatrix,
                                                modelMatrix: modelMatrix,
                                                normalMatrix: modelMatrix.normalMatrix)
            commandEncoder.setVertexBytes(&vertexUniforms, length: MemoryLayout<VertexUniforms>.size, index: 1)
     
            var fragmentUniforms = FragmentUniforms(cameraWorldPosition: cameraWorldPosition,
                                                    ambientLightColor: scene.ambientLightColor,
                                                    specularColor: node.material.specularColor,
                                                    specularPower: node.material.specularPower,
                                                    materialColor: node.material.color,
                                                    light0: scene.lights[0],
                                                    light1: scene.lights[1],
                                                    light2: scene.lights[2])
            commandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.size, index: 0)
     
            let vertexBuffer = mesh.vertexBuffers.first!
            commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
     
            for submesh in mesh.submeshes {
                let indexBuffer = submesh.indexBuffer
                commandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                     indexCount: submesh.indexCount,
                                                     indexType: submesh.indexType,
                                                     indexBuffer: indexBuffer.buffer,
                                                     indexBufferOffset: indexBuffer.offset)
            }
        }
     
        for child in node.children {
            drawNodeRecursive(child, parentTransform: modelMatrix, commandEncoder: commandEncoder)
        }
        
    }
    
}


// MARK: - NodeDelegate

extension Renderer : NodeDelegate {
    
    internal func createMesh(node: String, vertices: [Vertex], indices: [[UInt16]]) -> MTKMesh? {
        if vertices.isEmpty || indices.isEmpty { return nil }
        
        let vertexBuffer = bufferAllocator.newBuffer(MemoryLayout<Vertex>.stride * vertices.count, type: .vertex)
        let vertexMap = vertexBuffer.map()
        vertexMap.bytes.assumingMemoryBound(to: Vertex.self).assign(from: vertices, count: vertices.count)
        
        var submeshes = [MDLSubmesh]()
        for indices in indices {
            let indexBuffer = bufferAllocator.newBuffer(MemoryLayout<UInt16>.stride * indices.count, type: .index)
            let indexMap = indexBuffer.map()
            indexMap.bytes.assumingMemoryBound(to: UInt16.self).assign(from: indices, count: indices.count)
            
            let submesh = MDLSubmesh(indexBuffer: indexBuffer,
                                     indexCount: indices.count,
                                     indexType: .uInt16,
                                     geometryType: .triangles,
                                     material: nil)
            submeshes.append(submesh)
        }

        let mdlMesh = MDLMesh(vertexBuffer: vertexBuffer,
                              vertexCount: vertices.count,
                              descriptor: vertexDescriptor,
                              submeshes: submeshes)
        let mesh: MTKMesh?
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch {
            mesh = nil
            NSLog("Couldn't create mesh of node %s", node)
        }
        
        return mesh
    }
}
    
// MARK: - MTKViewDelegate

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        update(view)
     
        let commandBuffer = commandQueue.makeCommandBuffer()!
        if let renderPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

            commandEncoder.setDepthStencilState(depthStencilState)
            commandEncoder.setRenderPipelineState(renderPipeline)
            
            drawScene(commandEncoder: commandEncoder)
            commandEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
