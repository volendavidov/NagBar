//
//  Settings.swift
//  NagBar
//
//  Created by Volen Davidov on 18.10.15.
//  Copyright (c) 2015 Volen Davidov. All rights reserved.
//

import Foundation
import RealmSwift

class Setting : Object {
    dynamic var key = ""
    dynamic var value = ""
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

class Settings {
    
    let realm = try! Realm()
    
    func savePassword() -> Bool {
        return Settings().boolForKey("savePassword")
    }
    
    func doubleForKey(_ defaultName: String) -> Double {
        // We could just use:
        // return Double(realm.objects(Setting.self).filter("key == %@", defaultName).first!.value)!
        // here, as well as in the other function, but this leads to a memory leak. For some reason
        // the piece below does not retain the objects
        return Double(realm.object(ofType: Setting.self, forPrimaryKey: defaultName)!.value)!
    }
    
    func stringForKey(_ defaultName: String) -> String? {
        return realm.object(ofType: Setting.self, forPrimaryKey: defaultName)!.value
    }
    
    func valueForKey(_ key: String) -> Any? {
        return realm.object(ofType: Setting.self, forPrimaryKey: key)!.value
    }
    
    func boolForKey(_ defaultName: String) -> Bool {
        let result = realm.object(ofType: Setting.self, forPrimaryKey: defaultName)!.value
        let resultMap = ["0": false, "1": true]
        
        return resultMap[result] ?? false
    }
    
    func integerForKey(_ defaultName: String) -> Int {
        return Int(realm.object(ofType: Setting.self, forPrimaryKey: defaultName)!.value)!
    }
    
    func setBool(_ value: Bool, forKey: String) {
        let resultMap = [false: "0", true: "1"]
        
        let setting = Setting()
        setting.key = forKey
        setting.value = resultMap[value] ?? "0"
        try! realm.write {
            realm.add(setting, update: true)
        }
    }
    
    func setInteger(_ value: Int, forKey: String) {
        let setting = Setting()
        setting.key = forKey
        setting.value = String(value)
        try! realm.write {
            realm.add(setting, update: true)
        }
    }
    
    func setString(_ value: String, forKey: String) {
        let setting = Setting()
        setting.key = forKey
        setting.value = value
        try! realm.write {
            realm.add(setting, update: true)
        }
    }
}

class PasswordStore {
    static let sharedInstance = PasswordStore()
    private var passwordData: Dictionary<String, String> = [:]
    
    func getAll() -> Dictionary<String, String> {
        return self.passwordData
    }
    
    func get(_ account: String) -> String? {
        return self.passwordData[account]
    }
    
    func set(_ account: String, password: String) {
        self.passwordData[account] = password
    }
}
