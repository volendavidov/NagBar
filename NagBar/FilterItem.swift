
//  FilterItem.swift
//  NagBar
//
//  Created by Volen Davidov on 14.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import RealmSwift

class FilterItem: Object {
    dynamic var host: String = ""
    dynamic var service: String = ""
    dynamic var status: Int = 0
    
    func initDefault(host: String, service: String, status: Int) -> FilterItem {
        self.host = host
        self.service = service
        self.status = status
        
        return self
    }
}
