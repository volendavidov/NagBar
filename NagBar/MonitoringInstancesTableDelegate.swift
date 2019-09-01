//
//  MonitoringInstancesTableDelegate.swift
//  NagBar
//
//  Created by Volen Davidov on 31.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class MonitoringInstancesTableDelegate : NSObject, NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let tableColumn = tableColumn as? MonitoringInstancesTableColumn
        return tableColumn!.createViewForRow(row)
    }
}

class MITextField : NSTextField, NSTextFieldDelegate {
    init() {
        super.init(frame: CGRect.zero)
        isBezeled = false
        isBordered = false
        drawsBackground = false
        delegate = self
        self.cell?.lineBreakMode = .byTruncatingTail
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(coder: coder)
    }
}

class MIUsernameTextField: MITextField {
    override func textDidEndEditing(_ obj: Notification) {
        let monitoringInstance = MonitoringInstances().getById(self.tag)
        MonitoringInstances().updateUsername(monitoringInstance: monitoringInstance, username: self.stringValue)
    }
}

class MIPasswordTextField: NSSecureTextField, NSTextFieldDelegate {
    init() {
        super.init(frame: CGRect.zero)
        isBezeled = false
        isBordered = false
        drawsBackground = false
        delegate = self
        self.cell?.lineBreakMode = .byTruncatingTail
    }
    
    required convenience init?(coder: NSCoder) {
        self.init(coder: coder)
    }
    
    override func textDidEndEditing(_ obj: Notification) {
        let monitoringInstance = MonitoringInstances().getById(self.tag)
        MonitoringInstances().updatePassword(monitoringInstance: monitoringInstance, password: self.stringValue)
    }
}

class MIURLTextField: MITextField {
    override func textDidEndEditing(_ obj: Notification) {
        let monitoringInstance = MonitoringInstances().getById(self.tag)
        MonitoringInstances().updateUrl(monitoringInstance: monitoringInstance, url: self.stringValue)
    }
}

class MINameTextField: MITextField {
    var nameTextOrig: String?
    
    override func textDidBeginEditing(_ obj: Notification) {
        nameTextOrig = self.stringValue
    }
    
    override func textDidEndEditing(_ obj: Notification) {
        
        // this check is needed to prevent exceptions when nameTextOrig is nil and the following case:
        // 1. edit some name in the list
        // 2. click outside the text box to trigger save of the value
        // 3. click in the name text box and DO NOT make change
        // 4. click outside the text box
        if nameTextOrig == nil {
            return
        }
        
        // First check if there is already a monitoring instance with the entered name. We should not add it if it already exists. After that check if the name entered for monitoring instance is empty.
        if MonitoringInstances().getByKey(self.stringValue) != nil {
            let messageText = NSLocalizedString("monitoringInstanceExistsMessage", comment: "")
            let informativeText = String(format: NSLocalizedString("monitoringInstanceExistsInformative", comment: ""), self.stringValue, self.stringValue)
            NagBarAlert().showWarningAlert(messageText, informativeText: informativeText)
            
            stringValue = nameTextOrig!
        } else if self.stringValue == "" {
            let messageText = NSLocalizedString("monitoringInstanceEmptyMessage", comment: "")
            let informativeText = NSLocalizedString("monitoringInstanceEmptyInformative", comment: "")
            NagBarAlert().showWarningAlert(messageText, informativeText: informativeText)
            
            stringValue = nameTextOrig!
        } else {
            let monitoringInstance = MonitoringInstances().getByKey(nameTextOrig!)
            MonitoringInstances().updateName(monitoringInstance: monitoringInstance!, name: self.stringValue)
            // We also want to refresh the table after the editing has finished. The reason is the following case which triggers a bug:
            // 1. Add new monitoring instance
            // 2. Consider that it is the last in the list; i.e there are no monitoring instances with names after New (O, P, R, ...)
            // 2. Rename it to name which precedes the previous item (the one before "New")
            // 3. Click on the "Enabled" checkbox
            // 4. You will see that the status will change for the previous item (the one before "New")
            // So, this has something to do with the index of the row
            Foundation.NotificationCenter.default.post(name: Notification.Name(rawValue: "MonitoringInstanceNameChanged"), object: nil)
        }
    }
}

protocol MonitoringInstancesTableColumn {
    func createViewForRow(_ row: Int) -> NSView
}

class MINameTableColumn : NSTableColumn, MonitoringInstancesTableColumn  {
    func createViewForRow(_ row: Int) -> NSView {
        let text = MINameTextField()
        text.stringValue = MonitoringInstances().getKeyById(row)
        return text
    }
}

class MIEnabledTableColumn : NSTableColumn, MonitoringInstancesTableColumn  {
    
    func createViewForRow(_ row: Int) -> NSView {
        let button = NSButton()
        button.setButtonType(.switch)
        button.title = ""
        button.target = self
        button.action = #selector(MIEnabledTableColumn.checkButtonClick(_:))
        
        // we set a tag for the checkbox, because the checkbox can be clicked without a row being clicked and then we do not know for which row the checkbox was clicked
        button.tag = row
        button.state = NSControl.StateValue(rawValue: MonitoringInstances().getById(row).enabled)
        
        return button
    }
    
    @objc func checkButtonClick(_ sender: NSButton) {
        let monitoringInstance = MonitoringInstances().getById(sender.tag)
        MonitoringInstances().updateEnabled(monitoringInstance: monitoringInstance, enabled: sender.state.rawValue)
        
        if sender.state == NSControl.StateValue.off {
            self.connectionStateUnknown(sender.tag)
        } else {
            self.connectionStateChecking(sender.tag)
        }
    }
    
    private func setConnectionState(_ tag: Int, text: String, image: String) {
        // 2nd column is the status column
        let view = tableView?.view(atColumn: 2, row: tag, makeIfNecessary: false)
        for subview in view!.subviews {
            if subview is NSTextField {
                let textField = subview as! NSTextField
                textField.stringValue = NSLocalizedString(text, comment: "")
            } else if subview is NSImageView {
                let imageView = subview as! NSImageView
                imageView.image = NSImage.init(named: image)
            }
        }
    }
    
    func connectionStateUnknown(_ tag: Int) {
        self.setConnectionState(tag, text: "unknown", image: "NSStatusNone")
    }
    
    func connectionStateChecking(_ tag: Int) {
        self.setConnectionState(tag, text: "checking", image: "NSStatusNone")
        
        let monitoringInstance = MonitoringInstances().getById(tag)
        
        _ = monitoringInstance.monitoringProcessor().httpClient().checkConnection().done { result -> Void in
            
            if result {
                self.setConnectionState(tag, text: "ok", image: "NSStatusAvailable")
            } else {
                self.setConnectionState(tag, text: "error", image: "NSStatusUnavailable")
            }
        }
    }
}

class MIStatusTableColumn : NSTableColumn, MonitoringInstancesTableColumn  {
    func createViewForRow(_ row: Int) -> NSView {
        
        let statusView = NSView.init(frame: NSMakeRect(0, 0, 75, 15))
        
        let text = NSTextField.init(frame: NSMakeRect(15, 5, 60, 15))
        text.isEditable = false
        text.isBezeled = false
        text.isBordered = false
        text.drawsBackground = false
        
        let image = NSImageView.init(frame: NSMakeRect(0, 5, 15, 15))
        
        let monitoringInstance = MonitoringInstances().getById(row)
        
        if monitoringInstance.enabled == 0 {
            image.image = NSImage.init(named: "NSStatusNone")
            text.stringValue = NSLocalizedString("unknown", comment: "")
            statusView.addSubview(image)
            statusView.addSubview(text)
            return statusView
        } else {
            image.image = NSImage.init(named: "NSStatusNone")
            text.stringValue = NSLocalizedString("checking", comment: "")
            statusView.addSubview(image)
            statusView.addSubview(text)
        }
        
        _ = monitoringInstance.monitoringProcessor().httpClient().checkConnection().done { result -> Void in
            
            if result {
                image.image = NSImage.init(named: "NSStatusAvailable")
                text.stringValue = NSLocalizedString("ok", comment: "")
            } else {
                image.image = NSImage.init(named: "NSStatusUnavailable")
                text.stringValue = NSLocalizedString("error", comment: "")
            }
        }
        
        statusView.addSubview(image)
        statusView.addSubview(text)
        
        return statusView
    }
}

class MIURLTableColumn : NSTableColumn, MonitoringInstancesTableColumn  {
    func createViewForRow(_ row: Int) -> NSView {
        let text = MIURLTextField()
        text.tag = row
        text.stringValue = MonitoringInstances().getById(row).url
        
        return text
    }
}

class MIUsernameTableColumn : NSTableColumn, MonitoringInstancesTableColumn  {
    func createViewForRow(_ row: Int) -> NSView {
        let text = MIUsernameTextField()
        text.tag = row
        text.stringValue = MonitoringInstances().getById(row).username
        
        return text
    }
}

class MIPasswordTableColumn : NSTableColumn, MonitoringInstancesTableColumn  {
    func createViewForRow(_ row: Int) -> NSView {
        let text = MIPasswordTextField()
        text.tag = row
        
        text.stringValue = MonitoringInstances().getById(row).password
        
        return text
    }
}

class MITypeTableColumn : NSTableColumn, MonitoringInstancesTableColumn  {
    func createViewForRow(_ row: Int) -> NSView {
        let type = NSPopUpButton()
        
        type.addItems(withTitles: MonitoringInstanceType.allValues)
        type.target = self
        type.tag = row
        type.action = #selector(MITypeTableColumn.popupButtonClick(_:))
        
        type.selectItem(withTitle: MonitoringInstances().getById(row).type.rawValue)
        
        return type
    }
    
    @objc func popupButtonClick(_ sender: NSPopUpButton) {
        let monitoringInstance = MonitoringInstances().getById(sender.tag)
        MonitoringInstances().updateType(monitoringInstance: monitoringInstance, type: MonitoringInstanceType(rawValue: sender.title)!)
    }
}
