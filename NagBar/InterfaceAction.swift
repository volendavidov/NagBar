//
//  NagBarTabController.swift
//  NagBar
//
//  Created by Volen Davidov on 14.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

protocol InterfaceAction {
    func performAction()
}

class DefaultButton : NSButton, InterfaceAction {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        guard let identifier = self.identifier else {
            NSLog("Button identifier not defined")
            return
        }
        
        if Settings().boolForKey(identifier.rawValue) {
            self.state = NSControl.StateValue.on
        } else {
            self.state = NSControl.StateValue.off
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        self.performAction()
    }
    
    func performAction() {
        guard let identifier = self.identifier else {
            NSLog("Button identifier not defined")
            return
        }
        
        if(self.state == NSControl.StateValue.on) {
            Settings().setBool(true, forKey: identifier.rawValue)
        } else {
            Settings().setBool(false, forKey: identifier.rawValue)
        }
    }
}

class DefaultPopUpButton : NSPopUpButton {
    
    var popUpButtons: Dictionary <String, Dictionary<Int, String>> {
        return [
            "flashStatusBarType": [1: "Shake", 2: "Flash", 3: "Bright Flash"],
            "statusInformationLength": [100: "100", 200: "200", 300: "300", 400: "400", 500: "500", 600: "600", 700: "700"],
            "sortColumn": [0: "None", 1: "Host", 2: "Service", 3: "Status", 4: "Last Check", 5: "Attempt", 6: "Duration"],
            "sortOrder": [1: "Ascending", 2: "Descending"]
        ]
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        guard let identifier = self.identifier else {
            NSLog("Button identifier not defined")
            return
        }
        
        guard let popUpButtonDict = self.popUpButtons[identifier.rawValue] else {
            NSLog("Button identifier " + identifier.rawValue + " not found in dictionary")
            return
        }
        
        for i in popUpButtonDict {
            if (Settings().integerForKey(identifier.rawValue) == i.0) {
                self.selectItem(withTitle: i.1)
            }
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        self.performAction()
    }
    
    func performAction() {
        guard let identifier = self.identifier else {
            NSLog("Button identifier not defined")
            return
        }
        
        for (popUpButton, values) in self.popUpButtons {
            if identifier.rawValue != popUpButton {
                continue
            }
            
            for (id, text) in values {
                if self.titleOfSelectedItem == text {
                    Settings().setInteger(id, forKey: popUpButton)
                }
            }
        }
    }
}

class DefaultColorWell : NSColorWell {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        guard let identifier = self.identifier else {
            NSLog("Color well identifier not defined")
            return
        }
        
        guard let colorWheelColors = Settings().stringForKey(identifier.rawValue) else {
            NSLog("Color well " + identifier.rawValue + " not found in dictionary")
            return
        }
        
        let colorArr = colorWheelColors.components(separatedBy: ",")
        
        let red = CGFloat(Double(colorArr[0])!)
        let green = CGFloat(Double(colorArr[1])!)
        let blue = CGFloat(Double(colorArr[2])!)
        let alpha = CGFloat(Double(colorArr[3])!)
        self.color = NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
    }
    
    override func deactivate() {
        super.deactivate()
        
        let stringToSave = String(format: "%.3f", self.color.redComponent) + ","
            + String(format: "%.3f", self.color.greenComponent) + ","
            + String(format: "%.3f", self.color.blueComponent) + ",1.0"
        
        Settings().setString(stringToSave, forKey: self.identifier?.rawValue ?? "")
    }
}
