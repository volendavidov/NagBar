//
//  StatusItemView.swift
//  NagBar
//
//  Created by Volen Davidov on 05.03.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class StatusItemView: NSStatusBarButton {
    let StatusItemViewPaddingWidth = CGFloat(6)
    let StatusItemViewPaddingHeight = CGFloat(3)
    
//    var title: String?
    var statusItem: NSStatusItem?
    
    override func draw(_ dirtyRect: NSRect) {
        let origin = NSMakePoint(StatusItemViewPaddingWidth, StatusItemViewPaddingHeight);
        title.draw(at: origin, withAttributes: titleAttributes())
    }
    
    private func titleAttributes() -> Dictionary<NSAttributedString.Key, AnyObject> {
        let font = NSFont.menuBarFont(ofSize: 0)
        
        var color = NSColor.black
        
        // check if dark mode is enabled
        let dict = Foundation.UserDefaults.standard.persistentDomain(forName: Foundation.UserDefaults.globalDomain)
        let style = dict!["AppleInterfaceStyle"]
        
        if let style = style as? String {
            if ComparisonResult.orderedSame == style.caseInsensitiveCompare("dark") {
                color = NSColor.white
            }
        }
        
        return [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color]
    }
    
    override func rightMouseDown(with theEvent: NSEvent) {
        
        let menu = NSMenu(title: "")
        
        menu.addItem(withTitle: "Refresh", action: #selector(StatusItemView.refresh), keyEquivalent: "")
        
        menu.addItem(NSMenuItem.separator())
        
        if !Settings().boolForKey("showDockIcon") as Bool {
            menu.addItem(withTitle: "Preferences", action: #selector(AppDelegate.openPreferences(_:)), keyEquivalent: "")
        }
        
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        NSMenu.popUpContextMenu(menu, with: theEvent, for: self)
        
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        // show the panel
        StatusBar.get().onClick()
    }
    
    @objc func refresh() {
        LoadMonitoringData().refreshStatusData()
    }
    
    func setStatusItemTitle(_ newTitle: String) {
        if self.title == newTitle {
            return
        }
        
        self.title = newTitle
        
        let titleBounds = self.titleBoundingRect()
        let newWidth = titleBounds.size.width + (2 * StatusItemViewPaddingWidth)
        self.statusItem?.length = newWidth
        self.needsDisplay = true
    }
    
    func titleBoundingRect() -> NSRect {
        return title.boundingRect(with: NSMakeSize(0, 0), options: .usesFontLeading, attributes: self.titleAttributes())
    }
}
