//
//  Icinga2Processor.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class Icinga2Processor : NagiosProcessor {
    override func urlProvider() -> URLProvider {
        return Icinga2URLProvider(self.monitoringInstance!)
    }
    
    override func parser() -> ParserInterface {
        return Icinga2Parser(self.monitoringInstance!)
    }
    
    override func command() -> CommandInterface {
        return Icinga2Commands(self.monitoringInstance!)
    }
    
    override func httpClient() -> HTTPClient {
        return Icinga2HTTPClient(self.monitoringInstance!)
    }
}
