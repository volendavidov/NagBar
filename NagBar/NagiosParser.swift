//
//  NagiosIcingaParser.swift
//  NagBar
//
//  Created by Volen Davidov on 10/25/15.
//  Copyright © 2015 Volen Davidov. All rights reserved.
//

import Foundation
import Hpple

class NagiosParser: MonitoringProcessorBase, ParserInterface {
    
    var xPathProvider: XPathInterface!
    
    override init(_ monitoringInstance: MonitoringInstance) {
        super.init(monitoringInstance)
        self.xPathProvider = NagiosXPath()
    }
    
    func parse(urlType: MonitoringURLType, data: Data) -> Array<MonitoringItem> {
        
        switch urlType {
        case .hosts:
            return self.getHostMonitoringItems(data)
        case .services:
            return self.getServiceMonitoringItems(data)
        case .hostScheduledDowntime:
            return self.getHostMonitoringItems(data)
        }
    }
    
    private func getHostMonitoringItems(_ data: Data) -> Array<HostMonitoringItem> {
        
        let hppleData = TFHpple.init(htmlData: data)
        let statusCGIHost = hppleData?.search(withXPathQuery: self.xPathProvider.getXPathHostpageQuery())
        
        var hostList = [String]()
        
        for element in statusCGIHost! {
            let item: String = (element as AnyObject).firstChild!.content
            hostList.append(item)
        }
        
        let statusList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathHostQueryStatus()) as NSArray)
        let lastCheckList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathHostQueryLastCheck()) as NSArray)
        let durationList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathHostQueryDuration()) as NSArray)
        let statusInformationList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathHostQueryStatusInformation()) as NSArray)
        let itemUrlList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathHostQueryItemUrl()) as NSArray)
        
        var hostItems = [HostMonitoringItem]()
        
        for i in 0 ..< hostList.count {
            let item = HostMonitoringItem()
            
            item.host = self.getValue(hostList, index: i)
            item.status = self.getValue(statusList, index: i)
            item.lastCheck = self.getValue(lastCheckList, index: i)
            item.duration = self.getValue(durationList, index: i)
            item.statusInformation = self.getValue(statusInformationList, index: i)
            item.itemUrl = self.getItemUrl(self.getValue(itemUrlList, index: i))
            item.monitoringInstance = self.monitoringInstance
            
            hostItems.append(item)
        }
        
        return hostItems
    }
    
    private func getServiceMonitoringItems(_ data: Data) -> Array<ServiceMonitoringItem> {
        
        let hppleData = TFHpple.init(htmlData: data)
        let statusCGIHost = hppleData?.search(withXPathQuery: self.xPathProvider.getXPathHostQuery())
        
        var hostList = [String]()
        
        var prevHost = ""
        
        for element in statusCGIHost! {
            var item: String?
            
            // we need this for multiple services in a host - if an element does not have children, then the host field is empty and it is just a service of a host
            if (element as AnyObject).hasChildren() {
                item = (element as AnyObject).firstChild!.content
                prevHost = item!
            } else {
                item = prevHost
            }
            
            hostList.append(item!)
        }
        
        
        let statusCGIService = hppleData?.search(withXPathQuery: self.xPathProvider.getXPathServiceQuery())
        
        var serviceList = [String]()
        
        for element in statusCGIService! {
            let item: String = (element as AnyObject).firstChild!.content
            serviceList.append(item)
        }
        
        let statusList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathServiceQueryStatus()) as NSArray)
        let lastCheckList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathServiceQueryLastCheck()) as NSArray)
        let durationList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathServiceQueryDuration()) as NSArray)
        let attemptList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathServiceQueryAttempt()) as NSArray)
        let statusInformationList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathServiceQueryStatusInformation()) as NSArray)
        let itemUrlList = self.generateList(hppleData!.search(withXPathQuery: self.xPathProvider.getXPathServiceQueryItemUrl()) as NSArray)
        
        var serviceItems = [ServiceMonitoringItem]()
        
        for i in 0 ..< serviceList.count {
            let item = ServiceMonitoringItem()
            
            item.host = self.getValue(hostList, index: i)
            item.service = self.getValue(serviceList, index: i)
            item.status = self.getValue(statusList, index: i)
            item.lastCheck = self.getValue(lastCheckList, index: i)
            item.duration = self.getValue(durationList, index: i)
            item.attempt = self.getValue(attemptList, index: i)
            item.statusInformation = self.getValue(statusInformationList, index: i)
            item.itemUrl = self.getItemUrl(self.getValue(itemUrlList, index: i))
            item.monitoringInstance = self.monitoringInstance
            
            serviceItems.append(item)
        }
        
        return serviceItems
    }
    
    private func getValue(_ list: Array<String>, index: Int) -> String {
        
        var value = ""
        
        if !list.indices.contains(index) {
            NSLog("Index \(index) does not exist in serviceList")
        } else {
            value = list[index]
        }
        
        return value
    }
    
    private func generateList(_ hppleData: NSArray) -> Array<String> {
        var itemList = Array<String>()
        
        for element in hppleData {
            
            let item = (element as AnyObject).firstChild!.content
            
            // for some reason there are elements containing newlines so we want to ignore them
            let itemRange = item?.range(of: "^\n")
            
            if !(item?.isEmpty)! && itemRange == nil {
                itemList.append(item!)
            }
        }
        
        return itemList
    }
    
    private func getItemUrl(_ itemUrl: String) -> String {
        let monitoringInstanceURL = NagiosParser.stripStatusCGI(self.monitoringInstance!.url)
        return monitoringInstanceURL + itemUrl
    }
    
    static func stripStatusCGI(_ itemUrl: String) -> String {
        if let index = itemUrl.range(of: "status.cgi", options: .regularExpression) {
            var urlCopy = itemUrl
            urlCopy.removeSubrange(index)
            
            return urlCopy
        } else {
            return itemUrl
        }
    }
    
    func parseStartTime(_ data: Data) -> String {
        let startTime = self.getTimeElement(data, query: "//input[@name='start_time']")
        return startTime
    }
    
    func parseEndTime(_ data: Data) -> String {
        let endTime = self.getTimeElement(data, query: "//input[@name='end_time']")
        return endTime
    }
    
    private func getTimeElement(_ data: Data, query: String) -> String {
        
        var time = ""
        
        let hppleData = TFHpple.init(htmlData: data)
        
        for element in (hppleData?.search(withXPathQuery: query))! {
            time = (element as! TFHppleElement).attributes["value"]! as! String
        }
        
        return time
    }
}
