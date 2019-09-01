//
//  FilterTableViewDelegate.swift
//  NagBar
//
//  Created by Volen Davidov on 15.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import Cocoa

class FilterTableViewDelegate: NSObject, NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let text: NSTextField = NSTextField()
        text.isBezeled = false
        text.isBordered = false
        text.isEditable = false
        text.drawsBackground = false
        text.cell?.lineBreakMode = .byTruncatingTail
        
        text.identifier = tableColumn?.identifier
        
        if let tableColumn = tableColumn as? FilterItemTableColumn {
            let filterItem = FilterItems().getById(row)
            text.stringValue = tableColumn.formatText(filterItem)
        }
        
        return text
    }
}

protocol FilterItemTableColumn {
    func formatText(_ filterItem: FilterItem) -> String
}

class HostTableColumn: NSTableColumn, FilterItemTableColumn {
    func formatText(_ filterItem: FilterItem) -> String {
        return filterItem.host
    }
}

class ServiceTableColumn: NSTableColumn, FilterItemTableColumn {
    func formatText(_ filterItem: FilterItem) -> String {
        return filterItem.service
    }
}

class StatusTableColumn: NSTableColumn, FilterItemTableColumn {
    func formatText(_ filterItem: FilterItem) -> String {

        let serviceStatusMapping: Dictionary<Int, String> = [1: "P", 4: "W", 8: "U", 16: "C"]
        let hostStatusMapping: Dictionary<Int, String> = [1: "PE", 4: "D", 8: "UR"]
        
        var stringArray: Array<String> = []
        
        if filterItem.service.count != 0 {
            stringArray = self.numberToLetters(filterItem, statusMapping: serviceStatusMapping)
        } else {
            stringArray = self.numberToLetters(filterItem, statusMapping: hostStatusMapping)
        }
        
        let text = stringArray.joined(separator: ",")
        
        return text
    }
    
    fileprivate func numberToLetters(_ filterItem: FilterItem, statusMapping: Dictionary<Int, String>) -> Array<String> {
        var stringArray: Array<String> = []
        
        for (key, value) in statusMapping {
            if filterItem.status & key == key {
                stringArray.append(value)
            }
        }
        
        return stringArray
    }
}
