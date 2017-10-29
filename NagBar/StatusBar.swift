//
//  StatusBar.swift
//  NagBar
//
//  Created by Volen Davidov on 28.02.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class StatusBar : NSObject {
    
    // only a single instance of the status bar is needed
    private static let statusBar = StatusBar()
    
    class func get() -> StatusBar {
        return self.statusBar
    }
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    private var statusItemFailed: NSStatusItem?
    
    private var observer: AnyObject?
    
    private var results: Array<MonitoringItem>?
    private var oldResults: Array<MonitoringItem>?
    
    private var statusPanel: StatusPanel?
    
    func load(_ results: Array<MonitoringItem>, failedMonitoringInstances: FailedMonitoringInstances) {
        
        self.results = results
        
        // reload the status panel in case it is opened
        self.refreshStatusPanel()
        
        // show the failed monitoring instances status bar
        self.failedMonitoringInstancesView(failedMonitoringInstances)
        
        // init the status bar view
        let statusItemView = StatusItemView()
        
        statusItemView.statusItem = self.statusItem
        
        self.statusItem.view = statusItemView
        
        if Settings().boolForKey("showExtendedStatusInformation") {
            statusItemView.setStatusItemTitle(self.resultsToCodes(results))
        } else {
            statusItemView.setStatusItemTitle(NSLocalizedString("totalCount", comment: "") + " " + String(results.count))
        }
        
        // finally animate the status bar (shake, change color and etc.)
        self.animateStatusBar()
        
        oldResults = results
    }
    
    private func failedMonitoringInstancesView(_ failedMonitoringInstances: FailedMonitoringInstances) {
        
        if failedMonitoringInstances.count > 0 {
            self.statusItemFailed = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        } else {
            self.statusItemFailed = nil
            return
        }
        
        // we want to use the default NSCaution image, but we have to change its size
        
        let cautionImage = NSImage(named: "NSCaution")
        cautionImage?.size = CGSize(width: 18, height: 18)
        
        statusItemFailed!.image = cautionImage
        
        let menu = NSMenu()
        
        for (failedInstance, reason) in failedMonitoringInstances {
            
            var menuText: String?
            
            switch reason {
            case .wrongCredentials:
                menuText = String(format: NSLocalizedString("monitoringInstanceFailedWrongCredentials", comment: ""), failedInstance.name)
            case .ssl:
                menuText = String(format: NSLocalizedString("monitoringInstanceFailedSSL", comment: ""), failedInstance.name)
            default:
                menuText = String(format: NSLocalizedString("monitoringInstanceFailedUnknown", comment: ""), failedInstance.name)
            }
            menu.addItem(withTitle: menuText!, action: nil, keyEquivalent: "")
        }
        
        statusItemFailed!.menu = menu
    }
    
    func onClick() {
        NSApp.activate(ignoringOtherApps: true)
        self.loadStatusPanel()
    }
    
    private func refreshStatusPanel() {
        // refresh the status panel if it is opened, it won't be opened if self.statusPanel is nil
        if self.statusPanel != nil {
            self.loadStatusPanel()
        }
    }
    
    private func loadStatusPanel() {
        // This is an ugly workaround to get the position of the status bar
        let frameOrigin = (self.statusItem.value(forKey: "window")! as AnyObject).frame

        // If there is an existing panel (this will be the case when the
        // panel is already opened and is just being refreshed or if the panel is again
        // already opened and the status bar is clicked on second time), close it
        self.statusPanel?.panel?.close()
        self.statusPanel = nil
        
        self.statusPanel = StatusPanel(results: self.results!, panelBounds: frameOrigin!)
        observer = Foundation.NotificationCenter.default.addObserver(forName: NSNotification.Name.NSWindowDidResignKey, object: nil, queue: nil, using: {_ in
            // dismiss the panel only if another application is in foreground
            // otherwise the panel will be dismissed also on functions which open a modal inside the app
            // (e.g. acknowledge, schedule downtime) and when submitting the modal, the error
            // "sent to deallocated instance" will occur because the StatusPanel keeps reference to
            // these modals
            if NSWorkspace.shared().frontmostApplication!.bundleIdentifier! != Bundle.main.bundleIdentifier! {
                self.statusPanel?.panel?.close()
                self.statusPanel = nil
                Foundation.NotificationCenter.default.removeObserver(self.observer as! NSObjectProtocol)
            }
            }
        )
        
        self.statusPanel!.load()
    }
    
    private func resultsToCodes(_ results: Array<MonitoringItem>) -> String {
        var cCount = 0
        var wCount = 0
        var uCount = 0
        var pCount = 0
        var oCount = 0
        var unreachableCount = 0
        var downCount = 0
        var upCount = 0
        
        for i in results {
            switch i.status {
            case "CRITICAL":
                cCount += 1
            case "WARNING":
                wCount += 1
            case "UNKNOWN":
                uCount += 1
            case "PENDING":
                pCount += 1
            case "UP":
                upCount += 1
            case "OK":
                oCount += 1
            case "UNREACHABLE":
                unreachableCount += 1
            case "DOWN":
                downCount += 1
            default: break
            }
        }
        
        // break up the following statements to avoid compiler error "Expression was too complex to be solved in reasonable time"
        let criticalText = Bool(cCount) ? "C:" + String(cCount) : ""
        let warningText = Bool(wCount) ? " W:" + String(wCount) : ""
        let unknownText = Bool(uCount) ? " U:" + String(uCount) : ""
        let pendingText = Bool(pCount) ? " P:" + String(pCount) : ""
        let okText = Bool(oCount) ? " O:" + String(oCount) : ""
        let unreachableText = Bool(unreachableCount) ? " UR:" + String(unreachableCount) : ""
        let downText = Bool(downCount) ? " D:" + String(downCount) : ""
        let upText = Bool(upCount) ? " UP:" + String(upCount) : ""
        
        let text = criticalText + warningText + unknownText + pendingText + okText + unreachableText + downText + upText
        
        if text == "" {
            return NSLocalizedString("noAlarms", comment: "")
        } else {
            return text
        }
    }
    
    private func animateStatusBar() {
        
        if !Settings().boolForKey("flashStatusBar") {
            return
        }
        
        let animateType = Settings().integerForKey("flashStatusBarType")
        
        let animateTypes = [2: LightFlashStatusBar(), 3: DarkFlashStatusBar()]
        
        animateTypes[animateType]?.animate(oldResults: self.oldResults, newResults: self.results)
    }
}

