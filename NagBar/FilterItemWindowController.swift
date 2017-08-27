//
//  FilterItemWindowController.swift
//  NagBar
//
//  Created by Volen Davidov on 23.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class FilterItemWindowController: NSWindowController, NSTextFieldDelegate {
    @IBOutlet weak var host: NSTextField!
    @IBOutlet weak var service: NSTextField!
    
    @IBOutlet weak var hostDown: NSButton!
    @IBOutlet weak var hostUnreachable: NSButton!
    @IBOutlet weak var hostPending: NSButton!
    
    @IBOutlet weak var critical: NSButton!
    @IBOutlet weak var warning: NSButton!
    @IBOutlet weak var unknown: NSButton!
    @IBOutlet weak var pending: NSButton!
    
    // filterItemKey indicates whether we create a new Filter Item or edit an existing one. If it is nil, we are creating a new one. If it is set, we are editing an existing one.
    var filterItemKey: String?
    
    override func awakeFromNib() {
        
        // If filterItemKey is nil, then this is a new entry, we do not have to load values in the window and we just have to disable the service status buttons.
        if filterItemKey == nil {
            setServiceButtonsEnabled(false)
            return
        }
        
        let filterItem = FilterItems().getByKey(filterItemKey!)
        
        // load host and service values
        host.stringValue = filterItem!.host
        service.stringValue = filterItem!.service
        
        // load the status values
        let serviceStatusMapping: Dictionary<Int, String> = [1: "pending", 4: "warning", 8: "unknown", 16: "critical"]
        let hostStatusMapping: Dictionary<Int, String> = [1: "hostPending", 4: "hostDown", 8: "hostUnreachable"]
        
        // if there is more than one letter in the "service" field, enable the service buttons
        if filterItem!.service.characters.count != 0 {
            setStates(filterItem!, mapping: serviceStatusMapping)
            setHostButtonsEnabled(false)
        } else {
            setStates(filterItem!, mapping: hostStatusMapping)
            setServiceButtonsEnabled(false)
        }
    }
    
    private func setStates(_ filterItem: FilterItem, mapping: Dictionary<Int, String>) {
        var status = filterItem.status
        // loop over the sorted mapping - dictionaries do not keep the order of the keys
        for (key, value) in mapping.sorted(by: {$0.key > $1.key}) {
            let object = self.value(forKey: value) as! NSButton
            if status/key >= 1 {
                object.isEnabled = true
                status -= key
            } else {
                object.state = NSOffState
            }
        }
    }
    
    @IBAction func cancelButtonClick(_ sender: AnyObject) {
        window?.close()
    }
    
    @IBAction func saveButtonClick(_ sender: AnyObject) {
        
        let key = FilterItems.generateKey(host.stringValue, service: service.stringValue)
        
        var status: Int?
        if service.stringValue.characters.count != 0 {
            status = (Bool(critical.state) ? 16 : 0) + (Bool(unknown.state) ? 8 : 0) + (Bool(warning.state) ? 4 : 0) + (Bool(pending.state) ? 1 : 0)
        } else {
            status = (Bool(hostUnreachable.state) ? 8 : 0) + (Bool(hostDown.state) ? 4 : 0) + (Bool(hostPending.state) ? 1 : 0)
        }
        
        let filterItem = FilterItem().initDefault(host: host.stringValue, service: service.stringValue, status: status!)
        
        // Do not allow something with empty host and service to be saved
        if key == "" {
            return
        }
        
        // Then check if the item already exists. It will in the case of an existing item being edited. If filterItemKey was set (i.e. we are editing FilterItem), then it is OK to continue and overwrite it.
        if FilterItems().getKeys().contains(key) && filterItemKey == nil {
            
            let alert = NagBarAlert()
            
            var informativeText: String?
            
            if service.stringValue == "" {
                informativeText = String(format:NSLocalizedString("filterAlreadyExistsHost", comment: ""), host.stringValue)
            } else {
                informativeText = String(format:NSLocalizedString("filterAlreadyExistsService", comment: ""), host.stringValue, service.stringValue)
            }
            
            alert.showWarningAlert(NSLocalizedString("filterAlreadyExists", comment: ""), informativeText: informativeText!)
            
            return
        }
        
        // if filterItemKey is nil, then a new FilterItem has to be created
        if filterItemKey == nil {
            FilterItems().insert(key: key, value: filterItem)
            window?.close()
            return
        }
        
        // The easiest way to update the status is by removing and re-addeding the FilterItem. This
        // also covers the case where the host or the service names are changed.
        FilterItems().removeByKey(filterItemKey!)
        FilterItems().insert(key: key, value: filterItem)
        
        // After closing, an NSWindowWillCloseNotification is automatically posted and observed by FilterOptionsTabController
        window?.close()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        // react only on changed service field
        if (obj.object as AnyObject).identifier != "service" {
            return
        }
        
        if (obj.object as AnyObject).stringValue == "" {
            setHostButtonsEnabled(true)
            setServiceButtonsEnabled(false)
        } else {
            setHostButtonsEnabled(false)
            setServiceButtonsEnabled(true)
        }
    }
    
    private func setHostButtonsEnabled(_ enabled: Bool) {
        hostDown.isEnabled = enabled
        hostUnreachable.isEnabled = enabled
        hostPending.isEnabled = enabled
    }
    
    private func setServiceButtonsEnabled(_ enabled: Bool) {
        critical.isEnabled = enabled
        warning.isEnabled = enabled
        unknown.isEnabled = enabled
        pending.isEnabled = enabled
    }
}
