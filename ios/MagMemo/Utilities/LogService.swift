//
//  LogService.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/9.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit

class LogService {
    
    /*
    // MARK: - Properties
    static let shared = NetworkManager(baseURL: API.baseURL)
    
    // MARK: -
    let baseURL: URL
    
    // Initialization
    private init(baseURL: URL) {
        self.baseURL = baseURL
    }
    */
    
    static let shared = LogService()
    
    private var log:String = "log msg:\n"
    
    private init()
    {
        // Set up API instance
    }
    
    func add(log:String) {
        self.log.append("\n\(log)")
    }
    
    func addLogNoNewLine(log:String) {
        self.log.append("\(log)")
    }
    
    func addLogWithNewLine(log:String) {
        self.log.append("\n\(log)\n")
    }
    
    func getLog() -> String {
        return self.log
    }
    
    func cleanLog() {
        self.log = ""
    }

}
