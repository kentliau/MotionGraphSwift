//
//  GyroGraphViewController.swift
//  MotionGraphSwift
//
//  Created by Kent Liau on 9/4/15.
//  Copyright © 2015 Kent Liau. All rights reserved.
//

import UIKit

class GyroGraphViewController: GraphViewController {
    
    let gyroMin = NSTimeInterval(0.01)
    
    @IBOutlet weak var graphView: GraphView!
    
    override func startUpdatesWithSliderValue(sliderValue: Int) {
        let delta: NSTimeInterval = 0.005
        let updateInterval = gyroMin + delta * NSTimeInterval(sliderValue)
        
        let motionManager = (UIApplication.sharedApplication().delegate as! AppDelegate).sharedMotionManager
        
        if motionManager.gyroAvailable {
            motionManager.gyroUpdateInterval = updateInterval
            motionManager.startGyroUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {
                data, error in
                self.graphView.addX(data!.rotationRate.x, y: data!.rotationRate.y, z: data!.rotationRate.z)
                self.setLabelValueX(data!.rotationRate.x, y: data!.rotationRate.y, z: data!.rotationRate.z)
            })
        }
        
        updateIntervalLabel.text = NSString(format: "%f", updateInterval) as String
    }
    
    override func stopUpdates() {
        let motionManager = (UIApplication.sharedApplication().delegate as! AppDelegate).sharedMotionManager
        
        if motionManager.gyroActive {
            motionManager.stopGyroUpdates()
        }
    }

}
