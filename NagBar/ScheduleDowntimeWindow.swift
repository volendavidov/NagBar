//
//  ScheduleDowntimeWindow.swift
//  NagBar
//
//  Created by Volen Davidov on 07.08.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class ScheduleDowntimeWindow : NSWindowController {
    
    @IBOutlet weak private var comment: NSTextField!
    @IBOutlet weak private var startTime: NSTextField!
    @IBOutlet weak private var endTime: NSTextField!
    @IBOutlet weak private var hours: NSTextField!
    @IBOutlet weak private var minutes: NSTextField!
    @IBOutlet weak private var type: NSPopUpButton!
    
    var monitoringItems: Array<MonitoringItem> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hours.isEnabled = false
        minutes.isEnabled = false
        
        let monitoringInstance = self.monitoringItems[0].monitoringInstance
        
        let time = monitoringInstance!.monitoringProcessor().command().getTime(self.monitoringItems)
        
        time.then { startTime, endTime -> Void in
            self.startTime.stringValue = startTime
            self.endTime.stringValue = endTime
        }.catch { _ in
            
        }
        
        let hourFormatter = HourNumberFormatter()
        hours.formatter = hourFormatter
        let minuteFormatter = MinuteNumberFormatter()
        minutes.formatter = minuteFormatter
        
        self.comment.stringValue = Settings().stringForKey("scheduleDowntimeDefaultComment")!
    }
    
    @IBAction func buttonClicked(_ sender: NSButton) {
        
        if self.comment.stringValue == "" {
            NSBeep()
            return
        }
        
        let typeString = String(self.type.selectedItem!.tag)
        
        let monitoringInstance = self.monitoringItems[0].monitoringInstance!
        
        monitoringInstance.monitoringProcessor().command().scheduleDowntime(self.monitoringItems, from: self.startTime.stringValue, to: self.endTime.stringValue, comment: self.comment.stringValue, type: typeString, hours: self.hours.stringValue, minutes: self.minutes.stringValue)
        
        self.close()
    }
    
    @IBAction func cancelButtonClicked(_ sender: NSButton) {
        self.close()
    }
    
    @IBAction func popupButtonClicked(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem == 1 {
            hours.isEnabled = true
            minutes.isEnabled = true
            hours.stringValue = "2"
            minutes.stringValue = "0"
        } else {
            hours.isEnabled = false
            minutes.isEnabled = false
            hours.stringValue = ""
            minutes.stringValue = ""
        }
    }
}

class HourNumberFormatter : NumberFormatter {
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.characters.count == 0 {
            return true
        }
        
        if partialString.characters.count > 2 {
            NSBeep()
            return false
        }
        
        if let hourEntered = Int(partialString) {
            if hourEntered < 0 {
                NSBeep()
                return false
            }
        } else {
            NSBeep()
            return false
        }
        
        return true
    }
}

class MinuteNumberFormatter : NumberFormatter {
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.characters.count == 0 {
            return true
        }
        
        if partialString.characters.count > 3 {
            NSBeep()
            return false
        }
        
        if let minutesEntered = Int(partialString) {
            if minutesEntered < 0 || minutesEntered > 59 {
                NSBeep()
                return false
            }
        } else {
            NSBeep()
            return false
        }
        
        return true
    }
}
