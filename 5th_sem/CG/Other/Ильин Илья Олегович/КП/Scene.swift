//
//  Scene.swift
//  CG3-4
//
//  Created by Илья Ильин on 01.11.2021.
//

import Foundation
import MetalKit
import simd

struct Light {
    var worldPosition = simd_float3(0, 0, 0)
    var color = simd_float3(0, 0, 0)
}

class Scene {
    var rootNode = Node(name: "Root")
    var ambientLightColor = simd_float3(0, 0, 0)
    var lights = [Light]()
    
    var nodes: [Node] {
        rootNode.getChildrenNodes()
    }
    
    func nodeNamed(_ name: String) -> Node? {
        if rootNode.name == name {
            return rootNode
        } else {
            return rootNode.nodeNamedRecursive(name)
        }
    }
}
