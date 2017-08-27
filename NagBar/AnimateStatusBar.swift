//
//  AnimateStatusBar.swift
//  NagBar
//
//  Created by Volen Davidov on 23.04.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

protocol AnimateStatusBar {
    func animate(oldResults: Array<MonitoringItem>?, newResults: Array<MonitoringItem>?)
}

class AnimateStatusBarBase : AnimateStatusBar {
    
    private var oldResults:  Array<MonitoringItem>?
    private var newResults:  Array<MonitoringItem>?
    
    enum TriggerType {
        case recovery
        case alarm
        case none
    }
    
    func animate(oldResults: Array<MonitoringItem>?, newResults: Array<MonitoringItem>?) {
        
        self.oldResults = oldResults
        self.newResults = newResults
        
        switch self.trigger() {
        case .alarm:
            self.alarmAnimation()
            break
        case .recovery:
            self.recoveryAnimation()
            break
        case .none:
            break
        }
    }
    
    fileprivate func trigger() -> TriggerType {
        
        guard let newResults = self.newResults else {
            return .none
        }
        
        guard let oldResults = self.oldResults else {
            return .none
        }
        
        if oldResults.count < newResults.count {
            return .alarm
        }
        
        if oldResults.count > newResults.count {
            return .recovery
        }
        
        if oldResults.count == newResults.count {
            for (index,_) in oldResults.enumerated() {
                let currentMonitoringItem = oldResults[index]
                let oldMonitoringItem = newResults[index]
                
                if currentMonitoringItem.uniqueIdentifier() != oldMonitoringItem.uniqueIdentifier() {
                    return .alarm
                }
            }
        }
        
        return .none
    }
    
    fileprivate func alarmAnimation() {
        preconditionFailure("This method must be overridden")
    }
    
    fileprivate func recoveryAnimation() {
        preconditionFailure("This method must be overridden")
    }
}

class LightFlashStatusBar : AnimateStatusBarBase {
    override func alarmAnimation() {
        self.flashStatusBar(NSColor(calibratedRed: 1.0, green: 0.504, blue: 0.504, alpha: 0.6))
    }
    
    override func recoveryAnimation() {
        self.flashStatusBar(NSColor(calibratedRed: 0.288, green: 1.0, blue: 0.555, alpha: 0.6))
    }
    
    fileprivate func flashStatusBar(_ color: NSColor) {
        let layer = StatusBar.get().statusItem.view!.layer!
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = layer.backgroundColor
        animation.toValue = color.cgColor
        animation.duration = 0.5
        animation.autoreverses = true
        animation.repeatCount = 10
        
        layer.add(animation, forKey: "backgroundColor")
    }
}

class DarkFlashStatusBar : LightFlashStatusBar {
    override func alarmAnimation() {
        self.flashStatusBar(NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.6))
    }
    
    override func recoveryAnimation() {
        self.flashStatusBar(NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.6))
    }
}

class ShakeStatusBar : AnimateStatusBarBase {
    
    override func alarmAnimation() {
        self.shake()
    }
    
    override func recoveryAnimation() {
        self.shake()
    }
    
    private func shake() {
        let layer = StatusBar.get().statusItem.view!.layer!
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.beginTime = CACurrentMediaTime()
        animation.duration = 0.1
        animation.autoreverses = true
        animation.fromValue = -5
        animation.toValue = 5
        animation.repeatCount = 5
        layer.add(animation, forKey: "shakeAnimation")
    }
}
