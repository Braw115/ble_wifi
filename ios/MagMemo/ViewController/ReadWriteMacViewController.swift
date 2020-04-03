//
//  ReadWriteMacViewController.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/2.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreBluetooth

class ReadWriteMacViewController: OBWViewController {
    
    @IBOutlet var buttonsCollection: [UIButton]!
    
    @IBOutlet weak var writeWifiMacTextField: UITextField!
    @IBOutlet weak var writeBleMacTextField: UITextField!
    @IBOutlet weak var readBleMacTextField: UITextField!
    @IBOutlet weak var readWifiMacTextField: UITextField!
    @IBOutlet weak var logTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "OPL1000"
        self.logTextView.text = LogService.shared.getLog()
        
        for button in buttonsCollection {
            button.layer.cornerRadius = 5
        }
    }
    
    func updateLogMsg() {
        self.logTextView.text = LogService.shared.getLog()
    }
    
    
    func validateWritingMac(mac:String) -> Bool {
        
        let newMac = mac.replacingOccurrences(of: ":", with: "")
        if (newMac == "") {
            showAlertWith(msg: "Please type the new MAC address!")
            return false
        }
        
        if (newMac.count > 12) {
            showAlertWith(msg: "Please type with the correct MAC address!")
            return false
        }
        
        return true
    }
    
    func correctMacAddressFormat(macString:String) -> String {
        var macAddress = ""
        if (macString.contains(":")) {
            macAddress = macString.replacingOccurrences(of: ":", with: "")
        }
        
        var i = 1
        for c in macString {
            macAddress.append(c)
            if (i == 2) {
                macAddress.append(":")
                i = 0
            }
            i = i+1
        }
        macAddress.remove(at: macAddress.index(before: macAddress.endIndex))
        return macAddress
    }
    
    @IBAction func readWiFiMac(_ sender: Any) {
        NetstrapService.readWiFiMAC()
    }
    
    @IBAction func writeWiFiMac(_ sender: Any) {
        let macAddress = writeWifiMacTextField.text!
        if (validateWritingMac(mac: macAddress)) {
            self.view.endEditing(true)
            NetstrapService.writeWiFiMAC(mac:macAddress)
        }
    }
    
    @IBAction func readBLEMac(_ sender: Any) {
        NetstrapService.readBLEMAC()
    }
    
    @IBAction func writeBLEMac(_ sender: Any) {
        let macAddress = writeBleMacTextField.text!
        if (validateWritingMac(mac: macAddress)) {
            self.view.endEditing(true)
            NetstrapService.writeBLEMAC(mac:macAddress)
        }
    }
    
    @IBAction func resetAll(_ sender: Any) {
        NetstrapService.resetDevice()
    }
    
    func didReceivedReadBLEMacRsp(bytes:[UInt8]) {
        print("READ BLE MAC RESPONSE")
        print("bytes:\(bytes)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [READ_BLE_MAC_RSP]")
        
        //0516 0600 112233449986
        let successInt = HexConverter.byteToInt(byte: bytes[2])
        if successInt == 6 {
            print("READ BLE MAC SUCCESS")
            showSuccessHud(msg: "READ BLE MAC SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** READ BLE MAC SUCCESS")
            
            let macAddressBytes = Array(bytes[4...bytes.count-1])
            let macAddress = HexConverter.bytesArrayToStringWithSemicolon(bytes: macAddressBytes)
            readBleMacTextField.text = macAddress
            LogService.shared.add(log: "BLE MAC \(macAddress)")
        }
        else{
            print("READ BLE MAC FAILED")
            showErrorHud(msg: "READ BLE MAC FAILED")
            LogService.shared.addLogWithNewLine(log: "*** READ BLE MAC FAILED")
        }
        
        updateLogMsg()
    }
    
    func didReceivedWriteBLEMacRsp(bytes:[UInt8]) {
        print("WRITE BLE MAC RESPONSE")
        print("bytes:\(bytes)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [WRITE_BLE_MAC_RSP]")
        
        let successInt = HexConverter.byteToInt(byte: bytes[4])
        if successInt == 0 {
            print("WRITE BLE MAC SUCCESS")
            showSuccessHud(msg: "WRITE BLE MAC SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** WRITE BLE MAC SUCCESS")
            
            if let macAddress = writeBleMacTextField.text {
                let correctMac = correctMacAddressFormat(macString: macAddress)
                writeBleMacTextField.text = correctMac
                LogService.shared.add(log: "NEW BLE MAC \(correctMac)")
            }
            
        }
        else{
            print("WRITE BLE MAC FAILED.")
            showErrorHud(msg: "WRITE BLE MAC FAILED")
            LogService.shared.addLogWithNewLine(log: "*** WRITE BLE MAC FAILED")
        }
        
        updateLogMsg()
    }
    
    func didReceivedReadWiFiMacRsp(bytes:[UInt8]) {
        print("READ WIFI MAC RESPONSE")
        print("bytes:\(bytes)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [READ_WIFI_MAC_RSP]")
        
        //0316 0600 22334455 6686
        let successInt = HexConverter.byteToInt(byte: bytes[2])
        if successInt == 6 {
            print("READ WIFI MAC SUCCESS")
            showSuccessHud(msg: "READ WIFI MAC SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** READ BLE MAC SUCCESS")
            
            let macAddressBytes = Array(bytes[4...bytes.count-1])
            let macAddress = HexConverter.bytesArrayToStringWithSemicolon(bytes: macAddressBytes)
            readWifiMacTextField.text = macAddress
            LogService.shared.add(log: "WiFi MAC \(macAddress)")
        }
        else{
            print("READ WIFI MAC FAILED")
            showErrorHud(msg: "READ WIFI MAC FAILED")
            LogService.shared.addLogWithNewLine(log: "*** READ WIFI MAC FAILED")
        }
        
        updateLogMsg()
    }
    
    func didReceivedWriteWiFiMacRsp(bytes:[UInt8]) {
        print("WRITE WIFI MAC RESPONSE")
        print("bytes:\(bytes)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [WRITE_WIFI_MAC_RSP]")
        
        //0216 0100 00
        let successInt = HexConverter.byteToInt(byte: bytes[4])
        if successInt == 0 {
            print("WRITE WIFI MAC SUCCESS")
            showSuccessHud(msg: "WRITE WIFI MAC SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** WRITE WIFI MAC SUCCESS")
            
            if let macAddress = writeWifiMacTextField.text {
                let correctMac = correctMacAddressFormat(macString: macAddress)
                writeWifiMacTextField.text = correctMac
                LogService.shared.add(log: "NEW WIFI MAC \(correctMac)")
            }
        }
        else{
            print("WRITE WIFI MAC FAILED")
            showErrorHud(msg: "WRITE WIFI MAC FAILED")
            LogService.shared.addLogWithNewLine(log: "*** WRITE WIFI MAC FAILED")
        }
        
        updateLogMsg()
    }
    
    func didReceivedResetDeviceRsp(bytes:[UInt8]) {
        print("RESET DEVICE RESPONSE")
        print("bytes:\(bytes)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [RESET_DEVICE_RSP]")
        
        //0116 0100 00
        let successInt = HexConverter.byteToInt(byte: bytes[4])
        if successInt == 0 {
            print("RESET DEVICE SUCCESS.")
            showSuccessHud(msg: "RESET DEVICE SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** RESET DEVICE SUCCESS")
            
            readBleMacTextField.text = ""
            readWifiMacTextField.text = ""
            writeBleMacTextField.text = ""
            writeWifiMacTextField.text = ""
        }
        else{
            print("RESET DEVICE FAILED.")
            showErrorHud(msg: "RESET DEVICE FAILED")
            LogService.shared.addLogWithNewLine(log: "*** RESET DEVICE FAILED")
        }
        
        updateLogMsg()
    }
    
    
    /*
    func didReceivedReadDeviceInfoRsp(bytes:[UInt8]) {
        print("READ DEVICE INFORMATION RESPONSE")
        
        if (bytes.count < 11) {
            return
        }
        
        let macAddressByteArray = Array(bytes[4...9])
        let macAddress = HexConverter.bytesArrayToStringWithSemicolon(bytes:macAddressByteArray)
        print("macAddress:\(macAddress)")
        //macAddress:00:79:82:34:67:54
        self.readBleMacTextField.text = macAddress
        
        
        let manufactureNameLengthByte = bytes[10]
        let manufactureNameLength = HexConverter.byteToInt(byte: bytes[10])
        print("manufactureNameLength:\(manufactureNameLength)")
        
        let manufactureNameBytes = Array(bytes[11...bytes.count-1])
        let manufactureName = HexConverter.bytesArrayToString(bytes: manufactureNameBytes)
        print("manufactureName:\(manufactureName)")
        
        LogService.shared.addLogWithNewLine(log: "*** BLE MAC Address \(macAddress)")
        self.logTextView.text = LogService.shared.getLog()
        
    }
    
    func didReceivedWriteDeviceInfoRsp(bytes:[UInt8]) {
        print("WRITE DEVICE INFORMATION RESPONSE")
        
        if (bytes.count == 5) {
            let successInt = HexConverter.byteToInt(byte: bytes.last!)
            if successInt == 0 {
                print("Write BLE Info Success")
                //NetstrapService.readBLEDeviceInfo()
            }
            else{
                print("Write BLE Info Failed.")
            }
        }
    }
    */

}

// MARK: BluetoothManagerDelegate
extension ReadWriteMacViewController  {
    
    func serviceDidTimeout() {
        print("serviceDidTimeout")
        showErrorHud(msg: "Time Out!")
    }
    
    
    func didUpdateValueFor(characteristic:CBCharacteristic) {
        
        let data = characteristic.value
        if (data != nil) {
            let byteArray = [UInt8](data!)
            //print("Receive value byteArray:",byteArray)
            
            let receiveType = NetstrapService.checkReceivePacketType(data: data!)
            switch receiveType {
            case .EVT_READ_BLE_MAC_RSP:
                didReceivedReadBLEMacRsp(bytes:byteArray)
            case .EVT_WRITE_BLE_MAC_RSP:
                didReceivedWriteBLEMacRsp(bytes:byteArray)
            case .EVT_READ_WIFI_MAC_RSP:
                didReceivedReadWiFiMacRsp(bytes:byteArray)
            case .EVT_WRITE_WIFI_MAC_RSP:
                didReceivedWriteWiFiMacRsp(bytes:byteArray)
            case .EVT_RESET_DEVICE_RSP:
                didReceivedResetDeviceRsp(bytes:byteArray)
            default:
                print("Receive package type:\(receiveType) not belong here.")
            }
        }
    }
}
