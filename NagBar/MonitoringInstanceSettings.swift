//
//  MonitoringInstanceSettings.swift
//  NagBar
//
//  Created by Volen Davidov on 23.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

protocol MonitoringInstanceSettings {
    func getHostStatusTypes() -> String
    func getHostProperties() -> String
    func getServiceStatusTypes() -> String
    func getServiceProperties() -> String
    func getSortOrder() -> String
    func getSortColumn() -> String
}