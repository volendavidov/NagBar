//
//  CommandInterface.swift
//  NagBar
//
//  Created by Volen Davidov on 07.08.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CommandInterface {
    func getTime(_ monitoringItems: Array<MonitoringItem>) -> Promise<(String,String)>
    func recheck(_ monitoringItems: Array<MonitoringItem>)
    func scheduleDowntime(_ monitoringItems: Array<MonitoringItem>, from: String, to: String, comment: String, type: String, hours: String, minutes: String)
    func acknowledge(_ monitoringItems: Array<MonitoringItem>, comment: String)
    func capabilities() -> Array<CommandTypes>
}

enum CommandTypes {
    case openInBrowser
    case recheck
    case acknowledge
    case scheduleDowntime
}
