
//  FilterItem.swift
//  NagBar
//
//  Created by Volen Davidov on 14.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import RealmSwift

class FilterItem: Object {
    @objc dynamic var host: String = ""
    @objc dynamic var service: String = ""
    @objc dynamic var status: Int = 0
    
    func initDefault(host: String, service: String, status: Int) -> FilterItem {
        self.host = host
        self.service = service
        self.status = status
        
        return self
    }
}
