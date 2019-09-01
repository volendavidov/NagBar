//
//  AppDelegate.swift
//  NagBar
//
//  Created by Volen Davidov on 10.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var preferencesWindow: PreferencesWindowController?
    
    var passwordWindow: PasswordPromptController?
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // init the configuration
        InitConfig().initConfig()
        
        // check if the Dock icon should be displayed
        if !Settings().boolForKey("showDockIcon") {
            NSApp.setActivationPolicy(.accessory)
        }
        
        // check for new versions
        if Settings().boolForKey("newVersionCheck") {
            CheckNewVersion().checkNewVersion()
        }
        
        // ask for passwords in case they are not saved
        if !Settings().boolForKey("savePassword") && MonitoringInstances().getAllEnabled().count > 0 {
            self.showPasswordPrompt()
        }
        
        self.refreshStatusData()
        let timer = Timer(timeInterval: Settings().doubleForKey("refreshInterval"), target: self, selector: #selector(self.refreshStatusData), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    @IBAction func openPreferences(_ sender: AnyObject) {
        if self.preferencesWindow == nil {
            self.preferencesWindow = PreferencesWindowController(windowNibName: "PreferencesWindow")
        }
        self.preferencesWindow!.showWindow(self)
    }
    
    @objc func refreshStatusData() {
        LoadMonitoringData().refreshStatusData()
    }
    
    func showPasswordPrompt() {
        if self.passwordWindow == nil {
            self.passwordWindow = PasswordPromptController(windowNibName: "PasswordPrompt")
        }
        self.passwordWindow!.showWindow(self)
    }
}
