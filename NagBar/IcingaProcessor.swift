//
//  IcingaProcessor.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

// Icinga basically works the same way as Nagios except the HTML elements in status.cgi
// which have different XPath
class IcingaProcessor: NagiosProcessor {
    override func parser() -> ParserInterface {
        return IcingaParser(self.monitoringInstance!)
    }
}
