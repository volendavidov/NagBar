//
//  MonitoringInstances.swift
//  NagBar
//
//  Created by Volen Davidov on 31.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import RealmSwift

class MonitoringInstances {
    
    let realm = try! Realm()
    
    func getAll() -> MIDictionary {
        var monitoringInstances: MIDictionary = [:]
        for monitoringInstance in realm.objects(MonitoringInstance.self) {
            monitoringInstance.password = self.getPassword(monitoringInstance.name)
            monitoringInstances[monitoringInstance.name] = monitoringInstance
        }
        return monitoringInstances
    }
    
    func getAllEnabled() -> MIDictionary {
        var monitoringInstances: MIDictionary = [:]
        for monitoringInstance in realm.objects(MonitoringInstance.self).filter("enabled == 1") {
            monitoringInstance.password = self.getPassword(monitoringInstance.name)
            monitoringInstances[monitoringInstance.name] = monitoringInstance
        }
        return monitoringInstances
    }
    
    func getByKey(_ key: String) -> MonitoringInstance? {
        return getAll()[key]
    }
    
    func getKeyById(_ id: Int) -> String {
        return getAll().keys.sorted(){$0.lowercased() < $1.lowercased()}[id]
    }
    
    func getById(_ id: Int) -> MonitoringInstance {
        let key = self.getKeyById(id)
        let result = getAll()[key]
        
        result!.password = getPassword(key)

        return result!
    }
    
    func count() -> Int {
        return getAll().count
    }
    
    func updateName(monitoringInstance: MonitoringInstance, name: String) {
        try! realm.write {
            monitoringInstance.name = name
        }
    }
    
    func updateUrl(monitoringInstance: MonitoringInstance, url: String) {
        try! realm.write {
            monitoringInstance.url = url
        }
    }
    
    func updateType(monitoringInstance: MonitoringInstance, type: MonitoringInstanceType) {
        try! realm.write {
            monitoringInstance.type = type
        }
    }
    
    func updateEnabled(monitoringInstance: MonitoringInstance, enabled: Int) {
        try! realm.write {
            monitoringInstance.enabled = enabled
        }
    }
    
    func updateUsername(monitoringInstance: MonitoringInstance, username: String) {
        try! realm.write {
            monitoringInstance.username = username
        }
    }
    
    func updatePassword(monitoringInstance: MonitoringInstance, password: String) {
        // update the password in the cache and in the keychain
        PasswordStore.sharedInstance.set(monitoringInstance.name, password: password)
        if Settings().boolForKey("savePassword") {
            KeychainAccess().get().setPassword(password, forService: "NagBar", account: monitoringInstance.name)
        } else {
            KeychainAccess().get().deletePassword(forService: "NagBar", account: monitoringInstance.name)
        }
    }
    
    private func getPassword(_ account: String) -> String {
        
        // get the password from the cache to avoid multiple calls to the keychain
        // NOTE: if the save password option is disabled, the password is set in the
        // cache during startup
        if let password = PasswordStore.sharedInstance.get(account) {
            return password
        }
        
        // continue only if the save password option is enabled
        if !Settings().boolForKey("savePassword") {
            return ""
        }
        
        if let password = KeychainAccess().get().password(forService: "NagBar", account: account) {
            PasswordStore.sharedInstance.set(account, password: password)
            return password
        } else {
            return ""
        }
    }
    
    func removeById(_ id: Int) {
        var all = getAll()
        let key = getKeyById(id)
        self.deletePassword(key)
        
        try! realm.write {
            realm.delete(all[key]!)
        }
    }
    
    func insert(key: String, value: MonitoringInstance) {
        try! realm.write {
            realm.add(value)
        }
    }
    
    private func deletePassword(_ account: String) {
        KeychainAccess().get().deletePassword(forService: "NagBar", account: account)
    }
}
