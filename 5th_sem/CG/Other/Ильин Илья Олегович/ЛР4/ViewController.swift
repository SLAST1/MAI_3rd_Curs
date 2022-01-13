//
//  ViewController.swift
//  CG3-4
//
//  Created by Илья Ильин on 01.11.2021.
//

import UIKit
import MetalKit
import ModelIO

class ViewController: UIViewController {
    
    var mtkView: MTKView!
    var renderer: Renderer!
    
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
        super.viewDidLoad()
        
        setupViews()
        
        let device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        
        renderer = Renderer(view: mtkView, device: device)
        mtkView.delegate = renderer
        
        setupGestures()
    }
    
    // MARK: - Views setup
    func setupViews() {
        view.backgroundColor = .black
        
        mtkView = MTKView()
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
