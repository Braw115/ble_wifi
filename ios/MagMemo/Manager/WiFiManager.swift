//
//  WiFiManager.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/14.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit

class WiFiManager: NSObject {
    
    private static var mInstance:WiFiManager?
    static func sharedInstance() -> WiFiManager {
        if mInstance == nil {
            mInstance = WiFiManager()
            
        }
        return mInstance!
    }
    
    var isConnected = false
    var connectAP: APModel?

}
