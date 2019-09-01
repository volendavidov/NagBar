//
//  AcknowledgeWindow.swift
//  NagBar
//
//  Created by Volen Davidov on 31.08.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class AcknowledgeWindow: NSWindowController {
    
    @IBOutlet weak private var comment: NSTextField!
    
    var monitoringItems: Array<MonitoringItem> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.comment.stringValue = Settings().stringForKey("acknowledgementDefaultComment")!
    }
    
    @IBAction func buttonClicked(_ sender: NSButton) {
        if self.comment.stringValue == "" {
            NSSound.beep()
            return
        }
        
        let monitoringInstance = self.monitoringItems[0].monitoringInstance!
        
        monitoringInstance.monitoringProcessor().command().acknowledge(self.monitoringItems, comment: self.comment.stringValue)
        
        self.close()
    }
    
    @IBAction func cancelButtonClicked(_ sender: NSButton) {
        self.close()
    }
}
