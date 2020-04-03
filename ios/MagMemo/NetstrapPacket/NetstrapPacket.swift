//
//  NetstrapPacket.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/31.
//  Copyright © 2019 YonLau. All rights reserved.
//


import UIKit

enum NetstrapPacketType: String, CaseIterable  {
    
    /*** BLEWIFI ***/
    case CMD_BLEWIFI_REQ_SCAN = "0x0000"
    case CMD_BLEWIFI_REQ_CONNECT = "0x0001"
    case CMD_BLEWIFI_REQ_DISCONNECT = "0x0002"
    case CMD_BLEWIFI_REQ_RECONNECT = "0x0003"
    case CMD_BLEWIFI_REQ_READ_DEVICE_INFO = "0x0004"
    case CMD_BLEWIFI_REQ_WRITE_DEVICE_INFO = "0x0005"
    case CMD_BLEWIFI_REQ_WIFI_STATUS = "0x0006"
    case CMD_BLEWIFI_REQ_RESET = "0x0007"
    case EVT_BLEWIFI_RSP_SCAN_REPORT = "0x1000"
    case EVT_BLEWIFI_RSP_SCAN_END = "0x1001"
    case EVT_BLEWIFI_RSP_CONNECT = "0x1002"
    case EVT_BLEWIFI_RSP_DISCONNECT = "0x1003"
    case EVT_BLEWIFI_RSP_RECONNECT = "0x1004"
    case EVT_BLEWIFI_RSP_READ_DEVICE_INFO = "0x1005"
    case EVT_BLEWIFI_RSP_WRITE_DEVICE_INFO = "0x1006"
    case EVT_BLEWIFI_RSP_WIFI_STATUS = "0x1007"
    case EVT_BLEWIFI_RSP_RESET = "0x1008"
    
    /*** OTA ***/
    case CMD_BLEWIFI_REQ_OTA_VERSION = "0x0100"
    case CMD_BLE_REQ_OTA_UPGRADE = "0x0101"
    case CMD_BLE_REQ_OTA_RAW_DATA = "0x0102"
    case CMD_BLE_REQ_OTA_END = "0x0103"
    case EVT_BLE_RSP_OTA_VERSION = "0x1100"
    case EVT_BLE_RSP_OTA_UPGRADE = "0x1101"
    case EVT_BLE_RSP_OTA_RAW_DATA = "0x1102"
    case EVT_BLE_RSP_OTA_END = "0x1103"
    
    /*** MODE ***/
    case CMD_SET_DEVICE_MODE = "0x0404"
    case CMD_READ_DEVICE_MODE = "0x0405"
    case EVT_SET_DEVICE_MODE_RSP = "0x1404"
    case EVT_READ_DEVICE_MODE_RSP = "0x1405"
    
    /*** Read/Write MAC ***/
    case CMD_RESET_DEVICE_REQ = "0x0601"
    case CMD_WRITE_WIFI_MAC_REQ = "0x0602"
    case CMD_READ_WIFI_MAC_REQ = "0x0603"
    case CMD_WRITE_BLE_MAC_REQ = "0x0604"
    case CMD_READ_BLE_MAC_REQ = "0x0605"
    case CMD_SEND_BLE_STR_REQ = "0x0606"
    case CMD_SEND_SINGLE_TONE_REQ = "0x0607"
    case EVT_RESET_DEVICE_RSP = "0x1601"
    case EVT_WRITE_WIFI_MAC_RSP = "0x1602"
    case EVT_READ_WIFI_MAC_RSP = "0x1603"
    case EVT_WRITE_BLE_MAC_RSP = "0x1604"
    case EVT_READ_BLE_MAC_RSP = "0x1605"
    case EVT_END_BLE_STR_RSP = "0x1606"
    case EVT_SEND_SINGLE_TONE_RSP = "0x1607"
    
    
    case UNKNOWN_TYPE = "0x9999"
    
    static let allValues = NetstrapPacketType.allCases.map { $0.rawValue }
}

enum BytesOrderType: Int {
    case littleEndian = 0
    case bigEndian = 1
}

struct NetstrapConstants {
    static var maxTransferUnit : Int {
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            let modelName = UIDevice.modelName
            if modelName == "iPhone 6s Plus" || modelName == "iPhone 6s" || modelName == "iPhone 6 Plus" || modelName == "iPhone 6" || modelName == "iPhone 5s" || modelName == "iPhone 5c" || modelName == "iPhone 5" || modelName == "iPhone 4s" || modelName == "iPhone 4" {
                return 158
            }
            return 240
        }
        else{
            return 240
        }
    }
    //static let maxTransferUnit = 240 //158 for older than iPhone7
    static let maxRxPacketCount = 5
    static let imageHeaderLength = 24
    static let bootAgentLength = 1024 * 12
    static let imageHeaderReservedLength = 1024 * 4 * 2 - imageHeaderLength
}

class NetstrapPacket {
    
    /*
    public static let PDU_TYPE_CMD_SCAN_REQ = 0x0000
    public static let PDU_TYPE_CMD_CONNECT_REQ = 0x0001
    public static let PDU_TYPE_CMD_READ_DEVICE_INFO_REQ = 0x0004
    public static let PDU_TYPE_CMD_WRITE_DEVICE_INFO_REQ = 0x0005
    public static let PDU_TYPE_CMD_BLEWIFI_REQ_WIFI_STATUS = 0x0006
    public static let PDU_TYPE_CMD_OTA_VERSION_REQ = 0x0100
    public static let PDU_TYPE_CMD_OTA_UPGRADE_REQ = 0x0101
    public static let PDU_TYPE_CMD_OTA_RAW_DATA_REQ = 0x0102
    public static let PDU_TYPE_CMD_OTA_END_REQ = 0x0103
    public static let PDU_TYPE_EVT_SCAN_RSP = 0x1000
    public static let PDU_TYPE_EVT_SCAN_END = 0x1001
    public static let PDU_TYPE_EVT_CONNECT_RSP = 0x1002
    public static let PDU_TYPE_EVT_READ_DEVICE_INFO_RSP = 0x1005
    public static let PDU_TYPE_EVT_WRITE_DEVICE_INFO_RSP = 0x1006
    public static let PDU_TYPE_BLEWIFI_RSP_WIFI_STATUS = 0x1007
    public static let PDU_TYPE_EVT_OTA_VERSION_RSP = 0x1100
    public static let PDU_TYPE_EVT_OTA_UPGRADE_RSP = 0x1101
    public static let PDU_TYPE_EVT_OTA_RAW_DATA_RSP = 0x1102
    public static let PDU_TYPE_EVT_OTA_END_RSP = 0x1103
    public static let PDU_TYPE_VBATT_CAL = 0x0401
    public static let PDU_TYPE_IO_VOL_CAL = 0x0402
    public static let PDU_TYPE_TEMP_CAL = 0x0403
    public static let PDU_TYPE_SET_DEVICE_MODE = 0x0404
    public static let PDU_TYPE_READ_DEVICE_MODE = 0x0405
    public static let PDU_TYPE_VBATT_CAL_RSP = 0x1401
    public static let PDU_TYPE_IO_VOL_CAL_RSP = 0x1402
    public static let PDU_TYPE_TEMP_CAL_RSP = 0x1403
    public static let PDU_TYPE_SET_DEVICE_MODE_RSP = 0x1404
    public static let PDU_TYPE_READ_DEVICE_MODE_RSP = 0x1405
    public static let PDU_TYPE_RESET_REQ = 0x0601
    public static let PDU_TYPE_WRITE_WIFI_MAC_REQ = 0x0602
    public static let PDU_TYPE_READ_WIFI_MAC_REQ = 0x0603
    public static let PDU_TYPE_WRITE_BLE_MAC_REQ = 0x0604
    public static let PDU_TYPE_READ_BLE_MAC_REQ = 0x0605
    public static let PDU_TYPE_SEND_BLE_STR_REQ = 0x0606
    public static let PDU_TYPE_SEND_SINGLE_TONE_REQ = 0x0607
    public static let PDU_TYPE_RESET_RSP = 0x1601
    public static let PDU_TYPE_WRITE_WIFI_MAC_RSP = 0x1602
    public static let PDU_TYPE_READ_WIFI_MAC_RSP = 0x1603
    public static let PDU_TYPE_WRITE_BLE_MAC_RSP = 0x1604
    public static let PDU_TYPE_READ_BLE_MAC_RSP = 0x1605
    public static let PDU_TYPE_SEND_BLE_STR_RSP = 0x1606
    public static let PDU_TYPE_SEND_SINGLE_TONE_RSP = 0x1607
    public static let SCAN_TYPE_ACTIVE = 0
    public static let SCAN_TYPE_PASSIVE = 1
    public static let SCAN_TYPE_MIX = 2
    public static let AUTH_MODE_OPEN = 0
    public static let AUTH_MODE_WEP = 1
    public static let AUTH_MODE_WPA_PSK = 2
    public static let AUTH_MODE_WPA2_PSK = 3
    public static let AUTH_MODE_WPA_WPA2_PSK = 4
    public static let AUTH_MODE_WPA2_ENTERPRISE_PSK = 5
    public static let CONNECT_STATUS_SUCCESS = 0
    */
    
    
    class func getCmdId(packageType:NetstrapPacketType, bytesOrder:BytesOrderType? = .littleEndian ) -> [UInt8] {

        let newCmdIdString = NetstrapPacket.convertCmdIdTo2bytesString(string: packageType.rawValue)
        let cmdIdBytes: [UInt8] = HexConverter.hexStringArrayToBytesArray(hexString: newCmdIdString)
        return (bytesOrder == BytesOrderType.littleEndian) ? cmdIdBytes.reversed() : cmdIdBytes
    }
    
    class func checkCmdType(hexString:String) -> NetstrapPacketType {
        
        for type in NetstrapPacketType.allValues {
            if (hexString == type) {
                return NetstrapPacketType(rawValue: type)!
            }
        }
        return NetstrapPacketType.UNKNOWN_TYPE
    }
    
    class func convertCmdIdTo2bytesString(string:String) -> String {
        let cmdIdString = string.replacingOccurrences(of: "0x", with: "")
        var newCmdIdString = ""
        for (idx,c) in cmdIdString.enumerated() {
            newCmdIdString.append(c)
            if (idx == 1) {
                newCmdIdString.append(",")
            }
        }
        return newCmdIdString
    }

    
    
    /*
    func cmdIdHexToBytesArray(packetType:NetstrapPacketType) -> [UInt8] {
        
        let rawValue = packetType.rawValue
        let data = Data([rawValue])
        let hexString = data.hexEncodedString()
        var newHexString = ""
        for (idx,c) in hexString.enumerated() {
            newHexString.append(c)
            if (idx == 2) {
                newHexString.append(",")
            }
        }
        let bytes = HexConverter.hexStringArrayToBytesArray(hexString: newHexString)
        return bytes.reversed()
    }
    */

    
    
}
