//
//  ViewController.swift
//  CG6
//
//  Created by Илья Ильин on 16.12.2021.
//

/*
 Для поверхности, созданной в л.р. №4-5, обеспечить выполнение следующего шейдерного эффекта:
 Вариант 13:  Анимация. Прозрачность изменяется по синусоидальному закону
 */

import UIKit
import MetalKit

class ViewController: MetalViewController {
    
    var approximation: Float = 1.0 {
        didSet {
            renderer.approximation = self.approximation
        }
    }
    
    // MARK: Sliders and gestures
    
    var deltaSlider:  UISlider! /// from 0.001 to 1
    
    let panSensivity: Float   = 5.0
    let pinchSensivity: Float = 0.5
    var lastPanLocation: CGPoint!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        setupViews()
        setupScene()
        
        super.viewDidLoad()
        
        setupGestures()
    }
    
    // MARK: - Scene setup
    
    func setupScene() {
        self.scene = Scene()
     
        self.scene.ambientLightColor = simd_float3(0.01, 0.01, 0.01)
        let light0 = Light(worldPosition: simd_float3( 2,  2, 2), color: simd_float3(1.0, 0.8, 0.8))
        let light1 = Light(worldPosition: simd_float3(-2,  2, 2), color: simd_float3(0.8, 1.0, 0.8))
        let light2 = Light(worldPosition: simd_float3( 0, -2, 2), color: simd_float3(0.8, 0.8, 1.0))
        self.scene.lights = [ light0, light1, light2 ]
        
        let rotationMatrix = makeRotationMatrixAroundY(degrees: 0.5)
        let animation = NodeAnimation(materialAnimation: { material, time in
            var newMaterial = material
            newMaterial.color.w = sin(time)
            return newMaterial
        }, modelAnimation: nil)
//        { [rotationMatrix] modelMatrix, time in
//            return modelMatrix * rotationMatrix
//        }
        let material = Material(specularColor: simd_float3(0.8, 0.8, 0.8),
                                specularPower: 100,
                                color: simd_float4(0.5, 0.5, 0.5, 1.0))
        let cylinder = TiltCylinder(name: "Cylinder", material: material, a: 2, b: 1, delta: approximation)
        cylinder.animation = animation
        
        self.scene.rootNode.children.append(cylinder)
    }
    
    
    // MARK: - Views setup
    func setupViews() {
        view.backgroundColor = .black
        
        mtkView = MTKView()
        mtkView.clearColor = MTLClearColor(red: 0, green: 1, blue: 1, alpha: 1)
        mtkView.isOpaque = false
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mtkView)
        
        deltaSlider = UISlider()
        deltaSlider.value = 1
        deltaSlider.maximumValue = 1000
        deltaSlider.minimumValue = 1
        deltaSlider.addTarget(self, action: #selector(self.deltaValueChanged(_:)), for: .valueChanged)
        deltaSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deltaSlider)
        
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            mtkView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mtkView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mtkView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mtkView.bottomAnchor.constraint(equalTo: deltaSlider.topAnchor),
            
            deltaSlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            deltaSlider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            deltaSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    @objc func deltaValueChanged(_ sender: UISlider!) {
        approximation = (sender.maximumValue + 1 - sender.value) / sender.maximumValue
    }
    
    //MARK: - Gesture related
    func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.pan(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinch(_:)))
        self.view.addGestureRecognizer(pan)
        self.view.addGestureRecognizer(pinch)
    }

    @objc func pan(_ sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.changed {
            let pointInView = sender.location(in: self.view)
            
            let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
            let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
            
            renderer.rotationX -= xDelta
            renderer.rotationY -= yDelta
            
            lastPanLocation = pointInView
        } else if sender.state == UIGestureRecognizer.State.began {
            lastPanLocation = sender.location(in: self.view)
        }
    }
    
    @objc func pinch(_ sender: UIPinchGestureRecognizer) {
        let newScale = Float(sender.scale) * pinchSensivity
        renderer.scale = newScale
    }
    
    @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
}
