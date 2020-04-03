//
//  APModel.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/4.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit

class APModel: NSObject {
    
    var ssid: String?
    var bssid: String?
    var bssidData: Data?
    var bssidBytes: [UInt8]?
    var rssi: NSNumber?
    var connected: Int = 0
    var authMode: Int = 0 //Open (0), WEP (1), WPA_PSK (2), WPA2_PSK (3), WPA_WPA_2_PSK(4), WPA2_ENTERPRISE (5)
    
    var ipAddress: String?
    var maskAddress: String?
    var gatewayAddress: String?
    
    init(ssid: String, bssid: String, bssidData:Data?, bssidBytes:[UInt8]?, authMode: Int, connected: Int) {
        self.ssid = ssid
        self.bssid = bssid
        self.bssidData = bssidData
        self.bssidBytes = bssidBytes
        self.authMode = authMode
        self.connected = connected
    }
    
    init(ipAddress: String, maskAddress: String, gatewayAddress: String) {
        self.ipAddress = ipAddress
        self.maskAddress = maskAddress
        self.gatewayAddress = gatewayAddress
    }
    

}
