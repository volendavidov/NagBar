//
//  UserDefaults.swift
//  NagBar
//
//  Created by Volen Davidov on 18.10.15.
//  Copyright (c) 2015 Volen Davidov. All rights reserved.
//

import Foundation
import SAMKeychain

class ExternalServiceProvider {
    func isTestEnvironment() -> Bool {
        let environment = ProcessInfo.processInfo.environment
        let isTestEnvironment = environment["TESTS_RUNNING"]
        
        if isTestEnvironment == "YES" {
            return true
        } else {
            return false
        }
    }
}

class KeychainAccess : ExternalServiceProvider {
    func get() -> SAMKeychain.Type {
        if self.isTestEnvironment() {
            return SSKeychainMock.self
        } else {
            return SAMKeychain.self
        }
    }
}
