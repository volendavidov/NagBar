//
//  CommandsTabController.swift
//  NagBar
//
//  Created by Volen Davidov on 16.02.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class CommandsTabController: NSWindowController, NSControlTextEditingDelegate {
    @IBOutlet weak var acknowledgementDefaultComment: NSTextField!
    @IBOutlet weak var scheduleDowntimeDefaultComment: NSTextField!
    
    override func awakeFromNib() {
        acknowledgementDefaultComment.stringValue = Settings().stringForKey("acknowledgementDefaultComment")!
        scheduleDowntimeDefaultComment.stringValue = Settings().stringForKey("scheduleDowntimeDefaultComment")!
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let key = (obj.object as! NSTextField).identifier!
        let value = (obj.object as! NSTextField).stringValue
        
        Settings().setString(value, forKey: key.rawValue)
    }
}
