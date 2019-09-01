//
//  MonitoringInstance.swift
//  NagBar
//
//  Created by Volen Davidov on 17.10.15.
//  Copyright (c) 2015 Volen Davidov. All rights reserved.
//

import Foundation
import RealmSwift

enum MonitoringInstanceType: String {
    case Nagios = "Nagios"
    case Icinga = "Icinga"
    case Icinga2 = "Icinga2"
    case Thruk = "Thruk"
    case Check_MK = "Check_MK"
    
    static let allKeys = [Nagios, Icinga, Icinga2, Thruk]
    static let allValues = ["Nagios", "Icinga", "Icinga2", "Thruk"]
}

typealias MIDictionary = Dictionary<String, MonitoringInstance>

class MonitoringInstance : Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var url: String = ""
    // Realm does not support enums - https://github.com/realm/realm-cocoa/issues/921
    @objc private dynamic var privateType = MonitoringInstanceType.Nagios.rawValue
    var type: MonitoringInstanceType {
        get {
            return MonitoringInstanceType(rawValue: privateType)!
        }
        set {
            privateType = newValue.rawValue
        }
    }
    @objc dynamic var username: String = ""
    var password: String = ""
    @objc dynamic var enabled: Int = 0
    
    func initDefault(name: String, url: String, type: MonitoringInstanceType, username: String, password: String, enabled: Int) -> MonitoringInstance {
        self.name = name
        self.url = url
        self.username = username
        self.password = password
        self.enabled = enabled
        
        return self
    }
    
    func monitoringProcessor() -> MonitoringProcessor {
        switch self.type {
        case .Nagios:
            return NagiosProcessor(self)
        case .Icinga:
            return IcingaProcessor(self)
        case .Icinga2:
            return Icinga2Processor(self)
        case .Thruk:
            return ThrukProcessor(self)
        case .Check_MK:
            return CheckMKProcessor(self)
        }
    }
}

