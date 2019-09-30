//
//  NagiosCommands.swift
//  NagBar
//
//  Created by Volen Davidov on 30.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import PromiseKit

class NagiosCommands : MonitoringProcessorBase, CommandInterface {
    
    func capabilities() -> Array<CommandTypes> {
        return [CommandTypes.acknowledge, CommandTypes.openInBrowser, CommandTypes.recheck, CommandTypes.scheduleDowntime]
    }
    
    func getTime(_ monitoringItems: Array<MonitoringItem>) -> Promise<(String,String)> {
        
        return Promise<(String,String)>{ seal in
        
            let nagiosTimeUrl = NagiosParser.stripStatusCGI(self.monitoringInstance!.url) + String(format: "cmd.cgi?cmd_typ=55&host=%@", monitoringItems[0].host)
        
            let promise: Promise<Data> = Promise<Data>.value(Data())
        
            promise.then { _ -> Promise<Data> in
                // get the start time from nagios first
                return self.monitoringInstance!.monitoringProcessor().httpClient().get(nagiosTimeUrl)
                }.done { data -> Void in
                    // parse the start time
                    let startTime = NagiosParser(self.monitoringInstance!).parseStartTime(data)
                    let endTime = NagiosParser(self.monitoringInstance!).parseEndTime(data)
                    seal.fulfill((startTime, endTime))
                }.catch { error in
                    seal.reject(error)
                }
        }
    }
    
    func recheck(_ monitoringItems: Array<MonitoringItem>) {
        
        var promise: Promise<String> = Promise<String>.value("")
        
        let nagiosTimeUrl = NagiosParser.stripStatusCGI(self.monitoringInstance!.url) + String(format: "cmd.cgi?cmd_typ=55&host=%@", monitoringItems[0].host)
        
        
        promise = promise.then { _ -> Promise<Data> in
            // get the start time from nagios first
            return self.monitoringInstance!.monitoringProcessor().httpClient().get(nagiosTimeUrl)
        }.then { data -> Promise<String> in
            // parse the start time
            return Promise { seal in
                let parser = NagiosParser(self.monitoringInstance!)
                seal.fulfill(parser.parseStartTime(data as Data))
            }
        }
        
        // recheck each of the selected monitoring items
        for monitoringItem in monitoringItems {
            _ = promise.then {startTime -> Promise<Data> in
                
                var parameters: Dictionary<String, String> = [
                    "cmd_typ": "96",
                    "cmd_mod": "2",
                    "start_time": startTime,
                    "host": monitoringItem.host,
                    "force_check": "on",
                    "btnSubmit": "Commit"
                ]
                    
                if monitoringItem.monitoringItemType == .service {
                    parameters["cmd_typ"] = "7"
                    parameters["service"] = monitoringItem.service
                }
                

                return self.monitoringInstance!.monitoringProcessor().httpClient().post(NagiosParser.stripStatusCGI(self.monitoringInstance!.url) + "cmd.cgi", postData: parameters)
            }
        }
        
        promise.catch { err in
            NSLog("Unable to execute recheck, error: %@", err.localizedDescription)
        }
    }
    
    func scheduleDowntime(_ monitoringItems: Array<MonitoringItem>, from: String, to: String, comment: String, type: String, hours: String, minutes: String) {
        
        var promise: Promise<Data> = Promise<Data>.value(Data())
        
        for monitoringItem in monitoringItems {
            promise = promise.then { _ -> Promise<Data> in
                
                var parameters: Dictionary<String, String> = [
                    "cmd_typ": "55",
                    "cmd_mod": "2",
                    "start_time": from,
                    "end_time": to,
                    "host": monitoringItem.host,
                    "com_data": comment,
                    "fixed": type,
                    "hours": hours,
                    "minutes": minutes,
                    "btnSubmit": "Commit"
                ]
                
                if monitoringItem.monitoringItemType == .service {
                    parameters["cmd_typ"] = "56"
                    parameters["service"] = monitoringItem.service
                }
                
                return self.monitoringInstance!.monitoringProcessor().httpClient().post(NagiosParser.stripStatusCGI(self.monitoringInstance!.url) + "cmd.cgi", postData: parameters)
                
            }
        }
        
        promise.catch { err in
            NSLog("Unable to execute scheduleDowntime, error: %@", err.localizedDescription)
        }
    }
    
    
    
    func acknowledge(_ monitoringItems: Array<MonitoringItem>, comment: String) {

        var promise: Promise<Data> = Promise<Data>.value(Data())
        
        for monitoringItem in monitoringItems {
            promise = promise.then { _ -> Promise<Data> in
                
                var parameters: Dictionary<String, String> = [
                    "cmd_typ": "33",
                    "cmd_mod": "2",
                    "host": monitoringItem.host,
                    "com_data": comment,
                    "btnSubmit": "Commit"
                ]
                
                if monitoringItem.monitoringItemType == .service {
                    parameters["cmd_typ"] = "34"
                    parameters["service"] = monitoringItem.service
                }
                
                return self.monitoringInstance!.monitoringProcessor().httpClient().post(NagiosParser.stripStatusCGI(self.monitoringInstance!.url) + "cmd.cgi", postData: parameters)
                
            }
        }
        
        promise.catch { err in
            NSLog("Unable to execute acknowledge, error: %@", err.localizedDescription)
        }
    }
}
