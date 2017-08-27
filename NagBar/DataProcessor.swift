//
//  DataProcessor.swift
//  NagBar
//
//  Created by Volen Davidov on 17.04.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation

struct ProcessorRequest {
    var currentItems: Array<MonitoringItem>
    var allItems: Array<MonitoringItem>
    var urlType: MonitoringURLType
}

class Processor {
    var nextProcessor: Processor?
    var processorRequest: ProcessorRequest?
    
    func setNextProcessor(_ nextProcessor: Processor) {
        self.nextProcessor = nextProcessor
    }
    
    func process(_ processorRequest: ProcessorRequest) {
        self.processorRequest = processorRequest
    }
    
    func get() -> Array<MonitoringItem> {
        return self.processorRequest!.allItems
    }
    
    fileprivate func finish(_ nextProcessor: Processor?, newProcessorRequest: ProcessorRequest) {
        if let nextProcessor = self.nextProcessor {
            nextProcessor.process(newProcessorRequest)
        } else {
            self.processorRequest = newProcessorRequest
        }
    }
}

class AddProcessor : Processor {
    fileprivate func operation(_ input: Array<MonitoringItem>, diff: Array<MonitoringItem>) -> Array<MonitoringItem> {
        return input + diff
    }
}

class SubtractProcessor : Processor {
    fileprivate func operation(_ input: Array<MonitoringItem>, diff: Array<MonitoringItem>) -> Array<MonitoringItem> {
        var inputMutable = input
        
        for i in diff {
            inputMutable.removeObject(i)
        }
        
        return inputMutable
    }
}

class FilterItemsProcessor : SubtractProcessor {
    /**
     Filter hosts and services defined in the Filter Options tab in Preferences
     */
    
    private func shouldRemove(_ monitoringItem: MonitoringItem, filterItem: FilterItem, statusMapping: Dictionary<Int, String>) -> Bool {
        
        for (key, value) in statusMapping {
            if monitoringItem.status == value {
                if filterItem.status & key == key {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func removeMonitoringItem(_ monitoringItem: MonitoringItem, filterItem: FilterItem, monitoringItemType: MonitoringItemType, statusMapping: Dictionary<MonitoringItemType, Dictionary<Int, String>>) -> MonitoringItem? {

        if(monitoringItem.host.range(of: filterItem.host, options: .regularExpression) == nil) {
            return nil
        }
        
        if monitoringItemType == .service {
            if(monitoringItem.service.range(of: filterItem.service, options: .regularExpression) == nil) {
                return nil
            }
        }
        
        if self.shouldRemove(monitoringItem, filterItem: filterItem, statusMapping: statusMapping[monitoringItemType]!) {
            return monitoringItem
        }
        
        return nil
    }
    
    private func statusItemsForRemoval(_ currentItems: Array<MonitoringItem>) -> Array<MonitoringItem> {
        
        let serviceStatusMapping: Dictionary<Int, String> = [1: "PENDING", 4: "WARNING", 8: "UNKNOWN", 16: "CRITICAL"]
        let hostStatusMapping: Dictionary<Int, String> = [1: "PENDING", 4: "DOWN", 8: "UNREACHABLE"]
        
        let statusMapping: Dictionary<MonitoringItemType, Dictionary<Int, String>> = [.host: hostStatusMapping, .service: serviceStatusMapping]
        
        var statusItemsForRemoval: Array<MonitoringItem> = Array<MonitoringItem>()
        
        let filterItems = FilterItems().getAll() 
        
        // loop over all filter items to check if the list of monitoring items matches some of them
        for (_, filterItem) in filterItems {
            for monitoringItem in currentItems {
                let monitoringItemType = monitoringItem.monitoringItemType
                
                if let monitoringItemToRemove = self.removeMonitoringItem(monitoringItem, filterItem: filterItem, monitoringItemType: monitoringItemType, statusMapping: statusMapping) {
                        statusItemsForRemoval.append(monitoringItemToRemove)
                }
            }
        }
        
        return statusItemsForRemoval
    }
    
    override func process(_ processorRequest: ProcessorRequest) {
        
        super.process(processorRequest)
        
        // get the list of all status items that have to be removed
        let statusItemsForRemoval = self.statusItemsForRemoval(processorRequest.currentItems)
        
        let allItems = self.operation(processorRequest.allItems, diff: statusItemsForRemoval)
        let newProcessorRequest = ProcessorRequest(currentItems: processorRequest.currentItems, allItems: allItems, urlType: processorRequest.urlType)
        
        self.finish(nextProcessor, newProcessorRequest: newProcessorRequest)
    }
}

class FilterScheduledDowntimeProcessor : SubtractProcessor {
    /**
     Filter services whose hosts are in scheduled downtime (regardless of whether the host is
     up, down or unreachable
     */
    override func process(_ processorRequest: ProcessorRequest) {
        
        super.process(processorRequest)
        
        // process only if the last request is for host scheduled downtime
        if processorRequest.urlType != .hostScheduledDowntime {
            // set the next processor before returning
            if let nextProcessor = self.nextProcessor {
                nextProcessor.process(processorRequest)
            }
            
            return
        }
        
        var statusItemsForRemoval: Array<MonitoringItem> = Array<MonitoringItem>()
        
        for monitoringItemDowntime in processorRequest.currentItems {
            for monitoringItem in processorRequest.allItems {
                if monitoringItemDowntime.host == monitoringItem.host {
                    statusItemsForRemoval.append(monitoringItem)
                }
            }
        }
        
        let allItems = self.operation(processorRequest.allItems, diff: statusItemsForRemoval)
        let newProcessorRequest = ProcessorRequest(currentItems: processorRequest.currentItems, allItems: allItems, urlType: processorRequest.urlType)
        
        self.finish(nextProcessor, newProcessorRequest: newProcessorRequest)
    }
}


class AdditionProcessor : AddProcessor {
    /**
     The purpose of this class is just to add the current monitoring items to
     all monitoring items for the monitoring instance
     */
    override func process(_ processorRequest: ProcessorRequest) {
        
        super.process(processorRequest)
        
        let allItems = self.operation(processorRequest.allItems, diff: processorRequest.currentItems)
        let newProcessorRequest = ProcessorRequest(currentItems: processorRequest.currentItems, allItems: allItems, urlType: processorRequest.urlType)
        
        self.finish(nextProcessor, newProcessorRequest: newProcessorRequest)
    }
}
