//
//  ThrukURLProvider.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

// Thruk URLs have the same format as Nagios URLs, except that we request them in JSON format
class ThrukURLProvider : NagiosURLProvider {
    override var appendURL: String {
        get {
            return "&view_mode=json"
        }
    }
}