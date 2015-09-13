//
//  DeviceMotionGraphViewController.swift
//  MotionGraphSwift
//
//  Created by Kent Liau on 9/4/15.
//  Copyright © 2015 Kent Liau. All rights reserved.
//

import UIKit

class DeviceMotionGraphViewController: GraphViewController {

    let deviceMotionMin: NSTimeInterval = 0.01
    
    enum DeviceMotionGraphType: Int {
        case Attitude = 0
        case RotationRate
        case Gravity
        case UserAcceleration
    }
    
    @IBOutlet var graphViews: [GraphView]!
    
    @IBOutlet weak var graphLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var graphTitles = ["deviceMotion.attitude", "deviceMotion.rotationRate", "deviceMotion.gravity", "deviceMotion.userAcceleration"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showGraphAtIndex(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        showGraphAtIndex(sender.selectedSegmentIndex)
    }
    
    func showGraphAtIndex(selectedIndex: Int) {
        for (idx, graphView) in graphViews.enumerate() {
            let hidden = (idx != selectedIndex)
            graphView.hidden = hidden
        }

        graphLabel.text = graphTitles[selectedIndex]
    }
    
    override func startUpdatesWithSliderValue(sliderValue: Int) {

        let delta: NSTimeInterval = 0.005
        let updateInterval: NSTimeInterval = deviceMotionMin + delta * NSTimeInterval(sliderValue)
        
        let motionManager = (UIApplication.sharedApplication().delegate as! AppDelegate).sharedMotionManager
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = updateInterval
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {
                data, error in
                self.graphViews[DeviceMotionGraphType.Attitude.rawValue].addX(data!.attitude.roll, y: data!.attitude.pitch, z: data!.attitude.yaw)
                self.graphViews[DeviceMotionGraphType.RotationRate.rawValue].addX(data!.rotationRate.x, y: data!.rotationRate.y, z: data!.rotationRate.z)
                self.graphViews[DeviceMotionGraphType.Gravity.rawValue].addX(data!.gravity.x, y: data!.gravity.y, z: data!.gravity.z)
                self.graphViews[DeviceMotionGraphType.UserAcceleration.rawValue].addX(data!.userAcceleration.x, y: data!.userAcceleration.y, z: data!.userAcceleration.z)
                
                switch self.segmentedControl.selectedSegmentIndex {
                    case DeviceMotionGraphType.Attitude.rawValue:
                        self.setLabelValueRoll(data!.attitude.roll, pitch: data!.attitude.pitch, yaw: data!.attitude.yaw)
                    case DeviceMotionGraphType.RotationRate.rawValue:
                        self.setLabelValueX(data!.rotationRate.x, y:data!.rotationRate.y, z:data!.rotationRate.z)
                    case DeviceMotionGraphType.Gravity.rawValue:
                        self.setLabelValueX(data!.gravity.x, y:data!.gravity.y, z:data!.gravity.z)
                    case DeviceMotionGraphType.UserAcceleration.rawValue:
                        self.setLabelValueX(data!.userAcceleration.x, y:data!.userAcceleration.y, z:data!.userAcceleration.z)
                    default: break
                }
                
            })
        }

        graphLabel.text = graphTitles[segmentedControl.selectedSegmentIndex]
        updateIntervalLabel.text = NSString(format: "%f", updateInterval) as String

    }
    
    override func stopUpdates() {
        let motionManager = (UIApplication.sharedApplication().delegate as! AppDelegate).sharedMotionManager
        if motionManager.deviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    

}
