
//
//  MonitoringInstancesTabController.swift
//  NagBar
//
//  Created by Volen Davidov on 31.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class MonitoringInstancesTabController: NSWindowController {

    @IBOutlet weak var refreshInterval: NSTextField!
    @IBOutlet weak var stepper: NSStepper!
    
    let refreshIntervalMinValue: Double = 15
    let refreshIntervalMaxValue: Double = 900
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set the stepper value; if we don't do this, refreshInterval field will be set to stepper.minValue (i.e. 15) on the first click of the stepper
        stepper.integerValue = Settings().integerForKey("refreshInterval")
        
        refreshInterval.stringValue = Settings().stringForKey("refreshInterval")!
    }
    
    @IBAction func stepperAction(_ sender: AnyObject) {
        stepper.minValue = refreshIntervalMinValue
        stepper.maxValue = refreshIntervalMaxValue
        
        refreshInterval.integerValue = stepper.integerValue
        
        Settings().setString(stepper.stringValue, forKey: "refreshInterval")
    }
}

class AcceptInvalidCertificatesButton : DefaultButton {
    override func performAction() {
        super.performAction()
        ConnectionManager.sharedInstance.update()
    }
}

class SavePasswordButton : DefaultButton {
    override func performAction() {
        super.performAction()
        
        if self.state == NSControl.StateValue.off {
            let monitoringInstances = MonitoringInstances().getAll()
            for (_, value) in monitoringInstances {
                // this will automatically delete the password if the save password option is disabled
                MonitoringInstances().updatePassword(monitoringInstance: value, password: value.password)
            }
        } else {
            let passwords = PasswordStore.sharedInstance.getAll()
            
            for (key, value) in passwords {
                let monitoringInstance = MonitoringInstances().getByKey(key)
                MonitoringInstances().updatePassword(monitoringInstance: monitoringInstance!, password: value)
            }
        }
    }
}
