//
//  PasswordPromptController.swift
//  NagBar
//
//  Created by Volen Davidov on 02.05.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa
import Alamofire

class PasswordPromptController : NSWindowController {
    
    @IBOutlet weak fileprivate var okButton: NSButton!
    @IBOutlet weak fileprivate var passwordField: NSSecureTextField!
    @IBOutlet weak fileprivate var progressIndicator: NSProgressIndicator!
    @IBOutlet weak fileprivate var textField: NSTextField!

    private var currentMonitoringInstance: MonitoringInstance?
    
    override func awakeFromNib() {
        _ = self.nextMonitoringInstance()
        
        self.textField.stringValue = String(format:NSLocalizedString("pleaseEnterPassword", comment: ""), self.currentMonitoringInstance!.name)
    }
    
    /**
     * Set the next monitoring instance. Return false if there is no next monitoring instance.
     */
    private func nextMonitoringInstance() -> Bool {
        
        let enabledMonitoringInstances = MonitoringInstances().getAllEnabled()
        let monitoringInstances = Array(enabledMonitoringInstances.keys.sorted())

        if self.currentMonitoringInstance == nil {
            if monitoringInstances.count > 0 {
                self.currentMonitoringInstance = enabledMonitoringInstances[monitoringInstances[0]]
                return true
            }
        }
        
        for (index, monitoringInstance) in monitoringInstances.enumerated() {
            if self.currentMonitoringInstance!.name == monitoringInstance && index + 1 < monitoringInstances.count {
                self.currentMonitoringInstance = enabledMonitoringInstances[monitoringInstances[index + 1]]
                return true
            }
        }
        
        return false
    }
    
    private func startChecking() {
        self.okButton.isEnabled = false
        self.progressIndicator.startAnimation(nil)
    }
    
    private func stopChecking() {
        self.okButton.isEnabled = true
        self.progressIndicator.stopAnimation(nil)
    }
    
    @IBAction func checkConnection(_ sender: NSButton) {
        // disable the button and start the progress indicator
        self.startChecking()
        
        // make the request
        ConnectionManager.sharedInstance.manager!.request(self.currentMonitoringInstance!.url, method: .head).authenticate(user: self.currentMonitoringInstance!.username, password: self.passwordField.stringValue).validate().response { response in
            if let error = response.error {
                self.stopChecking()
                self.retryModal(error as NSError)
            } else {
                // on success - set the password for the course of the app's life
                PasswordStore.sharedInstance.set(self.currentMonitoringInstance!.name, password: self.passwordField.stringValue)
                
                // if the passwords for all monitoring instances are set, and there is no next one
                // then close the window and refresh
                if !self.nextMonitoringInstance() {
                    self.window!.close()
                    LoadMonitoringData().refreshStatusData()
                } else {
                    self.stopChecking()
                    self.textField.stringValue = String(format:NSLocalizedString("pleaseEnterPassword", comment: ""), self.currentMonitoringInstance!.name)
                }
            }
        }
    }
    
    private func retryModal(_ error: NSError) {
        let informativeText = String(format:NSLocalizedString("skipMonitoringInstance", comment: ""), self.errorCodeToText(error.code))
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("no", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("yes", comment: ""))
        alert.messageText = NSLocalizedString("connectionFailed", comment: "")
        alert.informativeText = informativeText
        alert.alertStyle = .warning
        
        if alert.runModal() == NSAlertSecondButtonReturn {
            if self.nextMonitoringInstance() {
                self.textField.stringValue = String(format:NSLocalizedString("pleaseEnterPassword", comment: ""), self.currentMonitoringInstance!.name)
            } else {
                self.window!.close()
            }
        }
    }
    
    private func errorCodeToText(_ code: Int) -> String {
        switch code {
        case -999:
            return NSLocalizedString("incorrectPassword", comment: "")
        case -1001:
            return NSLocalizedString("connectionTimedOut", comment: "")
        case -1004:
            return NSLocalizedString("couldNotConnect", comment: "")
        default:
            return NSLocalizedString("unknownError", comment: "")
        }
    }
}
