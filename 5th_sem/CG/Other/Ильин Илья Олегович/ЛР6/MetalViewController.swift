//
//  MetalViewController.swift
//  CG6
//
//  Created by Илья Ильин on 16.12.2021.
//

import UIKit
import MetalKit

class MetalViewController: UIViewController {
    
    var mtkView: MTKView!
    var renderer: Renderer!
    var scene: Scene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        
        renderer = Renderer(view: mtkView, device: device, scene: scene)
        mtkView.delegate = renderer
    }
}
