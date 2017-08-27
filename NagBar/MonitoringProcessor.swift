//
//  MonitoringProcessor.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

protocol MonitoringProcessor {
    func httpClient() -> HTTPClient
    func urlProvider() -> URLProvider
    func parser() -> ParserInterface
    func command() -> CommandInterface
}
