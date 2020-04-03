//
//  ReadMacViewController.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/24.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreBluetooth

class ReadMacViewController: OBWViewController {
    
    @IBOutlet var buttonsCollection: [UIButton]!
    
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
    
    @IBAction func readWiFiMac(_ sender: Any) {
        NetstrapService.readWiFiMAC()
    }
    
    @IBAction func readBLEMac(_ sender: Any) {
        NetstrapService.readBLEMAC()
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

}

// MARK: BluetoothManagerDelegate
extension ReadMacViewController  {
    
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
            case .EVT_READ_WIFI_MAC_RSP:
                didReceivedReadWiFiMacRsp(bytes:byteArray)
            default:
                print("Receive package type:\(receiveType) not belong here.")
            }
        }
    }
}
