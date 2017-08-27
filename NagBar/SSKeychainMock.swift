//
//  SSKeychainMock.swift
//  NagBar
//
//  Created by Volen Davidov on 10/23/15.
//  Copyright © 2015 Volen Davidov. All rights reserved.
//

import Foundation
import SAMKeychain

class SSKeychainMock : SAMKeychain {
    override class func password(forService service: String, account: String) -> String? {
        return "testpass"
    }
}
