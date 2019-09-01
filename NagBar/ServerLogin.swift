//
//  ServerLogin.swift
//  NagBar
//
//  Created by Volen Davidov on 12.11.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa
import RealmSwift

enum LoginType : Int {
    case ssh = 0
    case sshiTerm = 1
    case rdp = 2
}

@objc class ServerLogin : NSObject {

    let realm = try! Realm()
    
    @objc
    func sshLogin(_ sender: NSMenuItem) {
        let monitoringItem = sender.representedObject as! MonitoringItem
        let loginMethod = SSHLogin()
        if self.getLoginType(monitoringItem) == nil {
            self.setLoginType(monitoringItem, loginType: .ssh)
        }
        
        self.login(monitoringItem, loginMethod: loginMethod)
    }
    
    @objc
    func sshITermLogin(_ sender: NSMenuItem) {
        let monitoringItem = sender.representedObject as! MonitoringItem
        let loginMethod = SSHITermLogin()
        if self.getLoginType(monitoringItem) == nil {
            self.setLoginType(monitoringItem, loginType: .sshiTerm)
        }
        
        self.login(monitoringItem, loginMethod: loginMethod)
    }
    
    @objc
    func rdpLogin(_ sender: NSMenuItem) {
        let monitoringItem = sender.representedObject as! MonitoringItem
        let loginMethod = RDPLogin()
        if self.getLoginType(monitoringItem) == nil {
            self.setLoginType(monitoringItem, loginType: .rdp)
        }
        
        self.login(monitoringItem, loginMethod: loginMethod)
    }
    
    private func login(_ monitoringItem: MonitoringItem, loginMethod: ServerLoginMethod) {
        
        var username: String?
        if let settingsUsername = self.getUsername(monitoringItem) {
            username = settingsUsername
        } else {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("enterUsername", comment: "")
            alert.addButton(withTitle: NSLocalizedString("ok", comment: ""))
            alert.addButton(withTitle: NSLocalizedString("cancel", comment: ""))
            
            let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
            inputTextField.placeholderString = NSLocalizedString("username", comment: "")
            
            alert.accessoryView = inputTextField
            
            let button = alert.runModal()
            
            if button == NSApplication.ModalResponse.alertFirstButtonReturn {
                username = inputTextField.stringValue
                self.setUsername(monitoringItem, username: inputTextField.stringValue)
            }
        }
        
        if let username = username {
            loginMethod.login(monitoringItem.host, username: username)
        }
    }
    
    @objc func removeLoginSettings(_ sender: NSMenuItem) {
        
        let monitoringItem = sender.representedObject as! MonitoringItem

        let serverLoginItem = realm.objects(ServerLoginItem.self).filter("host == %@", monitoringItem.host).first!
        
        try! realm.write {
            realm.delete(serverLoginItem)
        }
    }
    
    func getUsername(_ monitoringItem: MonitoringItem) -> String? {
        let serverLoginItem = realm.objects(ServerLoginItem.self).filter("host == %@", monitoringItem.host).first
        if let serverLoginItem = serverLoginItem {
            if serverLoginItem.username != "" {
                return serverLoginItem.username
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getLoginType(_ monitoringItem: MonitoringItem) -> LoginType? {
        let serverLoginItem = realm.objects(ServerLoginItem.self).filter("host == %@", monitoringItem.host).first
        if let serverLoginItem = serverLoginItem {
            return LoginType(rawValue: serverLoginItem.loginType)
        } else {
            return nil
        }
    }
    
    func setLoginType(_ monitoringItem: MonitoringItem, loginType: LoginType) {
        let serverLoginItem = ServerLoginItem()
        serverLoginItem.host = monitoringItem.host
        serverLoginItem.loginType = loginType.rawValue
        try! realm.write {
            realm.add(serverLoginItem, update: true)
        }
    }
    
    func setUsername(_ monitoringItem: MonitoringItem, username: String) {
        let serverLoginItem = ServerLoginItem()
        serverLoginItem.host = monitoringItem.host
        serverLoginItem.username = username
        try! realm.write {
            realm.add(serverLoginItem, update: true)
        }
    }
}

class ServerLoginItem : Object {
    @objc dynamic var host = ""
    @objc dynamic var username = ""
    @objc dynamic var loginType = 0
    
    override static func primaryKey() -> String? {
        return "host"
    }
}

protocol ServerLoginMethod {
    func login(_ host: String, username: String)
}

class SSHLogin : ServerLoginMethod {
    func login(_ host: String, username: String) {
        // We could just use open ssh://hostname, but it will open a new window of Terminal
        let source = NSString(format: "tell application \"System Events\"\nset processlist to (name of processes)\nif processlist contains \"Terminal\" then\nactivate application \"Terminal\"\ntell application \"System Events\" to keystroke \"t\" using command down\ntell application \"System Events\" to keystroke \"ssh %@@%@\"\ntell application \"System Events\" to keystroke return\nelse\ntell application \"Terminal\"\nreopen\nactivate\ntell application \"System Events\" to keystroke \"ssh %@@%@\"\ntell application \"System Events\" to keystroke return\nend tell\nend if\nend tell", username, host, username, host);
        
        let script = NSAppleScript(source: source as String)
        
        var err: NSDictionary? = nil
        script!.executeAndReturnError(&err)
        
        if err != nil {
            NSLog(String(describing: err))
        }
    }
}

class SSHITermLogin : ServerLoginMethod {
    func login(_ host: String, username: String) {
        
        let source = NSString(format: "tell application \"System Events\"\nset processlist to (name of processes)\nif processlist contains \"iTerm\" then\nactivate application \"iTerm\"\ntell application \"System Events\" to keystroke \"t\" using command down\ntell application \"System Events\" to keystroke \"ssh %@@%@\"\ntell application \"System Events\" to keystroke return\nelse\ntell application \"iTerm\"\nreopen\nactivate\ntell application \"System Events\" to keystroke \"ssh %@@%@\"\ntell application \"System Events\" to keystroke return\nend tell\nend if\nend tell", username, host, username, host)
        
        let script = NSAppleScript(source: source as String)
        
        var err: NSDictionary? = nil
        script!.executeAndReturnError(&err)
        
        if err != nil {
            NSLog(String(describing: err))
        }
    }
}

class RDPLogin : ServerLoginMethod {
    func login(_ host: String, username: String) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        
        let url = NSString(format: "rdp://full%%20address=s:%@&username=s:%@", host, username)
        task.arguments = [url as String]
        
        task.launch()
    }
}
