//
//  AccelerometerGraphViewController.swift
//  MotionGraphSwift
//
//  Created by Kent Liau on 9/4/15.
//  Copyright © 2015 Kent Liau. All rights reserved.
//

import UIKit

class AccelerometerGraphViewController: GraphViewController {
    
    let accelerometerMin: NSTimeInterval = 0.01
    
    @IBOutlet weak var graphView: GraphView!
    
    override func startUpdatesWithSliderValue(sliderValue: Int) {
   
        let delta = NSTimeInterval(0.005)
        let updateInterval = accelerometerMin + delta * NSTimeInterval(sliderValue)
        
        let motionManager = (UIApplication.sharedApplication().delegate as! AppDelegate).sharedMotionManager
        
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = updateInterval
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {
                data, error in
                self.graphView.addX(data!.acceleration.x, y: data!.acceleration.y, z: data!.acceleration.z)
                self.setLabelValueX(data!.acceleration.x, y: data!.acceleration.y, z: data!.acceleration.z)
            })
        }
        updateIntervalLabel.text = NSString(format: "%f", updateInterval) as String
    }
    
    
    override func stopUpdates() {
        let motionManager = (UIApplication.sharedApplication().delegate as! AppDelegate).sharedMotionManager
        if motionManager.accelerometerActive {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
}
