//
//  Utilities.swift
//  NagBar
//
//  Created by Volen Davidov on 18.10.15.
//  Copyright (c) 2015 Volen Davidov. All rights reserved.
//

import Foundation

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

extension Bool {
    init<T : Integer>(_ integer: T) {
        if integer == 0 {
            self.init(false)
        } else {
            self.init(true)
        }
    }
}

extension Array {
    mutating func removeObject(_ anObject : AnyObject) {
        var index: Int?
        for (i, value) in self.enumerated() {
            if value as AnyObject === anObject {
                index = i
            }
        }
        
        if let index = index {
            self.remove(at: index)
        }
    }
}
