//
//  SendCmdViewController.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/2.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import CoreBluetooth
import SVProgressHUD

class SendCmdViewController: OBWViewController {
    
    @IBOutlet var buttonsCollection: [UIButton]!
    @IBOutlet weak var readModeTextField: UITextField!
    @IBOutlet weak var singleToneModeTextField: UITextField!
    @IBOutlet weak var singleToneFreqTextField: UITextField!
    @IBOutlet weak var sendStrTextField: UITextField!
    @IBOutlet weak var logTextView: UITextView!
    
    
    var setUserMode = false
    
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
    
    
    @IBAction func initMode(_ sender: Any) {
        setUserMode = false
        
        SVProgressHUD.show()
        NetstrapService.setInitMode()
    }
    
    @IBAction func userMode(_ sender: Any) {
        setUserMode = true
        
        SVProgressHUD.show()
        NetstrapService.setUserMode()
    }
    
    @IBAction func readMode(_ sender: Any) {
        SVProgressHUD.show()
        NetstrapService.readDeviceMode()
    }
    
    
    @IBAction func sendSingleTone(_ sender: Any) {
        
        if (singleToneModeTextField.text == "" || singleToneFreqTextField.text == "") {
            showInfoHud(msg: "Set the Mode and Frequency first!")
            return
        }
        
        if (singleToneModeTextField.text != "1" && singleToneModeTextField.text != "3") {
            showAlertWith(msg: "Only support to 1 or 3 Mode")
            return
        }
        
        
        if (singleToneModeTextField.text == "1") {
            //Frequency : 2397 – 2484 (LE, WiFi)
            let modeInt = Int(singleToneFreqTextField.text!) ?? -1
            if (modeInt == -1 || modeInt > 2484 || modeInt < 2397) {
                showAlertWith(msg: "Only support Freq: 2397 – 2484 (LE, WiFi)")
                return
            }
            
        }
        else if (singleToneModeTextField.text == "3") {
            //Frequency : 1 – 14 (WiFi Channel)
            let modeInt = Int(singleToneFreqTextField.text!) ?? -1
            if (modeInt == -1 || modeInt > 14 || modeInt < 1) {
                showAlertWith(msg: "Only support Freq: 1 – 14 (WiFi Channel)")
                return
            }
        }
        
        self.view.endEditing(true)
        SVProgressHUD.show()
        NetstrapService.sendSingleTone(mode: singleToneModeTextField.text!, freq: singleToneFreqTextField.text!)
    }
    
    
    @IBAction func sendStrCmd(_ sender: Any) {
        if (sendStrTextField.text == "") {
            showInfoHud(msg: "Set the string first!")
            return
        }
        self.view.endEditing(true)
        SVProgressHUD.show()
        NetstrapService.sendBLEString(str:sendStrTextField.text!)
    }
    
    func didReceivedSetDeviceModeRsp(bytes:[UInt8]) {
        if (setUserMode) {
            setUserMode = false
            didReceivedSetUserModeRsp(bytes: bytes)
        }
        else{
            didReceivedSetInitModeRsp(bytes: bytes)
        }
    }
    
    func didReceivedSetInitModeRsp(bytes:[UInt8]) {
        print("SET DEVICE INIT MODE RESPONSE")
        print("bytes:\(bytes)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "[SET_DEVICE_INIT_MODE_RSP]")
        
        let successInt = HexConverter.byteToInt(byte: bytes[4])
        if successInt == 0 {
            print("SET INIT MODE SUCCESS.")
            showSuccessHud(msg: "SET INIT MODE SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** SET INIT MODE SUCCESS")
        }
        else{
            print("SET INIT MODE FAILED.")
            showErrorHud(msg: "SET INIT MODE FAILED")
            LogService.shared.addLogWithNewLine(log: "*** SET INIT MODE FAILED")
        }
        
        updateLogMsg()
    }
    
    func didReceivedSetUserModeRsp(bytes:[UInt8]) {
        print("SET DEVICE USER MODE RESPONSE")
        print("bytes:\(bytes)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "[SET_DEVICE_USER_MODE_RSP]")
        
        if (bytes.count == 5) {
            let successInt = HexConverter.byteToInt(byte: bytes[4])
            if successInt == 0 {
                print("SET USER MODE SUCCESS.")
                showSuccessHud(msg: "SET USER MODE SUCCESS")
                LogService.shared.addLogWithNewLine(log: "*** SET USER MODE SUCCESS")
            }
            else{
                print("SET USER MODE FAILED.")
                showErrorHud(msg: "SET USER MODE FAILED")
                LogService.shared.addLogWithNewLine(log: "*** SET USER MODE FAILED")
            }
        }
        
        updateLogMsg()
    }
    
    func didReceivedReadDeviceModeRsp(bytes:[UInt8]) {
        print("READ DEVICE MODE RESPONSE")
        print("bytes:\(bytes)")
        
        //0514 0100 05
        
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "[READ_DEVICE_MODE_RSP]")
        
        if (bytes.count == 5) {
            
            print("READ DEVICE MODE SUCCESS.")
            showSuccessHud(msg: "READ DEVICE MODE SUCCESS")
            LogService.shared.add(log: "*** READ DEVICE MODE SUCCESS")
            
            let mode = HexConverter.byteToInt(byte: bytes[4])
            print("mode:\(mode)")
            LogService.shared.addLogWithNewLine(log: "mode:\(mode)")
            if (mode == 0) {
                readModeTextField.text = "INIT MODE"
            }
            else if (mode == 2) {
                readModeTextField.text = "USER MODE"
            }
        }
        else{
            print("不是正確的RSP")
            print("READ DEVICE MODE FAILED.")
            showErrorHud(msg: "READ DEVICE MODE FAILED")
            LogService.shared.addLogWithNewLine(log: "*** READ DEVICE MODE FAILED")
        }
        
        updateLogMsg()
    }
    
    func didReceivedSendSingleToneRsp(bytes:[UInt8]) {
        print("SEND SINGLE TONE RESPONSE")
        print("bytes:\(bytes)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "[SEND_SINGLE_TONE_RSP]")
        
        if (bytes.count < 5) {
            print("不是正確的RSP")
            return
        }
        
        let successInt = HexConverter.byteToInt(byte: bytes[4])
        if successInt == 0 {
            print("SET SINGLE TONE SUCCESS.")
            showSuccessHud(msg: "SET SINGLE TONE SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** SET SINGLE TONE SUCCESS")
        }
        else{
            print("SET SINGLE TONE FAILED")
            showErrorHud(msg: "SET SINGLE TONE FAILED")
            LogService.shared.addLogWithNewLine(log: "*** SET SINGLE TONE FAILED")
        }
        
        updateLogMsg()
    }
    
    func didReceivedSendBLEStrRsp(bytes:[UInt8]) {
        print("SEND BLE STR RESPONSE")
        print("bytes:\(bytes)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "[SEND_BLE_STR_RSP]")
        
        //0616 0100 00
        if (bytes.count < 5) {
            print("不是正確的RSP")
            return
        }
        
        let successInt = HexConverter.byteToInt(byte: bytes[4])
        if successInt == 0 {
            print("SEND BLE STR SUCCESS.")
            showSuccessHud(msg: "SEND BLE STR SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** SEND BLE STR SUCCESS")
        }
        else{
            print("SEND BLE STR FAILED.")
            showErrorHud(msg: "SEND BLE STR FAILED")
            LogService.shared.addLogWithNewLine(log: "*** SEND BLE STR FAILED")
        }
        
        updateLogMsg()
    }
    
    

}

// MARK: BluetoothManagerDelegate
extension SendCmdViewController {
    
    func didFailToDiscoverServices(error: Error?) {
        
    }
    
    func didFailToDiscoverCharacteritics(error: Error?) {
        
    }
    
    func didFailToWriteValueFor(characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func serviceDidTimeout() {
        print("serviceDidTimeout")
        if (setUserMode) {
            setUserMode = false
        }
        
        showErrorHud(msg: "Time Out!")
    }
    
    func didUpdateValueFor(characteristic:CBCharacteristic) {
        
        let data = characteristic.value
        if (data != nil) {
            let byteArray = [UInt8](data!)
            print("Receive value byteArray:",byteArray)
            
            let receiveType = NetstrapService.checkReceivePacketType(data: data!)
            switch receiveType {
            case .EVT_SET_DEVICE_MODE_RSP:
                didReceivedSetDeviceModeRsp(bytes:byteArray)
            case .EVT_READ_DEVICE_MODE_RSP:
                didReceivedReadDeviceModeRsp(bytes:byteArray)
            case .EVT_SEND_SINGLE_TONE_RSP:
                didReceivedSendSingleToneRsp(bytes:byteArray)
            case .EVT_END_BLE_STR_RSP:
                didReceivedSendBLEStrRsp(bytes:byteArray)
            default:
                print("Receive package type:\(receiveType) not belong here.")
            }
            
        }
    }
}
