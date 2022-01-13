//
//  ViewController.swift
//  CG1
//
//  Created by Илья Ильин on 21.09.2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var graphView: UIGraphView!
    
    @IBOutlet weak var functionLabel: UILabel!
    @IBOutlet weak var aSlider: UISlider!
    @IBOutlet weak var kSlider: UISlider!
    @IBOutlet weak var phiSlider: UISlider!
    
    // параметры функции
    var points = [CGPoint]()
    var step: Double = 0.01
    
    var a: Double = 1 {
        didSet {
            if a != oldValue {
                countPoints()
                redrawGraph()
            }
        }
    }
    var k: Double = 1 {
        didSet {
            if k != oldValue {
                countPoints()
                redrawGraph()
            }
        }
    }
    var phiUpperBound: Double = 16 {
        didSet {
            if phiUpperBound != oldValue {
                countPoints()
                redrawGraph()
            }
        }
    }
    
    func countPoints() {
        points.removeAll()
        for phi in stride(from: 0, through: phiUpperBound, by: step) {
            let x = a * exp(k * phi) * cos(phi)
            let y = a * exp(k * phi) * sin(phi)
            points.append(CGPoint(x: x, y: y))
        }
    }
    
    func redrawGraph() {
        graphView.points = points
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        functionLabel.text = "Here will be function!"
        
        aSlider.value = Float(a)
        aSlider.minimumValue = -10
        aSlider.maximumValue = 10
        
        kSlider.value = Float(k)
        kSlider.minimumValue = -10
        kSlider.maximumValue = 10
        
        phiSlider.value = Float(phiUpperBound)
        phiSlider.minimumValue = 0
        phiSlider.maximumValue = 30
        
        countPoints()
        redrawGraph()
    }
    
    @IBAction func aSliderValueChanged(_ sender: UISlider) {
        a = Double(sender.value)
    }
    @IBAction func kSliderValueChanged(_ sender: UISlider) {
        k = Double(sender.value)
    }
    
    @IBAction func phiSliderValueChanged(_ sender: UISlider) {
        phiUpperBound = Double(sender.value)
    }
    
}

