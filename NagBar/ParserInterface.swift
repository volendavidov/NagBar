//
//  ParserInterface.swift
//  NagBar
//
//  Created by Volen Davidov on 10/25/15.
//  Copyright © 2015 Volen Davidov. All rights reserved.
//

import Foundation

protocol ParserInterface {
    func parse(urlType: MonitoringURLType, data: Data) -> Array<MonitoringItem>
}
