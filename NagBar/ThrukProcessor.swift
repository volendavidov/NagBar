//
//  ThrukProcessor.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

class ThrukProcessor : NagiosProcessor {
    override func urlProvider() -> URLProvider {
        return ThrukURLProvider(self.monitoringInstance!)
    }
    
    override func parser() -> ParserInterface {
        return ThrukParser(self.monitoringInstance!)
    }
}
