//
//  CheckMKProcessor.swift
//  NagBar
//
//  Created by Volen Davidov on 03.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class CheckMKProcessor: MonitoringProcessorBase, MonitoringProcessor {
    
    func httpClient() -> HTTPClient {
        return CheckMKHTTPClient(self.monitoringInstance!)
    }
    
    func urlProvider() -> URLProvider {
        return CheckMKURLProvider(self.monitoringInstance!)
    }
    
    func parser() -> ParserInterface {
        return CheckMKParser(self.monitoringInstance!)
    }
    
    func command() -> CommandInterface {
        return NagiosCommands(self.monitoringInstance!)
    }
}
