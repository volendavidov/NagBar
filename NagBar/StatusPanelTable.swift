//
//  StatusPanelTable.swift
//  NagBar
//
//  Created by Volen Davidov on 23.05.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Cocoa
import Foundation

class StatusPanelTable : NSTableView {
    
    private var statusPanelTableViewDatasource: StatusPanelTableViewDatasource?
    private var statusPanelTableDelegate: StatusPanelTableDelegate?
    
    private var selectedIndexes: IndexSet?
    private var targetAction: Array<MenuAction> = []
    private var results: Array<MonitoringItem>?
    
    private var serverLogin: ServerLogin?
    
    func initTable(_ results: Array<MonitoringItem>) {
    
        if self.statusPanelTableViewDatasource == nil {
            self.statusPanelTableViewDatasource = StatusPanelTableViewDatasource(results: results)
        }
        
        if self.statusPanelTableDelegate == nil {
            self.statusPanelTableDelegate = StatusPanelTableDelegate(results: results)
        }
        
        if self.serverLogin == nil {
            self.serverLogin = ServerLogin()
        }
        
        self.results = results
        
        self.delegate = self.statusPanelTableDelegate
        self.dataSource = self.statusPanelTableViewDatasource
        
        for i in self.getColumns() {
            i.setResults(results)
            self.addTableColumn(i)
        }
        
        self.headerView = nil
        self.allowsMultipleSelection = true
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        self.removeHighlight()
        super.mouseDown(with: theEvent)
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        super.menu(for: event)

        var menu = NSMenu(title: "")
        menu.autoenablesItems = false
        
        if self.selectedRowIndexes.count == 0 {
            let mousePoint = self.convert(event.locationInWindow, from: nil)
            let row = self.row(at: mousePoint)
            
            // Use custom highlighting for the row. With the default highlighting, we have to
            // left click on the row to be highlighted. With our custom highlighting, rows are
            // highlighted with right click as well.
            self.highlightSelectedRow(row)
            
            self.selectedIndexes = IndexSet(integer: row)
        } else {
            self.selectedIndexes = self.selectedRowIndexes
        }
        
        var monitoringItems: Array<MonitoringItem> = []
        for i in self.selectedIndexes! {
            monitoringItems.append(self.results![i])
        }
        
        menu = self.monitoringInstanceCommandCapabilities(monitoringItems: monitoringItems, menu: menu)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(self.createMultipleSelectionMenuItem(String(format:NSLocalizedString("addToFilter", comment: "")), target: AddToFilterAction(), monitoringItems: monitoringItems))

        return menu
    }
    
    private func monitoringInstanceCommandCapabilities(monitoringItems: Array<MonitoringItem>, menu: NSMenu) -> NSMenu {
        
        // Do not show menu items if different monitoring instances are selected. Action on different monitoring
        // instances would greatly increase complexity.
        if self.checkDifferentMonitoringInstances(monitoringItems: monitoringItems) {
            return menu
        }
        
        menu.addItem(self.loadLoginSubmenu(monitoringItems[0]))
        if serverLogin!.getLoginType(monitoringItems[0]) != nil {
            menu.addItem(self.removeLoginSettingsMenu(monitoringItems[0]))
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let capabilities = monitoringItems[0].monitoringInstance!.monitoringProcessor().command().capabilities()
        
        if capabilities.contains(.openInBrowser) {
            menu.addItem(self.createSingleSelectionMenuItem(String(format:NSLocalizedString("openInBrowser", comment: "")), target: OpenInBrowserAction(), monitoringItems: monitoringItems))
        }
        
        if capabilities.contains(.recheck) {
            menu.addItem(self.createMultipleSelectionMenuItem(String(format:NSLocalizedString("recheck", comment: "")), target: RecheckAction(), monitoringItems: monitoringItems))
        }
        
        if capabilities.contains(.scheduleDowntime) {
            menu.addItem(self.createMultipleSelectionMenuItem(String(format:NSLocalizedString("scheduleDowntime", comment: "")), target: ScheduleDowntimeAction(), monitoringItems: monitoringItems))
        }
        
        if capabilities.contains(.acknowledge) {
            menu.addItem(self.createMultipleSelectionMenuItem(String(format:NSLocalizedString("acknowledge", comment: "")), target: AcknowledgeAction(), monitoringItems: monitoringItems))
        }
        
        return menu
    }
    
    private func checkDifferentMonitoringInstances(monitoringItems: Array<MonitoringItem>) -> Bool {
        var monitoringInstances: Array<String> = []
        for monitoringItem in monitoringItems {
            if !monitoringInstances.contains(monitoringItem.monitoringInstance!.name) {
                monitoringInstances.append(monitoringItem.monitoringInstance!.name)
            }
        }
        
        return monitoringInstances.count > 1
    }
    
    private func loginMenuItem(_ monitoringItem: MonitoringItem, title: String, selector: Selector) -> NSMenuItem {
        let loginMenuItem = NSMenuItem(title: title, action: selector, keyEquivalent: "")
        loginMenuItem.target = self.serverLogin
        loginMenuItem.representedObject = monitoringItem
        
        return loginMenuItem
    }
    
    private func removeLoginSettingsMenu(_ monitoringItem: MonitoringItem) -> NSMenuItem {
        let removeLoginSettingsMenuItem = NSMenuItem(title: NSLocalizedString("removeLoginSettings", comment: ""), action: #selector(self.serverLogin!.removeLoginSettings(_:)), keyEquivalent: "")
        removeLoginSettingsMenuItem.target = self.serverLogin
        removeLoginSettingsMenuItem.representedObject = monitoringItem
        
        return removeLoginSettingsMenuItem
    }
    
    private func loadLoginSubmenu(_ monitoringItem: MonitoringItem) -> NSMenuItem {
        
        if let loginType = serverLogin!.getLoginType(monitoringItem) {
            var selector: Selector?
            switch loginType {
            case .ssh:
                selector = #selector(self.serverLogin!.sshLogin(_:))
                break
            case .sshiTerm:
                selector = #selector(self.serverLogin!.sshITermLogin(_:))
                break
            case .rdp:
                selector = #selector(self.serverLogin!.rdpLogin(_:))
                break
            }
            
            let login = self.loginMenuItem(monitoringItem, title: NSLocalizedString("login", comment: ""), selector: selector!)
            return login
        } else {
            let loginMenuItem = NSMenuItem(title: NSLocalizedString("login", comment: ""), action: nil, keyEquivalent: "")
            loginMenuItem.submenu = self.buildLoginSubmenu(monitoringItem)
            return loginMenuItem
        }
    }
    
    private func buildLoginSubmenu(_ monitoringItem: MonitoringItem) -> NSMenu {
        
        let loginSubmenu = NSMenu()
        loginSubmenu.autoenablesItems = false
        
        let sshLoginMenuItem = self.loginMenuItem(monitoringItem, title: "SSH", selector: #selector(self.serverLogin!.sshLogin(_:)))
        loginSubmenu.addItem(sshLoginMenuItem)
        
        if self.checkITermInstalled() {
            let sshITermLoginMenuItem = self.loginMenuItem(monitoringItem, title: "SSH (iTerm)", selector: #selector(self.serverLogin!.sshITermLogin(_:)))
            loginSubmenu.addItem(sshITermLoginMenuItem)
        }
        
        let rdpLoginMenuItem = self.loginMenuItem(monitoringItem, title: "RDP", selector: #selector(self.serverLogin!.rdpLogin(_:)))
        loginSubmenu.addItem(rdpLoginMenuItem)
        
        return loginSubmenu
    }
    
    private func checkITermInstalled() -> Bool {
        if let iterm = LSCopyApplicationURLsForBundleIdentifier("com.googlecode.iterm2" as CFString, nil)?.takeUnretainedValue() {
            return CFArrayGetCount(iterm) > 0
        }
        
        return false
    }
    
    private func createMultipleSelectionMenuItem(_ title: String, target: MenuAction, monitoringItems: Array<MonitoringItem>) -> NSMenuItem {
        
        // retain the target class
        self.targetAction.append(target)
        
        let menuItem = NSMenuItem(title: title, action: #selector(target.action(_:)), keyEquivalent: "")
        menuItem.target = target
        menuItem.representedObject = monitoringItems
        
        return menuItem
    }
    
    private func createSingleSelectionMenuItem(_ title: String, target: MenuAction, monitoringItems: Array<MonitoringItem>) -> NSMenuItem {
        let menuItem = self.createMultipleSelectionMenuItem(title, target: target, monitoringItems: monitoringItems)
        
        if self.selectedIndexes!.count != 1 {
            menuItem.isEnabled = false
        }
        
        return menuItem
    }

    private func removeHighlight() {
        // remove all subviews SelectedTableViewCellBackground
        
        for i in 0..<self.numberOfRows {
            
            var viewArray: Array<NSView> = []
            
            for j in 0..<self.numberOfColumns {
                
                let selectedCell = self.view(atColumn: j, row: i, makeIfNecessary: false)
                
                if let selectedCell = selectedCell {
                    for k in selectedCell.subviews {
                        if type(of: k) == SelectedTableViewCellBackground.self {
                            viewArray.append(k)
                        }
                    }
                }
            }
            
            for m in viewArray {
                m.removeFromSuperview()
            }
        }
    }

    private func highlightSelectedRow(_ selectedRow: Int) {
        self.removeHighlight()
        
        // add the subview SelectedTableViewCellBackground for the selected row
        
        for l in 0 ..< self.numberOfColumns {
            let selectedCell = self.view(atColumn: l, row: selectedRow, makeIfNecessary: false)
            // this is to avoid adding SelectedTableViewCellBackground as subview TableViewCellBackground if it is already added
            var selectedTableViewCellBackgroundExists = false
            
            for j in selectedCell!.subviews {
                if j.isKind(of: SelectedTableViewCellBackground.self) {
                    selectedTableViewCellBackgroundExists = true
                }
            }
            
            if !selectedTableViewCellBackgroundExists {
                let selectedTableViewCellBackground = SelectedTableViewCellBackground(frame: selectedCell!.bounds)
                selectedCell?.addSubview(selectedTableViewCellBackground)
            }
        }
    }
    
    private func getColumns() -> Array<SPTableColumn> {
        // the order here is important
        
        var result: Array<SPTableColumn> = []
        
        // init the column with empty results set; we must set it later!
        if Settings().boolForKey("monitoringInstance") {
            result.append(SPMonitoringInstanceTableColumn(results: Array<MonitoringItem>()))
        }
        
        result.append(SPHostTableColumn(results: Array<MonitoringItem>()))
        result.append(SPServiceTableColumn(results: Array<MonitoringItem>()))
        result.append(SPAcknowledgedDowntimeTableColumn(results: Array<MonitoringItem>()))
        
        if Settings().boolForKey("status") {
            result.append(SPStatusTableColumn(results: Array<MonitoringItem>()))
        }
        
        if Settings().boolForKey("duration") {
            result.append(SPDurationTableColumn(results: Array<MonitoringItem>()))
        }
        
        if Settings().boolForKey("lastCheck") {
            result.append(SPLastCheckTableColumn(results: Array<MonitoringItem>()))
        }
        
        if Settings().boolForKey("attempt") {
            result.append(SPAttemptTableColumn(results: Array<MonitoringItem>()))
        }
        
        if Settings().boolForKey("statusInformation") {
            result.append(SPStatusInformationTableColumn(results: Array<MonitoringItem>()))
        }
        
        return result
    }
}

class SelectedTableViewCellBackground : NSView {
    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current!.cgContext
        context.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        context.fill(NSRectToCGRect(dirtyRect))
    }
}
