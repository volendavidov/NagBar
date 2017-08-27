//
//  IcingaParser.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class IcingaParser : NagiosParser {
    override init(_ monitoringInstance: MonitoringInstance) {
        super.init(monitoringInstance)
        self.xPathProvider = IcingaXPath()
    }
}
