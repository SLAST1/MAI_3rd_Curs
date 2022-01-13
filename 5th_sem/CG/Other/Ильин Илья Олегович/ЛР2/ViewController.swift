//
//  ViewController.swift
//  CG2
//
//  Created by Илья Ильин on 18.10.2021.
//

import UIKit
import simd

class ViewController: MetalViewController, MetalViewControllerDelegate {
    
    var worldModelMatrix: float4x4!
    var objectToDraw: Parallelepiped! //
    
    let panSensivity: Float = 5.0
    let pinchSensivity: Float = 0.5
    var lastPanLocation: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worldModelMatrix = float4x4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -4)
        worldModelMatrix.rotateAroundX(float4x4.degrees(toRad: 25), y: 0.0, z: 0.0)
        
        objectToDraw = Parallelepiped(device: device) //
        
        self.metalViewControllerDelegate = self
        
        setupGestures()
    }
    
    //MARK: - MetalViewControllerDelegate
    func renderObjects(drawable: CAMetalDrawable) {
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(timeSinceLastUpdate: CFTimeInterval) {
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
    }
    
    //MARK: - Gesture recognition
    func setupGestures(){
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
            
            objectToDraw.rotationY -= xDelta
            objectToDraw.rotationX -= yDelta
            lastPanLocation = pointInView
        } else if sender.state == UIGestureRecognizer.State.began {
            lastPanLocation = sender.location(in: self.view)
        }
    }
    
    @objc func pinch(_ sender: UIPinchGestureRecognizer) {
        let newScale = Float(sender.scale) * pinchSensivity
        objectToDraw.scale = newScale
    }
    
    @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
}

