//
//  NagiosProcessor.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class NagiosProcessor : MonitoringProcessorBase, MonitoringProcessor {
    
    func httpClient() -> HTTPClient {
        return NagiosHTTPClient(self.monitoringInstance!)
    }
    
    func urlProvider() -> URLProvider {
        return NagiosURLProvider(self.monitoringInstance!)
    }
    
    func parser() -> ParserInterface {
        return NagiosParser(self.monitoringInstance!)
    }
    
    func command() -> CommandInterface {
        return NagiosCommands(self.monitoringInstance!)
    }
}
