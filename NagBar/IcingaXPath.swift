//
//  IcingaXPath.swift
//  NagBar
//
//  Created by Volen Davidov on 03.01.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//
// There are two version of the beginning of the query as per the following Icinga versions:
// 1.8.1 - /html/body/*[@id='tableformhost']/table[4]/
// 1.6.1 - /html/body/*[@id='tableformhost']/div/table/

import Foundation

class IcingaXPath: XPathInterface {
    func getXPathHostQuery() -> String {
        return "/html/body/*[@id='tableformservice']/table[4]/tr/td[1]/table/tr/td[1]/table/tr/td/a | /html/body/*[@id='tableformservice']/table[4]/tr/td[not(@*)][not(node())] | /html/body/*[@id='tableformservice']/div/table/tr/td[1]/table/tr/td[1]/table/tr/td/a | /html/body/*[@id='tableformservice']/div/table/tr/td[not(@*)][not(node())]"
    }
    
    func getXPathHostQueryStatus() -> String {
        return "/html/body/*[@id='tableformhost']/table[4]/tr/td[2] | /html/body/*[@id='tableformhost']/div/table/tr/td[2]"
    }
    
    func getXPathHostQueryLastCheck() -> String {
        return "/html/body/*[@id='tableformhost']/table[4]/tr/td[3] | /html/body/*[@id='tableformhost']/div/table/tr/td[3]"
    }
    
    func getXPathHostQueryDuration() -> String {
        return "/html/body/*[@id='tableformhost']/table[4]/tr/td[4] | /html/body/*[@id='tableformhost']/div/table/tr/td[4]"
    }
    
    func getXPathHostQueryStatusInformation() -> String {
        return "/html/body/*[@id='tableformhost']/table[4]/tr/td[6] | /html/body/*[@id='tableformhost']/div/table/tr/td[6]"
    }
    
    func getXPathHostQueryItemUrl() -> String {
        return "/html/body/*[@id='tableformhost']/table[4]/tr/td[1]/table/tr/td[1]/table/tr/td/a/@href | /html/body/*[@id='tableformhost']/div/table/tr/td[1]/table/tr/td[1]/table/tr/td/a/@href"
    }
    
    func getXPathServiceQuery() -> String {
        return "/html/body/*[@id='tableformservice']/table[4]/tr/td[2]/table/tr/td[1]/table/tr/td/a | /html/body/*[@id='tableformservice']/div/table/tr/td[2]/table/tr/td[1]/table/tr/td/a"
    }
    
    func getXPathServiceQueryStatus() -> String {
        return "/html/body/*[@id='tableformservice']/table[4]/tr/td[3] | /html/body/*[@id='tableformservice']/div/table/tr/td[3]"
    }
    
    func getXPathServiceQueryLastCheck() -> String {
        return "/html/body/*[@id='tableformservice']/table[4]/tr/td[4] | /html/body/*[@id='tableformservice']/div/table/tr/td[4]"
    }
    
    func getXPathServiceQueryDuration() -> String {
        return "/html/body/*[@id='tableformservice']/table[4]/tr/td[5] | /html/body/*[@id='tableformservice']/div/table/tr/td[5]"
    }
    
    func getXPathServiceQueryAttempt() -> String {
        return "/html/body/*[@id='tableformservice']/table[4]/tr/td[6] | /html/body/*[@id='tableformservice']/div/table/tr/td[6]"
    }
    
    func getXPathServiceQueryStatusInformation() -> String {
        return "/html/body/*[@id='tableformservice']/table[4]/tr/td[7] | /html/body/*[@id='tableformservice']/div/table/tr/td[7]"
    }
    
    func getXPathServiceQueryItemUrl() -> String {
        return "/html/body/*[@id='tableformservice']/table[4]/tr/td[2]/table/tr/td[1]/table/tr/td/a/@href | /html/body/*[@id='tableformservice']/div/table/tr/td[2]/table/tr/td[1]/table/tr/td/a/@href"
    }
    
    func getXPathHostpageQuery() -> String {
        return "//*[@id='tableformhost']/table[4]/tr/td[1]/table/tr/td[1]/table/tr/td/a | //*[@id='tableformhost']/div/table/tr/td[1]/table/tr/td[1]/table/tr/td/a"
    }
}
