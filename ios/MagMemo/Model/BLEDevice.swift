//
//  BLEDevice.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/27.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEDevice: NSObject {
    
    var peripheral:CBPeripheral
    var advertisementData:[AnyHashable : Any]
    var UUID: String
    var localName: String?
    var rssi: NSNumber
    var pingTime: Int = 0
    var macAddress: [UInt8]?
    var manufactureName: [UInt8]?
    var manufactureNameLength: UInt8?
    
    init(peripheral: CBPeripheral, UUID: String, advertisementDictionary:[AnyHashable : Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementDictionary
        self.UUID = UUID
        self.rssi = rssi
    }
    /*
    init (macAddress:[UInt8], manufactureName:[UInt8], manufactureNameLength:UInt8) {
        self.macAddress = macAddress
        self.manufactureName = manufactureName
        self.manufactureNameLength = manufactureNameLength
    }
    */
    
    public func updateRSSI(_ rssi: NSNumber) {
        self.rssi = rssi
    }
    
}
