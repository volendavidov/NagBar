//
//  PreferencesWindowDelegate.swift
//  NagBar
//
//  Created by Volen Davidov on 05.03.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesWindowDelegate : NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        LoadMonitoringData().refreshStatusData()
    }
}
