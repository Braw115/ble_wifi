//
//  NetstrapService.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/7.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import CoreBluetooth

class NetstrapService {
    
    class func scanWiFi() {
        LogService.shared.add(log: "-> [TO_SCAN_WIFI]")
        LogService.shared.add(log: "-> [SCAN_WIFI_REQ]")
        //let bytes : [UInt8] = [0x00, 0x00, 0x02, 0x00, 0x01, 0x02]
        //let data = Data(bytes)
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_BLEWIFI_REQ_SCAN)
        let dataLength:[UInt8] = [0x02, 0x00]
        bytesArray.append(contentsOf: dataLength)
        bytesArray.append(0x01) //show_hidden
        bytesArray.append(0x02) //scan_type
        let data = Data(bytesArray)
        BluetoothManager.sharedInstance().writeValue(data: data)
    }
    
    class func connectWiFi(bytes:[UInt8]) {
        LogService.shared.add(log: "-> [TO_CONNECT_WIFI]")
        LogService.shared.add(log: "-> [CONNECT_WIFI_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_BLEWIFI_REQ_CONNECT)
        bytesArray.append(contentsOf: bytes)
        let data = Data(bytesArray)
        //print("hexDataStr:", HexConverter.bytesDataToHexString(data: data))
        BluetoothManager.sharedInstance().writeValue(data: data)
    }
    
    class func getWifiStatus() {
        LogService.shared.add(log: "-> [GET_WIFI_STATUS]")
        LogService.shared.add(log: "-> [GET_WIFI_STATUS_REQ]")
        //let bytes : [UInt8] = [0x06, 0x00, 0x00, 0x00]
        //let data = Data(bytes)
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_BLEWIFI_REQ_WIFI_STATUS)
        let dataLength:[UInt8] = [0x00, 0x00]
        bytesArray.append(contentsOf: dataLength)
        let data = Data(bytesArray)
        BluetoothManager.sharedInstance().writeValue(data: data)
    }
    
    class func wifiReset() {
        LogService.shared.add(log: "-> [TO_RESET_WIFI]")
        LogService.shared.add(log: "-> [TO_RESET_WIFI_REQ]")
        //let bytes : [UInt8] = [0x07, 0x00, 0x00, 0x00]
        //let data = Data(bytes)
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_BLEWIFI_REQ_RESET)
        let dataLength:[UInt8] = [0x00, 0x00]
        bytesArray.append(contentsOf: dataLength)
        let data = Data(bytesArray)
        BluetoothManager.sharedInstance().writeValue(data: data)
    }
    
    //class func readBLEDeviceInfo(completion: @escaping (_ data: Data) -> Void) {
    class func readBLEDeviceInfo() {
        LogService.shared.add(log: "-> [TO_READ_BLE_DEVICE_INFO]")
        LogService.shared.add(log: "-> [TO_RESET_WIFI_REQ]")
        //let bytes : [UInt8] = [0x04, 0x00, 0x00, 0x00]
        //let data = Data(bytes)
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_BLEWIFI_REQ_READ_DEVICE_INFO)
        bytesArray.append(contentsOf: [0x00, 0x00])
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))

    }
    
    class func readBLEMAC() {
        LogService.shared.add(log: "-> [TO_READ_BLE_MAC]")
        LogService.shared.add(log: "-> [TO_READ_BLE_MAC_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_READ_BLE_MAC_REQ)
        bytesArray.append(contentsOf: [0x00, 0x00])
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
        
    }
    
    class func writeBLEMAC(mac:String) {
        LogService.shared.add(log: "-> [TO_WRITE_BLE_MAC]")
        LogService.shared.add(log: "-> [TO_WRITE_BLE_MAC_REQ]")
        
        let newMacString = mac.replacingOccurrences(of: ":", with: "")
        let macBytes = HexConverter.hexStringToBytesArray(hexString: newMacString)
        
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_WRITE_BLE_MAC_REQ)
        bytesArray.append(contentsOf: [0x06, 0x00])
        bytesArray.append(contentsOf: macBytes)
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
        
    }
    
    class func readWiFiMAC() {
        LogService.shared.add(log: "-> [TO_READ_WIFI_MAC]")
        LogService.shared.add(log: "-> [TO_READ_WIFI_MAC_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_READ_WIFI_MAC_REQ)
        bytesArray.append(contentsOf: [0x00, 0x00])
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    class func writeWiFiMAC(mac:String) {
        LogService.shared.add(log: "-> [TO_WRITE_WIFI_MAC]")
        LogService.shared.add(log: "-> [TO_WRITE_WIFI_MAC_REQ]")
        
        let newMacString = mac.replacingOccurrences(of: ":", with: "")
        let macBytes = HexConverter.hexStringToBytesArray(hexString: newMacString)
        
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_WRITE_WIFI_MAC_REQ)
        bytesArray.append(contentsOf: [0x06, 0x00])
        bytesArray.append(contentsOf: macBytes)
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    class func resetDevice() {
        LogService.shared.add(log: "-> [TO_RESET_DEVICE]")
        LogService.shared.add(log: "-> [TO_RESET_DEVICE_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_RESET_DEVICE_REQ)
        bytesArray.append(contentsOf: [0x00, 0x00])
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    class func readOTAVersion() {
        LogService.shared.add(log: "-> [TO_READ_FIRMWARE_VERSION]")
        LogService.shared.add(log: "-> [OTA_VERSION_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_BLEWIFI_REQ_OTA_VERSION)
        bytesArray.append(contentsOf: [0x00, 0x00])
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    class func requestOTAUpgrade(fwHearderBytes:[UInt8]) {
        //LogService.shared.add(log: "-> [OTA_UPGRADE_REQ]")
        LogService.shared.add(log: "[OTA_UPGRADE_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_BLE_REQ_OTA_UPGRADE)
        
        let dataLengthBytes = HexConverter.dataLengthToBytesArray(dataLength: 26, arrayCount: 2)
        bytesArray.append(contentsOf: dataLengthBytes.reversed())
        
        let maxRxPacketCount: [UInt8] = HexConverter.dataLengthToBytesArray(dataLength: NetstrapConstants.maxRxPacketCount, arrayCount: 2)
        bytesArray.append(contentsOf: maxRxPacketCount.reversed())
        bytesArray.append(contentsOf: fwHearderBytes)
        
        //let hexString = HexConverter.bytesArrayToStringWithSpace(bytes: bytesArray)
        //LogService.shared.addLogWithNewLine(log: "*** Tx \(hexString)")
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    class func requestOTARawData(rawData:[UInt8], dataLength:Int) {
        //LogService.shared.add(log: "-> [OTA_START_SEND_RAW_DATA]")
        //LogService.shared.add(log: "[OTA_UPGRADE_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_BLE_REQ_OTA_RAW_DATA)
        
        //let dataLengthBytes: [UInt8] = HexConverter.dataLengthToBytesArray(dataLength: NetstrapConstants.maxTransferUnit, arrayCount: 2)
        let dataLengthBytes: [UInt8] = HexConverter.dataLengthToBytesArray(dataLength: dataLength, arrayCount: 2)
        bytesArray.append(contentsOf: dataLengthBytes.reversed())
        bytesArray.append(contentsOf: rawData)
        //print("OTA Raw Data BytesArray:\(bytesArray)")
        //LogService.shared.addLogNoNewLine(log: "#")
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray), writeLog: AppConfig.internalDebug)
    }
    
    class func requestOTAEnd() {
        LogService.shared.add(log: "-> [OTA_END_REQ]")
        //LogService.shared.add(log: "[OTA_UPGRADE_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_BLE_REQ_OTA_END)
        
        let dataLengthBytes: [UInt8] = [0x01, 0x00]
        bytesArray.append(contentsOf: dataLengthBytes)
        bytesArray.append(0x00)
        
        //let hexString = HexConverter.bytesArrayToStringWithSpace(bytes: bytesArray)
        //LogService.shared.add(log: "*** Tx \(hexString)")
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    class func setInitMode() {
        LogService.shared.add(log: "-> [SET_INIT_MODE]")
        LogService.shared.add(log: "[INIT_MODE_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_SET_DEVICE_MODE)
        let dataLengthBytes: [UInt8] = HexConverter.dataLengthToBytesArray(dataLength: 1, arrayCount: 2)
        bytesArray.append(contentsOf: dataLengthBytes.reversed())
        bytesArray.append(0x00)
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    class func setUserMode() {
        LogService.shared.add(log: "-> [SET_USER_MODE]")
        LogService.shared.add(log: "[USER_MODE_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_SET_DEVICE_MODE)
        let dataLengthBytes: [UInt8] = HexConverter.dataLengthToBytesArray(dataLength: 1, arrayCount: 2)
        bytesArray.append(contentsOf: dataLengthBytes.reversed())
        bytesArray.append(0x02)
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    class func readDeviceMode() {
        LogService.shared.add(log: "-> [READ_DEVICE_MODE]")
        LogService.shared.add(log: "[READ_DEVICE_MODE_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_READ_DEVICE_MODE)
        bytesArray.append(contentsOf: [0x00, 0x00])
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    class func sendSingleTone(mode:String, freq:String) {
        LogService.shared.add(log: "-> [SEND_SINGLE_TONE]")
        LogService.shared.add(log: "[SEND_SINGLE_TONE_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_SEND_SINGLE_TONE_REQ)
        bytesArray.append(contentsOf: [0x06, 0x00])
        
        let modeInt = Int(mode)
        let freqInt = Int(freq)
        
        if modeInt == 1 {
            bytesArray.append(contentsOf: [0x01, 0x00])
            
            /*
            let hexStr = freqInt!.toHexa
            let byteStr = "0" + hexStr
            let hexStringArray = byteStr.hexStringAddComma
            let bytes = HexConverter.hexStringArrayToBytesArray(hexString: hexStringArray)
            bytesArray.append(contentsOf: bytes.reversed())
            bytesArray.append(contentsOf: [0x00, 0x00])
            */
            let freqBytes = HexConverter.dataLengthToBytesArray(dataLength: freqInt!, arrayCount: 6)
            bytesArray.append(contentsOf: freqBytes.reversed())
            print("Mode 1 freqBytes:\(freqBytes)")
            print("")
        }
        else {
            //bytesArray.append(contentsOf: [0x03, 0x00])
            //bytesArray.append(contentsOf: [freqInt!.toU8,0x00, 0x00, 0x00])
            let freqBytes = HexConverter.dataLengthToBytesArray(dataLength: freqInt!, arrayCount: 6)
            bytesArray.append(contentsOf: freqBytes.reversed())
            print("Mode 3 freqBytes:\(freqBytes)")
            print("")
        }
        //let modeBytes:[UInt8] = [0x03, 0x00]
        //bytesArray.append(contentsOf: modeBytes)
        
        
        //let freqBytes:[UInt8] = [0x01, 0x00, 0x00, 0x00]
        //bytesArray.append(contentsOf: freqBytes)
        //[07,06,06,00, 03,00, 01,00,00,00]
        print("sendSingleTone bytesArray:\(bytesArray)")
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
        
    }
    
    class func sendBLEString(str:String) {
        LogService.shared.add(log: "-> [SEND_BLE_STR]")
        LogService.shared.add(log: "[SEND_BLE_STR_REQ]")
        var bytesArray = NetstrapPacket.getCmdId(packageType: .CMD_SEND_BLE_STR_REQ)
        let dataLengthBytes = HexConverter.dataLengthToBytesArray(dataLength: str.count, arrayCount: 2)
        bytesArray.append(contentsOf: dataLengthBytes.reversed())
        //let strBytes:[UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06]
        let strBytes = HexConverter.stringToBytesArray(str: str)
        bytesArray.append(contentsOf: strBytes)
        
        //let hexString = HexConverter.bytesArrayToStringWithSpace(bytes: bytesArray)
        //LogService.shared.add(log: "*** Tx \(hexString)")
        BluetoothManager.sharedInstance().writeValue(data: Data(bytesArray))
    }
    
    
    class func checkReceivePacketType(data:Data) -> NetstrapPacketType {
        let byteArray = [UInt8](data)
        if (byteArray.count < 2) {
            return NetstrapPacketType.UNKNOWN_TYPE
        }
        
        let cmdIdByteArray = Array(byteArray[0...1])
        let data = Data(cmdIdByteArray.reversed())
        var hexString = HexConverter.bytesDataToHexString(data: data)
        hexString = "0x\(hexString)"
        
        return NetstrapPacket.checkCmdType(hexString: hexString)

    }

}
