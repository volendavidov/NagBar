//
//  OpenInBrowserAction.swift
//  NagBar
//
//  Created by Volen Davidov on 24.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class OpenInBrowserAction: NSObject, MenuAction {
    
    func action(_ sender: NSMenuItem) {
        let monitoringItems = sender.representedObject as! Array<MonitoringItem>
        
        var url = URL(string: monitoringItems[0].itemUrl)
        
        // the above sometimes fails with Thruk
        if url == nil {
            url = URL(string: monitoringItems[0].itemUrl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        }
        
        if url == nil {
            NSLog("Error parsing url with string " + monitoringItems[0].itemUrl)
            return
        }
        
        NSWorkspace.shared().open(url!)
    }
}
