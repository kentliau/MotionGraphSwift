//
//  GraphViewController.swift
//  MotionGraphSwift
//
//  Created by Kent Liau on 9/4/15.
//  Copyright © 2015 Kent Liau. All rights reserved.
//

import UIKit
import CoreMotion

class GraphViewController: UIViewController {
    
    @IBOutlet weak var updateIntervalLabel: UILabel!

    @IBOutlet weak var updateIntervalSlider: UISlider!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateIntervalSlider.value = 0.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startUpdatesWithSliderValue( Int(updateIntervalSlider.value * 100) )
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        stopUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Responding to events
    @IBAction func takeSliderValueFrom(sender: UISlider) {
        startUpdatesWithSliderValue(Int(sender.value * 100))
    }
    
    func setLabelValueX(x: Double, y: Double, z: Double) {
        xLabel.text = "x: \(x)"
        yLabel.text = "y: \(y)"
        zLabel.text = "z: \(z)"
    }
    
    func setLabelValueRoll(roll: Double, pitch: Double, yaw: Double) {
        xLabel.text = "roll: \(roll)"
        yLabel.text = "pitch: \(pitch)"
        zLabel.text = "yaw: \(yaw)"
    }
    
    // MARK: - Update methods stub implementations
    func startUpdatesWithSliderValue(sliderValue: Int) {
        return
    }
    
    func stopUpdates() {
        return
    }

}
