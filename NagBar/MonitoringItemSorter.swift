//
//  MonitoringItemSorter.swift
//  NagBar
//
//  Created by Volen Davidov on 24.05.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

// Some monitoring instances (like Icinga2 API) do not have built-in sorting
// of the monitoring items, so we do it here instead

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MonitoringItemSorter {
    
    enum SortColumn : Int {
        case none = 0
        case host = 1
        case service = 2
        case status = 3
        case lastCheck = 4
        case attempt = 5
        case duration = 6
    }
    
    enum SortOrder : Int {
        case none = 0
        case ascending = 1
        case descending = 2
    }
    
    let sortColumn = SortColumn(rawValue: Settings().integerForKey("sortColumn"))!
    let sortOrder = SortOrder(rawValue: Settings().integerForKey("sortOrder"))!
    
    func sortHosts(_ monitoringItems: Array<HostMonitoringItem>) -> Array<HostMonitoringItem> {
        
        switch self.sortColumn {
        case .none:
            return monitoringItems
        case .host:
            return monitoringItems.sorted(by: {self.sort($0.host, second: $1.host, sortOrder: sortOrder)})
        case .service:
            return monitoringItems
        case .status:
            return monitoringItems.sorted(by: {self.sort($0.status, second: $1.status, sortOrder: sortOrder)})
        case .lastCheck:
            return monitoringItems.sorted(by: {self.sortLastCheck($0.lastCheck, second: $1.lastCheck, sortOrder: sortOrder)})
        case .attempt:
            return monitoringItems
        case .duration:
            return monitoringItems.sorted(by: {self.sortDuration($0.duration, second: $1.duration, sortOrder: sortOrder)})
        }
    }
    
    func sortServices(_ monitoringItems: Array<ServiceMonitoringItem>) -> Array<ServiceMonitoringItem> {
        
        switch self.sortColumn {
        case .none:
            return monitoringItems
        case .host:
            return monitoringItems.sorted(by: {self.sort($0.host, second: $1.host, sortOrder: sortOrder)})
        case .service:
            return monitoringItems.sorted(by: {self.sort($0.service, second: $1.service, sortOrder: sortOrder)})
        case .status:
            return monitoringItems.sorted(by: {self.sort($0.status, second: $1.status, sortOrder: sortOrder)})
        case .lastCheck:
            return monitoringItems.sorted(by: {self.sortLastCheck($0.lastCheck, second: $1.lastCheck, sortOrder: sortOrder)})
        case .attempt:
            return monitoringItems.sorted(by: {self.sort($0.attempt, second: $1.attempt, sortOrder: sortOrder)})
        case .duration:
            return monitoringItems.sorted(by: {self.sortDuration($0.duration, second: $1.duration, sortOrder: sortOrder)})
        }
    }
    
    private func sort(_ first: String, second: String, sortOrder: SortOrder) -> Bool {
        switch sortOrder {
        case .none:
            return false
        case .ascending:
            return first.lowercased() < second.lowercased()
        case .descending:
            return first.lowercased() > second.lowercased()
        }
    }
    
    /*
     * Compare durations with format 1d 5h 32m 43s
     */
    private func sortDuration(_ first: String, second: String, sortOrder: SortOrder) -> Bool {
       
        // first split the strings by space
        let firstArr = first.components(separatedBy: " ")
        let secondArr = second.components(separatedBy: " ")
        
        // the less components a value has, the earlier it happened
        // e.g. 32m 54s (2 components) happened before 3h 12m 43s (3 components)
        if firstArr.count < secondArr.count {
            return self.ascOrDesc(sortOrder, value: true)
        } else if firstArr.count > secondArr.count {
            return self.ascOrDesc(sortOrder, value: false)
        } else {
            // this is for the case where the number of components is the same
            for (index, value) in firstArr.enumerated() {
                // remove the string (that is, the last character) from the component,
                // so that it becomes 32 instead of 32m
                // Also convert it to Int
                let truncatedFirst = Int(value.substring(to: value.characters.index(before: value.endIndex)))
                let truncatedSecond = Int(secondArr[index].substring(to: secondArr[index].characters.index(before: secondArr[index].endIndex)))
                
                if truncatedFirst < truncatedSecond {
                    return self.ascOrDesc(sortOrder, value: true)
                } else if truncatedFirst > truncatedSecond {
                    return self.ascOrDesc(sortOrder, value: false)
                } else {
                    continue
                }
            }
        }
        
        return false
    }
    
    private func sortLastCheck(_ first: String, second: String, sortOrder: SortOrder) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY HH:mm:ss"
        
        guard let firstDate = dateFormatter.date(from: first) else {
            return false
        }
        
        guard let secondDate = dateFormatter.date(from: second) else {
            return false
        }
        
        if firstDate.compare(secondDate) == ComparisonResult.orderedAscending {
            return self.ascOrDesc(sortOrder, value: false)
        } else {
            return self.ascOrDesc(sortOrder, value: true)
        }
    }
    
    /**
     * invert the true/false value in case we have selected descending order
     */
    private func ascOrDesc(_ sortOrder: SortOrder, value: Bool) -> Bool {
        switch sortOrder {
        case .none:
            return value
        case .ascending:
            return value
        case .descending:
            return !value
        }
    }
}
