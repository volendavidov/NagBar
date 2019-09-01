//
//  CheckNewVersion.swift
//  NagBar
//
//  Created by Volen Davidov on 01.05.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CheckNewVersion {
    
    func checkNewVersion() {
        let newVersionUrl = URL(string: "https://sites.google.com/site/nagbarapp/version")
        Alamofire.request(newVersionUrl!).response { response in
            if response.error != nil {
                NSLog("Unable to fetch version data; error code " + String(response.error!._code))
            } else {
                self.compareVersions(response.data!)
            }
        }
    }
    
    private func compareVersions(_ data: Data) {
        
        guard let json = try? JSON(data: data) else {
            NSLog("Invalid JSON")
            return
        }
        
        guard let newVersion = json["version"].string else {
            NSLog("Unable to find new version key")
            return
        }
        
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") else {
            NSLog("Unable to find current version")
            return
        }
        
        if (newVersion.compare(currentVersion as! String, options: .numeric) == .orderedDescending) {
            // UI updates on the main thread
            DispatchQueue.main.async {
                self.showAlert(data)
            }
        }
    }
    
    private func showAlert(_ jsonData: Data) {
        
        guard let json = try? JSON(data: jsonData) else {
            return
        }
        
        let newVersion = json["version"].string!
        
        guard let changelog = json["changelog"].string else {
            NSLog("Unable to find changelog")
            return
        }
        
        let messageText = NSLocalizedString("newVersionMessageText", comment: "")
        let informativeText = String(format:NSLocalizedString("newVersionInformativeText", comment: ""), newVersion, changelog)
        
        NagBarAlert().showWarningAlert(messageText, informativeText: informativeText)
    }
}
