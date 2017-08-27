//
//  NagBarAlert.swift
//  NagBar
//
//  Created by Volen Davidov on 07.02.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class NagBarAlert {
    func showWarningAlert(_ messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        alert.runModal()
    }
}
