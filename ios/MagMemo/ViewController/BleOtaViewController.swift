//
//  BleOtaViewController.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/2.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreBluetooth
import SVProgressHUD

class BleOtaViewController: OBWViewController {
    
    @IBOutlet weak var otaButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var saveDataToLocal = false
    var upgradeOTAData: Data?
    var sentRawDataRowIndex = 0
    let maxTransferUnit = NetstrapConstants.maxTransferUnit
    let maxRxPacketCount = NetstrapConstants.maxRxPacketCount
    var otaStartIndex = 0
    var sendOtaStart = false
    var sendOtaPause = false
    var sendOtaEnd = false
    var sendOtaRoopCount = 0
    var otaStartTime:TimeInterval = 0
    var sendOtaReqCount = 0
    var receiveOTARspCount = 0
    var receivedOTAEndCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        otaButton.layer.cornerRadius = 5
        
        self.title = "OPL1000 BLE OTA"
        self.textView.text = LogService.shared.getLog()

        NetstrapService.readOTAVersion()
    }
    
    func updateLogMsg() {
        self.textView.text = LogService.shared.getLog()
        self.textView.scrollToBotom()
    }
    
    func checkAndCreateDirecotry() -> Bool{
        let otaPath = NSTemporaryDirectory() + "/OTA"
        var isDirectory:ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: otaPath, isDirectory: &isDirectory)
        if isExist == true && isDirectory.boolValue == true{
            print("File is:\(otaPath)")
            print("File exist and it is a direcotry")
            return true
        }
        else if isExist == true && isDirectory.boolValue == false{
            print("File exist but it is not a direcotry")
            return false
        }
        else{
            print("File isn't exist")
            do{
                try FileManager.default.createDirectory(atPath: otaPath, withIntermediateDirectories: true, attributes: nil)
                return true
            }catch{
                print("Cannot create OTA directory")
                return false
            }
        }
    }
    
    func saveDataToLocalDir(data:Data) {
        
        guard checkAndCreateDirecotry() else {
            print("Direcotory not exist.")
            return
        }
        
        let filePath = NSTemporaryDirectory() + "/OTA/OTA.bin"
        let fileURL = URL(fileURLWithPath: filePath)
        // 寫入
        do{
            try data.write(to: fileURL)
            print("Save file to local success.")
        }catch{
            print("Can not save file to local.")
        }
    }
    

    @IBAction func chooseFile(_ sender: Any) {
        
        if (sendOtaStart) {
            return
        }

        //let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet, kUTTypeData]
        let types = [kUTTypeText, kUTTypeData]
        let importMenu = UIDocumentPickerViewController(documentTypes: types as [String], in: .import)
        
        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = true
        }
        
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        
        present(importMenu, animated: true)
 
    }


    func getFWHeaderBytesFromData(data:Data) -> [UInt8] {
        
        //7341 544f e803 0100 c70c 0100 24f6 0200
        //let path = Bundle.main.path(forResource: "CBS_3268_patch_ota", ofType:"bin")
        //if let stream:InputStream = InputStream(fileAtPath: path!) {

        var allBuf:[UInt8] = [UInt8]()
        var headerBuf:[UInt8] = [UInt8]()
        let checkFF:[UInt8] = [0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff]
        var gotFF = false
        var headerAtIdx = 0
        
        var buf:[UInt8] = [UInt8](repeating: 0, count: 16)
        let stream:InputStream =  InputStream(data: data)
        stream.open()
        while true {
            let len = stream.read(&buf, maxLength: buf.count)
            
            if (headerBuf.count == 16) {
                headerBuf.append(contentsOf: buf)
                print("加了第二排headerBuf:\(headerBuf)")
                break
            }
            
            if (buf == checkFF) {
                //print("idx:\(headerAtIdx)有很多ffff")
                gotFF = true
            }
            else{
                if (gotFF) {
                    gotFF = false
                    //print("沒有ffff")
                    print("第\(headerAtIdx) 是Header")
                    headerBuf.append(contentsOf: buf)
                    print("第一排headerBuf:\(headerBuf)")
                }
            }
            
            allBuf.append(contentsOf: buf)
            headerAtIdx += 1
            /*
            for i in 0..<len {
                print(String(format:"%02x", buf[i]), terminator: " ")
            }
            */
            if len < buf.count {
                break
            }
        }
        stream.close()
        
        //print("allBuf.count:\(allBuf.count)")
        return headerBuf
    }
    
    
    func sendOTAUpgradeRequest(data:Data) {
        
        let headerBeginIndex = NetstrapConstants.bootAgentLength
        let headerEndIndex = NetstrapConstants.bootAgentLength + NetstrapConstants.imageHeaderLength - 1
        let fwHeaderBytes = HexConverter.bytesDataToBytesArray(data: data[headerBeginIndex...headerEndIndex])
        print("fwHeaderBytes:\(fwHeaderBytes)")
        
        /*
        let fwHeaderExample:[UInt8] = [0x73,0x41,0x54,0x4F,0xE8,0x03,0x01,0x00,0xC7,0x0C,0x01,0x00,
                                       0x24,0xF6,0x02,0x00,0x33,0xBD,0x00,0x01,0x24,0x05,0x00,0x00]
        if fwHeaderExample == fwHeaderBytes {
            print("兩者Header一樣")
        }
        
        let header = HexConverter.bytesDataToBytesArray(data: data[headerBeginIndex...headerEndIndex])
        let projectId = (header[4] & 0xFF) | ((header[5] & 0xFF) << 8)
        let chipId = (header[6] & 0xFF) | ((header[7] & 0xFF) << 8)
        let fwId = (header[8] & 0xFF) | ((header[9] & 0xFF) << 8)
        let imageSize1 = (header[12] & 0xFF) | ((header[13] & 0xFF) << 8) | ((header[14] & 0xFF) << 16)
        let imageSize = imageSize1 | ((header[15] & 0xFF) << 24)
        let checksum1 = (header[16] & 0xFF) | ((header[17] & 0xFF) << 8) | ((header[18] & 0xFF) << 16)
        let checksum = checksum1 | ((header[19] & 0xFF) << 24)
        print("projectId:\(projectId)") //1000
        print("chipId:\(chipId)") //1
        print("fwId:\(fwId)") //3271
        print("imageSize:\(imageSize)") //194084
        print("checksum:\(checksum)") //16825651
        */
        
        
        // TODO: 用Header組出ImageSize來檢查要送出的RawData sizes
        if fwHeaderBytes.count == 24 {
            print("原本Data有 \(data.count) bytes")
            
            let skipLength = NetstrapConstants.bootAgentLength + NetstrapConstants.imageHeaderLength  + NetstrapConstants.imageHeaderReservedLength
            let afterSkipBytes = data[skipLength...data.count-1]
            upgradeOTAData = afterSkipBytes
            //let test = afterSkipBytes.filter({$0 != 0xff})
            //print("Skip後的Data有\(afterSkipBytes.count) bytes")
            //let bytesArray = HexConverter.bytesDataToBytesArray(data: upgradeOTAData!)
            //print("content前十個:",bytesArray[0...9])
            print("最後要傳送的Data有\(upgradeOTAData!.count) bytes")
            print("需傳送\(upgradeOTAData!.count/maxTransferUnit + 1)次Request")
            NetstrapService.requestOTAUpgrade(fwHearderBytes:fwHeaderBytes)
        }
        else{
            SVProgressHUD.showError(withStatus: "OTA image not correct!")
        }
    }
    
    func sendOTARawDataRequest() {
        BluetoothManager.sharedInstance().otaCountingEnable = true
        
        //var otaStartIndex = 0
        //var sendOtaStart = false
        //var sendOtaPause = false
        //var sendOtaEnd = false
        //var sendOtaRoopCount = 0
        
        sendOtaReqCount += 1
        //print("第\(sendOtaReqCount) 次 OTA Raw Data Request")
        //LogService.shared.addLogWithNewLine(log: "第\(sendOtaReqCount) 次 OTA Raw Data Request")

        if (otaStartIndex < upgradeOTAData!.count) {
            
            var len = maxTransferUnit
            if (otaStartIndex + len >= upgradeOTAData!.count) {
                len = upgradeOTAData!.count - otaStartIndex
                sendOtaEnd = true
            }
            
            let dataBytesArray = HexConverter.bytesDataToBytesArray(data: upgradeOTAData!)
            let sendDataBytes = Array(dataBytesArray[otaStartIndex...(otaStartIndex+len-1)])
            NetstrapService.requestOTARawData(rawData: sendDataBytes, dataLength: len)
            LogService.shared.addLogNoNewLine(log: "#")
            
            //let hexString = HexConverter.bytesArrayToStringWithSpace(bytes: sendDataBytes)
            //print("sendDataBytes:\(hexString)")
            //LogService.shared.addLogWithNewLine(log: "\(hexString)")
            
            //print("sendDataBytes:\(sendDataBytes)")
            //print("sendDataBytes.count:\(sendDataBytes.count)")
            //LogService.shared.addLogWithNewLine(log: "\(sendDataBytes[0...19])")
            
            print("Sending 第\(otaStartIndex + 1) - \(otaStartIndex+len-1 + 1) 個Bytes")
            otaStartIndex += len
            
            
            sendOtaRoopCount += 1
            
            if (sendOtaRoopCount == maxRxPacketCount) {
                sendOtaPause = true
            }
            
            if (sendOtaEnd) {
                BluetoothManager.sharedInstance().otaCountingEnable = false
                
                sendOtaStart = false
                sendOtaPause = true
                sendOtaEnd = true
                
                //print("最後一次的sendDataBytes.count:\(sendDataBytes.count)")
                print("REQUEST OTA END")
                
                delay(1) {
                    NetstrapService.requestOTAEnd()
                }

            }
            
            updateLogMsg()
            
        }
        
    }
    
    // MARK: OTA RESPONSE
    func didReceivedOtaVersionRsp(bytes:[UInt8]) {
        print("READ OTA VERSION RESPONSE")
        print("bytes:\(bytes)")
        //0011 0700 00 0100 0100 0300
        
        if (bytes.count < 11) {
            print("不是正確的OTA VERSION RSP")
            return
        }
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [OTA_VERSION_RSP]")
        
        //0011 0700(datalength) 00(status) e803(projectId) 0100(chipId) c70c(fwId)
        let successInt = HexConverter.byteToInt(byte: bytes[4])
        if successInt == 0 {
            
            print("READ OTA VERSION SUCCESS.")
            LogService.shared.addLogWithNewLine(log: "*** READ OTA VERSION SUCCESS.")
            
            let projectIDBytes = Array(bytes[5...6])
            let projectIDStr = HexConverter.bytesArrayToString(bytes: projectIDBytes.reversed())
            print("projectId:\(projectIDStr)")
            LogService.shared.add(log: "projectId:\(projectIDStr)")
            
            let chipIDBytes = Array(bytes[7...8])
            let chipIDStr = HexConverter.bytesArrayToString(bytes: chipIDBytes.reversed())
            print("chipId:\(chipIDStr)")
            LogService.shared.add(log: "chipId:\(chipIDStr)")
            
            let fwIDBytes = Array(bytes[9...10])
            let fwIDStr = HexConverter.bytesArrayToString(bytes: fwIDBytes.reversed())
            print("fwId:\(fwIDStr)")
            LogService.shared.addLogWithNewLine(log: "fwId:\(fwIDStr)")
        }
        else {
            LogService.shared.addLogWithNewLine(log: "*** READ OTA FW VERSION FAILED.")
        }
        
        updateLogMsg()
    }
    
    func didReceivedOtaUpgradeRsp(bytes:[UInt8]) {
        print("OTA UPGRADE RESPONSE")
        
        if (bytes.count < 5) {
            print("不是正確的OTA UPGRADE RSP")
            return
        }
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [OTA_UPGRADE_RSP]")
        
        //0111 0100 00
        let successInt = HexConverter.byteToInt(byte: bytes[4])
        if successInt == 0 {
            
            print("GET OTA UPGRADE RESPONSE SUCCESS")
            LogService.shared.addLogWithNewLine(log: "status:\(successInt)")
            LogService.shared.addLogWithNewLine(log: "-> [OTA_START]")
            
            sendOtaStart = true
            otaStartTime = NSDate().timeIntervalSince1970
            sendOTARawDataRequest()
        }
        else {
            LogService.shared.add(log: "*** GET OTA UPGRADE RESPONSE FAILED.")
            LogService.shared.addLogWithNewLine(log: "status:\(successInt)")
        }
        
        updateLogMsg()
    }
    
    func didReceivedOTARawDataRsp(bytes:[UInt8]) {
        print("Did Received OTA RAW DATA RESPONSE")
        //print("bytes:\(bytes)")
        //0211 0000
        

        if (sendOtaEnd) {
            print("已傳送全部")
            return
        }
        
        if (sendOtaPause) {
            sendOtaRoopCount = 0
            sendOtaPause = false
            LogService.shared.addLogNoNewLine(log: " ")
        
            
            receiveOTARspCount += 1
            print("🍭 Receive OTA Raw Data Rsp \(receiveOTARspCount) 次")
            print("")
            self.sendOTARawDataRequest()

        }
        
    }
    
    func didReceivedOTAEndRsp(bytes:[UInt8]) {
        print("OTA END RESPONSE")
        //print("bytes:\(bytes)")
        //<0311 0100 02>
        
        receivedOTAEndCount += 1
        print("Receive OTA End RSP \(receivedOTAEndCount) 次")
        
        if (bytes.count < 5) {
            print("不是正確的OTA END RSP")
            return
        }
        
        sendOtaStart = false
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [OTA_END_RSP]")
        
        //0011 0700(datalength) 00(status) e803(projectId) 0100(chipId) c70c(fwId)
        let successInt = HexConverter.byteToInt(byte: bytes[4])
        if successInt == 0 {
            
            print("OTA END RESPONSE SUCCESS")
            LogService.shared.add(log: "*** OTA END RESPONSE SUCCESS")
            LogService.shared.addLogWithNewLine(log: "reason:\(successInt)")
            
            if (sendOtaEnd) {
                let otaSpendTime = NSDate().timeIntervalSince1970 - otaStartTime
                if otaSpendTime > 0 {
                    let str = String(format: "%.2f", Float(otaSpendTime))
                    print("OTA Time: \(str) s")
                    LogService.shared.addLogWithNewLine(log: "*** OTA Time: \(str) s")
                }
            }
        }
        else {
            print("OTA END RESPONSE FAILED")
        
            /*
            BLEWIFI_OTA_SUCCESS, //=0
            BLEWIFI_OTA_ERR_NOT_ACTIVE, //=1
            BLEWIFI_OTA_ERR_HW_FAILURE, //=2
            BLEWIFI_OTA_ERR_IN_PROGRESS, //=3
            BLEWIFI_OTA_ERR_INVALID_LEN, //=4
            BLEWIFI_OTA_ERR_CHECKSUM,
            BLEWIFI_OTA_ERR_MEM_CAPACITY_EXCEED
            */
            
            if (sendOtaEnd) {
                
            }

            print("reason:\(successInt)")
            LogService.shared.add(log: "*** OTA END RESPONSE FAILED.")
            LogService.shared.add(log: "reason:\(successInt)")
            
            let otaSpendTime = NSDate().timeIntervalSince1970 - otaStartTime
            if otaSpendTime > 0 {
                let str = String(format: "%.2f", Float(otaSpendTime))
                print("OTA Time: \(str) s")
                LogService.shared.addLogWithNewLine(log: "*** OTA Time: \(str)s")
            }
        }
        
        updateLogMsg()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BleOtaViewController: UIDocumentMenuDelegate,UIDocumentPickerDelegate,UINavigationControllerDelegate {
    
    func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("import result : \(urls)")
        if (urls.count > 0) {
            SVProgressHUD.show()
            do {

                let upgradeData = try Data(contentsOf: urls.last!)
                print("upgradeData.count:\(upgradeData.count)")
                print("upgradeData:\(upgradeData)")
                
                if (self.saveDataToLocal) {
                    self.saveDataToLocalDir(data: upgradeData)
                }
                
                DispatchQueue.main.async {
                    self.showSuccessHud(msg: "Load File Success.")
                    self.sendOTAUpgradeRequest(data: upgradeData)
                }
                
                /*
                let upgradeFirmwareUrl = try String(contentsOf: urls.last!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                getUpgradeDataFromUrl(url: upgradeFirmwareUrl)
                */
                
            } catch {
                // contents could not be loaded
                print("File could not be loaded.")
                //Please choose correct OTA image.
                showErrorHud(msg: "File could not be loaded.")
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func getUpgradeDataFromUrl(url:String) {
        if url == "" {
            showErrorHud(msg: "File could not be loaded.")
            return
        }
        
        let queue = DispatchQueue(label: "GetUpgradeBinData", qos: DispatchQoS.utility)
        queue.async {
            do {
                //let upgradeBinUrl = URL(string: "https://www.dropbox.com/s/m4je1mlp8m9h13r/CBS_3268_patch_ota.bin?dl=1")
                let upgradeBinUrl = URL(string: url)
                let upgradeData = try Data(contentsOf: upgradeBinUrl!)
                print("upgradeData.count:\(upgradeData.count)")
                print("upgradeData:\(upgradeData)")
  
                if (self.saveDataToLocal) {
                    self.saveDataToLocalDir(data: upgradeData)
                }
                
                DispatchQueue.main.async {
                    self.showSuccessHud(msg: "Get Data Success.")
                    self.sendOTAUpgradeRequest(data: upgradeData)
                }
                
                
            } catch {
                print("OTA image is incorrect.")
                DispatchQueue.main.async {
                    self.showErrorHud(msg: "OTA image is incorrect.")
                }
                
            }
        }
    }
}


// MARK: BluetoothManagerDelegate
extension BleOtaViewController {
    
    func didFailToDiscoverServices(error: Error?) {
        
    }
    
    func didFailToDiscoverCharacteritics(error: Error?) {
        
    }
    
    func didFailToWriteValueFor(characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func serviceDidTimeout() {
        print("serviceDidTimeout")
        showErrorHud(msg: "Time Out!")
        
        if (sendOtaStart) {
            sendOtaStart = false
            sendOtaEnd = false
            sendOtaPause = false
        }
    }
    
    func didWriteValueFor(characteristic: CBCharacteristic) {
        
        if (sendOtaStart && !sendOtaPause) {
            sendOTARawDataRequest()
        }
    }
    
    func didUpdateValueFor(characteristic:CBCharacteristic) {
        
        let data = characteristic.value
        if (data != nil) {
            let byteArray = [UInt8](data!)
            //print("Receive value byteArray:",byteArray)
            
            let receiveType = NetstrapService.checkReceivePacketType(data: data!)
            switch receiveType {
            case .EVT_BLE_RSP_OTA_VERSION:
                didReceivedOtaVersionRsp(bytes:byteArray)
            case .EVT_BLE_RSP_OTA_UPGRADE:
                didReceivedOtaUpgradeRsp(bytes:byteArray)
            case .EVT_BLE_RSP_OTA_RAW_DATA:
                didReceivedOTARawDataRsp(bytes:byteArray)
            case .EVT_BLE_RSP_OTA_END:
                didReceivedOTAEndRsp(bytes:byteArray)
            default:
                print("Receive package type:\(receiveType) not belong here.")
                showErrorHud(msg: "Error!")
            }
            
        }
    }
}
