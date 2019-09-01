//
//  AudibleAlarmsTabController.swift
//  NagBar
//
//  Created by Volen Davidov on 08.02.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class AudibleAlarmsTabController: NSWindowController {
    
    @IBOutlet weak var enableAudibleAlarms: NSButton!
    @IBOutlet weak var enableAudibleAlarmsCritical: NSButton!
    @IBOutlet weak var enableAudibleAlarmsWarning: NSButton!
    @IBOutlet weak var enableAudibleAlarmsDown: NSButton!
    @IBOutlet weak var enableAudibleAlarmsUnreachable: NSButton!
    @IBOutlet weak var enableAudibleAlarmsRecovery: NSButton!
    
    @IBOutlet weak var audibleAlarmsCriticalSoundFile: NSPopUpButton!
    @IBOutlet weak var audibleAlarmsWarningSoundFile: NSPopUpButton!
    @IBOutlet weak var audibleAlarmsDownSoundFile: NSPopUpButton!
    @IBOutlet weak var audibleAlarmsUnreachableSoundFile: NSPopUpButton!
    @IBOutlet weak var audibleAlarmsRecoverySoundFile: NSPopUpButton!
    
    func setPopupState(_ propertyName: String) {
        let popUpButton = self.value(forKey: propertyName) as! NSPopUpButton
        
        let filePath = Settings().valueForKey(propertyName) as! String
        
        if filePath == "" {
            popUpButton.selectItem(at: 0)
        } else {
            popUpButton.removeItem(at: 1)
            let fileStringArray = filePath.components(separatedBy: "/")
            popUpButton.insertItem(withTitle: fileStringArray.last!, at: 1)
            popUpButton.selectItem(at: 1)
        }
    }
    
    @IBAction func popupButtonFileSelector(_ sender: NSPopUpButton) {
        if sender.titleOfSelectedItem != "Default" {
            let fileSelectDialog = NSOpenPanel()
            
            // Enable the selection of files in the dialog.
            fileSelectDialog.canChooseFiles = true
            fileSelectDialog.allowedFileTypes = ["aiff", "wav", "mp3"]
            
            
            // Display the dialog. If the OK button was pressed, process the files.
            if fileSelectDialog.runModal() == NSApplication.ModalResponse.OK {
                // Get an array containing the full filenames of all
                // files and directories selected.
                let files = fileSelectDialog.urls
                sender.removeItem(at: 1)
                let fileStringArray = files[0].absoluteString.components(separatedBy: "/")
                sender.title = fileStringArray.last!
                
                Settings().setString(files[0].path, forKey: sender.identifier!.rawValue)
            }
        } else {
            sender.removeItem(at: 1)
            sender.insertItem(withTitle: "Custom", at: 1)
            Settings().setString("", forKey: sender.identifier!.rawValue)
        }
    }
}
