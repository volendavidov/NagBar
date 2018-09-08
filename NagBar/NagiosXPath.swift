//
//  NagiosXPath.swift
//  NagBar
//
//  Created by Volen Davidov on 10/25/15.
//  Copyright © 2015 Volen Davidov. All rights reserved.
//

import Foundation

class NagiosXPath: XPathInterface {
    
    func getXPathHostQuery() -> String {
        return "/html/body/table[@class='status']/tr/td[1]/table/tr/td[1]/table/tr/td/a | /html/body/table[@class='status']/tr/td[not(@*)][not(node())]"
    }
    
    func getXPathHostQueryStatus() -> String {
        return "/html/body/div/table/tr/td[2]"
    }
    
    func getXPathHostQueryLastCheck() -> String {
        return "/html/body/div/table/tr/td[3]"
    }
    
    func getXPathHostQueryDuration() -> String {
        return "/html/body/div/table/tr/td[4]"
    }
    
    func getXPathHostQueryStatusInformation() -> String {
        return "/html/body/div/table/tr/td[5]"
    }
    
    func getXPathHostQueryItemUrl() -> String {
        return "/html/body/div/table/tr/td[1]/table/tr/td[1]/table/tr/td/a/@href"
    }
    
    func getXPathHostAcknowledged() -> String {
        return "/html/body/div/table/tr/td[1]/table/tr/td[2]/table/tr/td/a/img[@src='/nagios/images/ack.gif']/@src | /html/body/div/table/tr/td[1]/table/tr/td[2]/table/tr[not(./td/a/img[@src='/nagios/images/ack.gif'])]"
    }
    
    func getXPathHostDowntime() -> String {
        return "/html/body/div/table/tr/td[1]/table/tr/td[2]/table/tr/td/a/img[@src='/nagios/images/downtime.gif']/@src | /html/body/div/table/tr/td[1]/table/tr/td[2]/table/tr[not(./td/a/img[@src='/nagios/images/downtime.gif'])]"
    }
    
    func getXPathServiceQuery() -> String {
        return "/html/body/table/tr/td[2]/table/tr/td[1]/table/tr/td/a"
    }
    
    func getXPathServiceQueryStatus() -> String {
        return "/html/body/table[@class='status']/tr/td[3]"
    }
    
    func getXPathServiceQueryLastCheck() -> String {
        return "/html/body/table[@class='status']/tr/td[4]"
    }
    
    func getXPathServiceQueryDuration() -> String {
        return "/html/body/table[@class='status']/tr/td[5]"
    }
    
    func getXPathServiceQueryAttempt() -> String {
        return "/html/body/table[@class='status']/tr/td[6]"
    }
    
    func getXPathServiceQueryStatusInformation() -> String {
        return "/html/body/table[@class='status']/tr/td[7]"
    }
    
    func getXPathServiceQueryItemUrl() -> String {
        return "/html/body/table[@class='status']/tr/td[2]/table/tr/td[1]/table/tr/td/a/@href"
    }
    
    func getXPathServiceAcknowledged() -> String {
        return "/html/body/table[@class='status']/tr/td[2]/table/tr/td[2]/table/tr/td/a/img[@src='/nagios/images/ack.gif']/@src | /html/body/table[@class='status']/tr/td[2]/table/tr/td[2]/table/tr[not(./td/a/img[@src='/nagios/images/ack.gif'])]"
    }
    
    func getXPathServiceDowntime() -> String {
        return "/html/body/table[@class='status']/tr/td[2]/table/tr/td[2]/table/tr/td/a/img[@src='/nagios/images/downtime.gif']/@src | /html/body/table[@class='status']/tr/td[2]/table/tr/td[2]/table/tr[not(./td/a/img[@src='/nagios/images/downtime.gif'])]"
    }
    
    func getXPathHostpageQuery() -> String {
        return "/html/body/div/table/tr/td[1]/table/tr/td[1]/table/tr/td/a"
    }
}
