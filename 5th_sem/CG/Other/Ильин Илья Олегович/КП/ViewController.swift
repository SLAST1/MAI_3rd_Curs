//
//  ViewController.swift
//  CG6
//
//  Created by Илья Ильин on 16.12.2021.
//
/*
 Составить и отладить программу, обеспечивающую каркасную визуализацию порции поверхности заданного типа.  Исходные данные готовятся самостоятельно и вводятся из файла или в панели ввода данных. Должна быть обеспечена возможность тестирования программы на различных наборах исходных данных. Программа должна обеспечивать выполнение аффинных преобразований для заданной порции поверхности, а также возможность управлять количеством изображаемых параметрических линий. Для визуализации параметрических линий поверхности разрешается использовать только функции отрисовки отрезков в экранных координатах.
 Вариант 15: Поверхность вращения. Образующая – кубическая  кривая Безье 3D
 */

import UIKit
import MetalKit

class ViewController: MetalViewController {
    
    // MARK: Object related
    
    var object: RotationBezierCurve!
    
    let approximationRange: (Float, Float) = (0.4, 0.01)
    var approximation: Float = 0.4 {
        didSet {
            renderer.approximation = self.approximation
        }
    }
    var rotation: Int = 3 {
        didSet {
            object.rotations = rotation
        }
    }
    var points = [
        simd_float3(0, 3, 0),
        simd_float3(2, 2, 0),
        simd_float3(2, 1, 0),
        simd_float3(3, 0, 0)
    ] {
        didSet {
            object.controlPoints = points
        }
    }
    
    let rotations = [3, 4, 5, 6, 8, 9, 10, 12, 15, 18, 20, 24, 30, 36, 40, 45, 60, 72, 90]
    
    
    // MARK: Views and gestures
    
    var stackView: UIStackView!
    
    var deltaSlider:  UISlider! /// from 0.001 to 1
    var pointsSliders: [UISlider]!
    var rotationStepper: UIStepper!
    var rotationsLabel: UILabel!
    
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
        
        let material = Material(specularColor: simd_float3(0.8, 0.8, 0.8),
                                specularPower: 100,
                                color: simd_float4(0.5, 0.5, 0.5, 1.0),
                                frontFacing: .counterClockwise,
                                cullMode: MTLCullMode.none,
                                triangleFillMode: .lines)
        
        object = RotationBezierCurve(name: "Bezier", material: material, controlPoints: points, approximation: 0.4, rotations: 3)
        self.scene.rootNode.children.append(object)
    }
    
    
    // MARK: - Views setup
    func setupViews() {
        mtkView = MTKView()
        mtkView.clearColor = MTLClearColor(red: 0, green: 1, blue: 1, alpha: 1)
        mtkView.isOpaque = false
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mtkView)
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        
        let deltaLabel = UILabel()
        deltaLabel.text = "Approximation"
        stackView.addArrangedSubview(deltaLabel)
        
        deltaSlider = UISlider()
        deltaSlider.value = 1
        deltaSlider.maximumValue = 100
        deltaSlider.minimumValue = 1
        deltaSlider.addTarget(self, action: #selector(self.deltaValueChanged(_:)), for: .valueChanged)
        stackView.addArrangedSubview(deltaSlider)
        
        rotationsLabel = UILabel()
        rotationsLabel.text = "Rotations: \(rotation)"
        stackView.addArrangedSubview(rotationsLabel)
        
        rotationStepper = UIStepper()
        rotationStepper.wraps = true
        rotationStepper.minimumValue = 0
        rotationStepper.maximumValue = Double(rotations.count - 1)
        rotationStepper.value = 0
        rotationStepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        stackView.addArrangedSubview(rotationStepper)
        
        let fillLabel = UILabel()
        fillLabel.text = "Filling mode"
        stackView.addArrangedSubview(fillLabel)
        
        let fillSwitch = UISwitch()
        fillSwitch.addTarget(self, action: #selector(fillValueChanged(_:)), for: .valueChanged)
        fillSwitch.isOn = false
        stackView.addArrangedSubview(fillSwitch)
        
        let cullLabel = UILabel()
        cullLabel.text = "Cull mode"
        stackView.addArrangedSubview(cullLabel)
        
        let cullSwitch = UISwitch()
        cullSwitch.addTarget(self, action: #selector(cullValueChanged(_:)), for: .valueChanged)
        cullSwitch.isOn = false
        stackView.addArrangedSubview(cullSwitch)
        
        let pointsLabel = UILabel()
        pointsLabel.text = "Points Y position"
        stackView.addArrangedSubview(pointsLabel)
        
        for i in 0..<points.count {
            let slider = UISlider()
            slider.tag = i
            slider.minimumValue = -5
            slider.maximumValue = 5
            slider.value = points[i].y
            slider.addTarget(self, action: #selector(pointValueChanged(_:)), for: .valueChanged)
            stackView.addArrangedSubview(slider)
        }
        
        view.addSubview(stackView)
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            mtkView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mtkView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mtkView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75),
            mtkView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            stackView.leftAnchor.constraint(equalTo: mtkView.rightAnchor, constant: 30),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
        ])
    }
    
    //MARK: - UIControl functions
    
    @objc func deltaValueChanged(_ sender: UISlider!) {
        let step = abs(approximationRange.0 - approximationRange.1) / sender.maximumValue
        approximation = (sender.maximumValue + 1 - sender.value) * step
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper!) {
        rotation = rotations[Int(sender.value)]
        rotationsLabel.text = "Rotations: \(rotation)"
    }
    
    @objc func pointValueChanged(_ sender: UISlider!) {
        points[sender.tag].y = Float(sender.value)
    }
    
    @objc func fillValueChanged(_ sender: UISwitch!) {
        if sender.isOn {
            object.material.triangleFillMode = .fill
        } else {
            object.material.triangleFillMode = .lines
        }
    }
    
    @objc func cullValueChanged(_ sender: UISwitch!) {
        if sender.isOn {
            object.material.cullMode = .back
        } else {
            object.material.cullMode = MTLCullMode.none
        }
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
