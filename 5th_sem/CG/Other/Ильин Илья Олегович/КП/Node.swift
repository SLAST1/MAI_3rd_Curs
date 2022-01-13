//
//  Node.swift
//  CG6
//
//  Created by Илья Ильин on 16.12.2021.
//

import Foundation
import MetalKit
import simd

struct Material {
    var specularColor = simd_float3(1, 1, 1)
    var specularPower = Float(1)
    var color: simd_float4 = simd_float4(0, 0, 0, 1)
    
    var frontFacing: MTLWinding?
    var cullMode: MTLCullMode? = MTLCullMode.none
    var triangleFillMode: MTLTriangleFillMode? = .lines
}

struct NodeAnimation {
    var materialAnimation: ( (Material, Float) -> (Material) )?
    var modelAnimation:    ( (float4x4, Float) -> (float4x4) )?
}


protocol NodeDelegate : AnyObject {
    func createMesh(node: String, vertices: [Vertex], indices: [[UInt16]]) -> MTKMesh?
}

class Node {
    // MARK: Node structure
    
    private(set) var name: String
    weak var parent: Node?
    var children = [Node]()
    
    // MARK: Delegate
    
    weak var delegate: NodeDelegate?
    
    // MARK: Node drawing properties
    
    public internal(set) var needRecount: Bool = true
    private(set) var time: Float = 0.0
    private(set) var approximation: Float {
        didSet {
            if oldValue != approximation {
                needRecount = true
            }
        }
    }
    
    public var modelMatrix = matrix_identity_float4x4
    
    private(set) var mesh: MTKMesh?
    public internal(set) var material: Material
    public internal(set) var vertices = [Vertex]()
    public internal(set) var indices =  [[UInt16]]()
    
    var animation: NodeAnimation?
    
    // MARK: Initialization
    
    init(name: String, material: Material, approximation: Float) {
        self.material = material
        self.approximation = approximation
        self.name = name
    }
    
    convenience init(name: String) {
        self.init(name: name, material: Material(), approximation: 1.0)
    }
    
    // MARK: Interface
    
    final func update(time: Float, approximation: Float) {
        self.time = time
        self.approximation = approximation
        updateLogic()
    }
    
    final func nodeNamedRecursive(_ name: String) -> Node? {
        for node in children {
            if node.name == name {
                return node
            } else if let matchingGrandchild = node.nodeNamedRecursive(name) {
                return matchingGrandchild
            }
        }
        return nil
    }
    
    final func getChildrenNodes() -> [Node] {
        var nodes = [self]
        for child in children {
            nodes += child.getChildrenNodes()
        }
        return nodes
    }
    
    // MARK: Internal methods
    
    /// Counts nodes vertices, needs to be overriden and set verices and indices
    internal func countVertices() {}
    
    // MARK: Private methods
    
    private func updateMesh() {
        mesh = delegate?.createMesh(node: name, vertices: vertices, indices: indices)
    }
    
    /// Called when we need to update figure mesh due to approximation changes
    private func updateLogic(){
        var needMeshUpdate = false
        if needRecount {
            countVertices()
            needRecount = false
            needMeshUpdate = true
        }
        
        material = animation?.materialAnimation?(material, time) ?? material
        modelMatrix = animation?.modelAnimation?(modelMatrix, time) ?? modelMatrix
        
        if needMeshUpdate {
            updateMesh()
        }
    }
}
