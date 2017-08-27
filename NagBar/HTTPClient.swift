//
//  HTTPClient.swift
//  NagBar
//
//  Created by Volen Davidov on 02.07.16.
//  Copyright © 2016 Volen Davidov. All rights reserved.
//

import Foundation
import PromiseKit

protocol HTTPClient {
    func get(_ url: String) -> Promise<Data>
    func checkConnection() -> Promise<Bool>
    func post(_ url: String, postData: Dictionary<String, String>) -> Promise<Data>
}
