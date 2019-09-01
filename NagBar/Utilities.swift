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
    var intValue: Int {
        return self ? 1 : 0
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
