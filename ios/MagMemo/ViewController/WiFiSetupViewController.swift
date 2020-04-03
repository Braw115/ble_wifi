//
//  WiFiSetupViewController.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/30.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import CoreBluetooth
import SVProgressHUD
import SwiftyUserDefaults
import Alamofire

class WiFiSetupViewController: OBWViewController, WiFiCellDelegate, WiFiResetCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl:UIRefreshControl!
    
    private var characteristic_TX: CBCharacteristic?
    private var characteristic_RX: CBCharacteristic?
    
    var discoveredAP = [APModel]()
    var connectAP: APModel?
    var defaultAPName: String?
    var defaultAPPassword: String?
    var currentSelectAPIndex = -1
    var isScanning = false
    var isConnecting = false
    var didConnect = false
    var password:String?
    var wifiMac:String?
    let scanningAPFailMessage = "Scanning AP was error. Please try again!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "WiFi Setup"
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = NSLocalizedString("PullToRefresh", comment: "Pull to refresh")
            refreshControl.backgroundColor = .white
            refreshControl.tintColor = .gray
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setPasswordDone), name: .passwordTextFieldDidEndSetting , object: nil)
        
        fetchDefaults()
        
        BluetoothManager.sharedInstance().delegate = self
        if (BluetoothManager.sharedInstance().state == .poweredOn) {
            startScanWifi()
        }
        
        if (WiFiManager.sharedInstance().isConnected) {
            self.didConnect = true
            self.connectAP = WiFiManager.sharedInstance().connectAP
        }
      NetstrapService.readWiFiMAC()
    }
  
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          navigationController?.setNavigationBarHidden(false, animated: true)
//          navigationController?.navigationBar.barTintColor = .init(red: 63.0/255, green: 81.0/255, blue: 181.0/255, alpha: 1.0)
//          navigationController?.navigationBar.tintColor = .white
//          navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white,
//                                                                   .font : UIFont.init(name: "Verdana", size: 20.0)!]
      }
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        // 開始刷新動畫
        sender.beginRefreshing()
        
        SVProgressHUD.dismiss()
        self.discoveredAP.removeAll()
        self.tableView.reloadData()
        
        // 使用 UIView.animate 彈性效果，並且更改 TableView 的 ContentOffset 使其位移
        // 動畫結束之後使用 loadData()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseIn, animations: {
            //self.tableView.contentOffset = CGPoint(x: 0, y: -20)
            self.startScanWifi()
            
        }) { (finish) in
            
        }
        sender.endRefreshing()
    }
    
    func fetchDefaults() {
        if let wifiAP = Defaults[.wifiAP] {
            print("Default wifiAP:\(wifiAP)")
            defaultAPName = wifiAP
        }
        
        if let wifiPassword = Defaults[.wifiPassword] {
            print("Default wifiPassword:\(wifiPassword)")
            defaultAPPassword = wifiPassword
            password = wifiPassword
        }
    }
    
    func checkAutoConnectWifi() {
        if (didConnect) {
            print("Already connected.")
            return
        }
        
        if defaultAPName != nil && defaultAPPassword != nil {
            for (idx,ap) in discoveredAP.enumerated() {
                if ap.ssid == defaultAPName {
                    currentSelectAPIndex = idx
                    connectWiFi(auto: true)
                    print("Will Auto Connect to \(defaultAPName!)")
                    break
                }
            }
        }
    }
    
    func startScanWifi() {
        if (isScanning) {
            SVProgressHUD.dismiss()
        }
        
        if (isConnecting) {
            isConnecting = false
            
            if (!didConnect) {
                let deleteCellPath = IndexPath(item: 1, section: 0)
                if let _ = tableView.cellForRow(at: deleteCellPath) {
                    tableView.deleteRows(at: [deleteCellPath], with: .automatic)
                }
            }
        }
        
        isScanning = true
        SVProgressHUD.show()
        discoveredAP.removeAll()
        
        NetstrapService.scanWiFi()
    }
    
    func getWifiStatus() {
        NetstrapService.getWifiStatus()
    }
    
    func connectWiFi(auto: Bool) {
        print("Connect WiFi")
        print("CurrentSelectAP index:\(currentSelectAPIndex)")
        connectAP = discoveredAP[currentSelectAPIndex]
        if (connectAP == nil) {
            showErrorHud(msg: "Error")
            return
        }
        
        if (didConnect) {
            let connectedAP = WiFiManager.sharedInstance().connectAP
            let selectAP = discoveredAP[currentSelectAPIndex]
            if (connectedAP?.ssid == selectAP.ssid) {
                showInfoHud(msg: "Already Connected.")
                return
            }
            else{
                didConnect = false
                
                let deleteCellPath = IndexPath(item: 1, section: 0)
                if let _ = tableView.cellForRow(at: deleteCellPath) {
                    tableView.deleteRows(at: [deleteCellPath], with: .automatic)
                }
                
                if connectedAP != nil {
                    discoveredAP.append(connectedAP!)
                    
                    let addCellPath = IndexPath(item: discoveredAP.count-1, section: 1)
                    tableView.insertRows(at: [addCellPath], with: .automatic)
                    
                }
            }
        }
        
        isConnecting = true
        isScanning = false
        didConnect = false
        
        print("insertRowForSection1")
        let checkCellPath = IndexPath(item: 1, section: 0)
        if let _ = tableView.cellForRow(at: checkCellPath) {
            print("deleteRowsFirst")
            tableView.deleteRows(at: [checkCellPath], with: .automatic)
        }
        let addCellPath = IndexPath(item: 1, section: 0)
        tableView.insertRows(at: [addCellPath], with: .automatic)
        
        print("removeRowForSection2")
        discoveredAP.remove(at: currentSelectAPIndex)
        let deleteCellPath = IndexPath(item: currentSelectAPIndex, section: 1)
        if let _ = tableView.cellForRow(at: deleteCellPath) {
            tableView.deleteRows(at: [deleteCellPath], with: .automatic)
        }
        
        print("要連線的AP:",connectAP!.ssid!)
        
        //var bytesArray : [UInt8] = [0x01, 0x00]
        //print("cmd_Id bytes:",bytesArray)
        var bytesArray = [UInt8]()
        
        let dataLengthBytes = HexConverter.dataLengthToBytesArray(dataLength: 8 + password!.count, arrayCount: 2)
        print("dataLengthBytes:\(dataLengthBytes)")
        
        print("bssidBytes:\(connectAP!.bssidBytes!)")
        
        let connectedByte = connectAP!.connected.toU8
        print("connectedByte:\(connectedByte)")
        
        let pwdLengthByte = password!.count.toU8
        print("pwdLengthByte:\(pwdLengthByte)")
        
        bytesArray.append(contentsOf: dataLengthBytes.reversed())
        bytesArray.append(contentsOf: connectAP!.bssidBytes!)
        bytesArray.append(connectedByte)
        bytesArray.append(pwdLengthByte)
        
        if password!.count != 0 {
            let passwordBytes: [UInt8] = Array(password!.utf8)
            print("passwordBytes:\(passwordBytes)")
            bytesArray.append(contentsOf: passwordBytes)
        }
        
        
        //let data = Data(bytesArray)
        //print("data:",data)
        //print("hexDataStr:", HexConverter.bytesDataToHexString(data: data))
        //BluetoothManager.sharedInstance().writeValue(data: data)
        NetstrapService.connectWiFi(bytes: bytesArray)
    }
    
    // MARK: Cell Delegate
    func resetButtonDidClick() {
        SVProgressHUD.show()
        NetstrapService.wifiReset()
    }
    
    func connectButtonDidClick(name:String, section:Int) {
        if (section == 0) {
            print("Show WiFi Status for connected AP")
            getWifiStatus()
        }
        else {
            //currentSelectAPIndex 在Inset/Delete時會變，不準
            for (idx,ap) in discoveredAP.enumerated() {
                if ap.ssid == name {
                    currentSelectAPIndex = idx
                    break
                }
            }
            
            if (currentSelectAPIndex == -1) {
                print("currentSelectAPIndex = -1")
                showErrorHud(msg: "Error! Please Retry.")
                return
            }
            
            let selectAP = discoveredAP[currentSelectAPIndex]
            print("The \(currentSelectAPIndex) AP \(selectAP.ssid ?? "unknown") is select to connect!")
            if (didConnect) {
                if WiFiManager.sharedInstance().connectAP?.ssid == selectAP.ssid {
                    showInfoHud(msg: "Already Connected.")
                    return
                }
            }
            
            //需要密碼
            if (selectAP.authMode != 0) {
                let vc = UIStoryboard(name: "Ble", bundle: nil).instantiateViewController(withIdentifier: "SetWiFiPasswordVC") as! SetWiFiPasswordViewController
                vc.apName = selectAP.ssid
                self.present(vc, animated: true, completion: nil)
            }
            else {
                print("連線AP不需要密碼")
                defaultAPName = discoveredAP[currentSelectAPIndex].ssid
                defaultAPPassword = ""
                password = ""
                connectWiFi(auto: false)
            }
        }
    }
    
    @objc func setPasswordDone(_ notification: Notification) {
        let password = notification.userInfo?["password"] as! String
        let ssid = notification.userInfo?["ssid"] as! String
        self.password = password
        
        //currentSelectAPIndex 在setPassword回來會被reset
        if (currentSelectAPIndex == -1) {
            for (idx,ap) in discoveredAP.enumerated() {
                if ap.ssid == ssid {
                    currentSelectAPIndex = idx
                    break
                }
            }
        }
        
        if (currentSelectAPIndex == -1) {
            print("currentSelectAPIndex = -1")
            showErrorHud(msg: "Error! Please Retry.")
            return
        }
        else{
            print("設置的密碼是:\(self.password!)")
            if password != "" && currentSelectAPIndex < discoveredAP.count {
                defaultAPName = discoveredAP[currentSelectAPIndex].ssid
                //defaultAPPassword = self.password //成功連上再設定
                
                connectWiFi(auto: false)
            }
        }
    }
    
    
    // MARK: Respond From Service
    func didReceivedWifiConnectRsp(byteArray:[UInt8]) {
        print("WIFI CONNECT RESPONSE")
        print("bytes:\(byteArray)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [WIFI_CONNECT_RSP]")
        
        
        let successUInt8 = byteArray[4]
        let successInt = HexConverter.byteToInt(byte: successUInt8)
        if (successInt == 0) {//wifi连接成功
          if(wifiMac != nil){
            let uuid : String = UserDefaults.standard.string(forKey: "uuid")!
            let token : String = UserDefaults.standard.string(forKey: "token")!
            let rfid = wifiMac?.replacingOccurrences(of: ":", with: "")
            //发送绑定请求
              let param: [String: String] = ["rfid": rfid ?? "", "name": "MagDock 1", "type": "dock"] // 参数
              let header: [String: String] = ["uuid": uuid, "token": token] //请求头
              Alamofire.request("https://app.ipitaka.com/api/app/dock", method: .post, parameters: param, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
                         if response.error == nil {
                             print("Post 请求成功：\(response.result.value ?? "")")
                         }else{
                             print("Post 请求失败：\(response.error ?? "" as! Error)")
                         }
                     }
            }
            
            print("WIFI CONNECT SUCCESS")
            showSuccessHud(msg: "WIFI CONNECT SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** WIFI CONNECT SUCCESS")
            
            isConnecting = false
            didConnect = true
            WiFiManager.sharedInstance().isConnected = true
            WiFiManager.sharedInstance().connectAP = connectAP
            
            //更新(如有)上一個Defaults
            defaultAPPassword = self.password //確定有成功連上才加，不然失敗的話仍會AutoConnect
            Defaults[.wifiAP] = defaultAPName
            Defaults[.wifiPassword] = defaultAPPassword
 
            let reloadCellPath = IndexPath(item: 1, section: 0)
            let aCell = self.tableView.cellForRow(at: reloadCellPath) as? WiFiCell
            aCell?.didConnectWifi()

        }
        else {
            print("WIFI CONNECT FAILED")
            showErrorHud(msg: "WIFI CONNECT FAILED")
            LogService.shared.addLogWithNewLine(log: "*** WIFI CONNECT FAILED")
            
            isConnecting = false
            didConnect = false
            WiFiManager.sharedInstance().isConnected = false
            WiFiManager.sharedInstance().connectAP = nil
            
            if (tableView.numberOfRows(inSection: 0) > 0) {
                /*
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                if (cell) {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                */
                
                let deleteCellPath = IndexPath(item: 1, section: 0)
                if let _ = tableView.cellForRow(at: deleteCellPath) {
                    tableView.deleteRows(at: [deleteCellPath], with: .automatic)
                }
                
            }
            
            if connectAP != nil {
                discoveredAP.insert(connectAP!, at: currentSelectAPIndex)
                let addCellPath = IndexPath(item: currentSelectAPIndex, section: 1)
                tableView.insertRows(at: [addCellPath], with: .automatic)
                
            }
        }
    }
    
    func didReceivedWifiResetRsp(byteArray:[UInt8]) {
        print("WIFI RESET RESPONSE")
        print("bytes:\(byteArray)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [WIFI_RESET_RSP]")
        
        //0810 0100 00
        let successUInt8 = byteArray[4]
        if successUInt8 == 0x00 {
            print("WIFI RESET SUCCESS")
            showSuccessHud(msg: "WIFI RESET SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** WIFI RESET SUCCESS")
            
            /*
            if (tableView.numberOfRows(inSection: 0) > 0) {
                let deleteCellPath = IndexPath(item: 1, section: 0)
                tableView.deleteRows(at: [deleteCellPath], with: .automatic)
            }
            
            if connectAP != nil {
                discoveredAP.insert(connectAP!, at: currentSelectAPIndex)
                
                let addCellPath = IndexPath(item: currentSelectAPIndex, section: 1)
                tableView.insertRows(at: [addCellPath], with: .automatic)
            }
            */
            
            isConnecting = false
            didConnect = false
            connectAP = nil
            
            defaultAPName = nil
            defaultAPPassword = nil
            Defaults[.wifiAP] = nil
            Defaults[.wifiPassword] = nil
            
            WiFiManager.sharedInstance().isConnected = false
            WiFiManager.sharedInstance().connectAP = nil
            
            discoveredAP.removeAll()
            tableView.reloadData()
            
            delay(1.5) {
                self.startScanWifi()
            }
            
        }
        else {
            print("WIFI RESET FAILED")
            showErrorHud(msg: "WIFI RESET FAILED")
            LogService.shared.addLogWithNewLine(log: "*** WIFI RESET FAILED")
        }
    }
    
    
    func didReceivedWifiScanRsp(byteArray:[UInt8]) {
        if (byteArray.count < 14) {
            print("收到的Scan Wifi RSP不是正確的格式")
            return
        }
        
        let ssidLengtUInt8 =  byteArray[4]
        //print("ssidLengtUInt8:",ssidLengtUInt8)
        
        let ssidLengtInt = HexConverter.byteToInt(byte: ssidLengtUInt8)
        //print("ssidLengtInt:",ssidLengtInt)
        
        
        var ssidName = "Unknown WiFi AP"
        let ssidStartIndex = 5
        if (ssidLengtInt > 0  && byteArray.count > (ssidStartIndex+ssidLengtInt-1)) {
            let ssidByteArray = byteArray[ssidStartIndex...(ssidStartIndex+ssidLengtInt-1)]
            //print("ssidByteArray:",ssidByteArray)
            
            let ssidNameData = Data(ssidByteArray)
            if let ssidNameStr = String.init(data: ssidNameData, encoding: .utf8) {
                ssidName = ssidNameStr
            }
            print("ssidName:",ssidName)
        }
        else{
            print("AP has no ssid name.")
        }
        
        
        //let hexEncodedString = ssidData.hexEncodedString()
        //print("hexEncodedString:",hexEncodedString)
        
        let bssidEndIndex = byteArray.count-4 //倒數第4個
        if (bssidEndIndex > 0 && (bssidEndIndex-6+1 < 0) ) {
            //取不到bssid, 後面Wifi也無法connect
            return
        }
        
        let bssidByteArray = Array<UInt8>(byteArray[(bssidEndIndex-6+1)...bssidEndIndex])
        let bssidNameData = Data(bssidByteArray)
        var bssidName = "Unknown BSSID"
        if let bssidNameStr = String.init(data: bssidNameData, encoding: .utf8) {
            bssidName = bssidNameStr
            print("bssidName:",bssidName)
        }
        print("bssidNameData:",bssidNameData)
        print("bssidByteArray:",bssidByteArray)
        
       
        let macAddress = HexConverter.bytesArrayToStringWithSemicolon(bytes: bssidByteArray)
        print("macAddress:\(macAddress)")
        
        
        let authModeUInt8 =  byteArray[byteArray.count-3] //倒數第3個
        let authModeInt = HexConverter.byteToInt(byte: authModeUInt8)
        print("authModeInt:",authModeInt)
        
        let connectedUInt8 = byteArray[byteArray.count-1] //倒數第1個
        let connectedInt = HexConverter.byteToInt(byte: connectedUInt8)
        print("connectedInt:",connectedInt)
        print("")
        
        
        if discoveredAP.contains(where: {$0.ssid == ssidName}) {
            print("\(ssidName) 重覆AP不加入")
        }
        else{
            let newAP = APModel(ssid: ssidName, bssid: bssidName, bssidData:bssidNameData,bssidBytes: bssidByteArray, authMode: authModeInt, connected: connectedInt)
            
            if (didConnect) {
                let connectedAP = WiFiManager.sharedInstance().connectAP
                if (connectedAP?.ssid == newAP.ssid) {
                    print("\(ssidName) 已Connected, 不加入AP list")
                }
                else{
                    discoveredAP.append(newAP)
                    let addCellPath = IndexPath(item: Int(discoveredAP.count - 1), section: 1)
                    tableView.insertRows(at: [addCellPath], with: .automatic)
                }
            }
            else{
                discoveredAP.append(newAP)
                let addCellPath = IndexPath(item: Int(discoveredAP.count - 1), section: 1)
                tableView.insertRows(at: [addCellPath], with: .automatic)
            }
        }
    }
    
    func didReceivedWifiScanEndRsp(byteArray:[UInt8]) {
        print("BLEWIFI_RSP_SCAN_END")
        DispatchQueue.main.async {
            self.isScanning = false
            self.tableView.reloadData()
            self.checkAutoConnectWifi()
            SVProgressHUD.dismiss(withDelay: 0.5)
        }
    }
    
    func didReceivedWifiStatusRsp(byteArray:[UInt8]) {
        print("WIFI STATUS RESPONSE")
        print("bytes:\(byteArray)")
        SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [WIFI_STATUS_RSP]")
        
        //RSP
        //0710 2400 00 10 544f544f4c494e4b5f41 333030325255
        //784476ef d2c0c0a8 0012ffff ff00 c0a80001
        
        
        //IP STATUS NOTIFY
        //0020 2400 00(status) 10(ssid length) 544f544f4c494e4b5f41(ssid) 333030325255(bssid)
        //784476ef(ip) d2c0c0a8(mask) 0011ffff(gateway) ff00 c0a80001
        
        //IP STATUS NOTIFY
        //<00202400 0010544f 544f4c49 4e4b5f41 33303032 52557844 76efd2c0 c0a8000f ffffff00 c0a80001>
        
        if (byteArray.count < 24) {
            print("收到的Wifi Status RSP不是正確的格式")
            return
        }
        //print("byteArray.count:\(byteArray.count)")
        
        
        let successInt = HexConverter.byteToInt(byte: byteArray[4])
        if successInt == 0 {
            //SVProgressHUD.showSuccess(withStatus: "GET WIFI STATUS SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** GET WIFI STATUS SUCCESS")
            
            let ssidLengtInt = HexConverter.byteToInt(byte: byteArray[5])
            print("ssidLengtInt:",ssidLengtInt)
            
            var ssidName = "Unknown WiFi AP"
            let ssidStartIndex = 6
            let ssidEndIndex = ssidStartIndex+ssidLengtInt-1
            if (ssidLengtInt > 0  && byteArray.count > ssidEndIndex) {
                let ssidByteArray = Array(byteArray[ssidStartIndex...ssidEndIndex])
                //print("ssidByteArray:",ssidByteArray)
                
                //let ssidNameData = Data(ssidByteArray)
                let ssidNameStr = HexConverter.bytesArrayToString(bytes: ssidByteArray)
                ssidName = ssidNameStr
                print("ssidName:",ssidName)
            }
            else{
                print("AP has no ssid name.")
            }
            
            
            //let hexEncodedString = ssidData.hexEncodedString()
            //print("hexEncodedString:",hexEncodedString)
            let bssidStartIndex = ssidEndIndex + 1
            let bssidEndIndex = bssidStartIndex + 5
            let bssidByteArray = Array<UInt8>(byteArray[bssidStartIndex...bssidEndIndex])
            let bssidNameData = Data(bssidByteArray)
            var bssidName = "Unknown BSSID"
            if let bssidNameStr = String.init(data: bssidNameData, encoding: .utf8) {
                bssidName = bssidNameStr
                print("bssidName:",bssidName)
            }
            print("bssidNameData:",bssidNameData)
            print("bssidByteArray:",bssidByteArray)
            
            let macAddress = HexConverter.bytesArrayToMacAddressWithDot(bytes:bssidByteArray)
            print("macAddress:\(macAddress)")
            
            let ipStartIndex = bssidEndIndex + 1
            let ipEndIndex = ipStartIndex + 3
            let ipByteArray = Array<UInt8>(byteArray[ipStartIndex...ipEndIndex])
            let ipAddress = HexConverter.bytesArrayToMacAddressWithDot(bytes:ipByteArray)
            print("ipAddress:\(ipAddress)")
            
            let maskStartIndex = ipEndIndex + 1
            let maskEndIndex = maskStartIndex + 3
            let maskByteArray = Array<UInt8>(byteArray[maskStartIndex...maskEndIndex])
            let maskAddress = HexConverter.bytesArrayToMacAddressWithDot(bytes:maskByteArray)
            print("maskAddress:\(maskAddress)")
            
            let gatewayStartIndex = maskEndIndex + 1
            let gatewayEndIndex = gatewayStartIndex + 3
            let gatewayByteArray = Array<UInt8>(byteArray[gatewayStartIndex...gatewayEndIndex])
            let gatewayAddress = HexConverter.bytesArrayToMacAddressWithDot(bytes:gatewayByteArray)
            print("gatewayAddress:\(gatewayAddress)")
            
            if (connectAP != nil) {
                connectAP!.ipAddress = ipAddress
                connectAP!.maskAddress = maskAddress
                connectAP!.gatewayAddress = gatewayAddress
            }
            
            print("IP Address:\(connectAP!.ipAddress ?? "")")
            print("Mask Address:\(connectAP!.maskAddress ?? "")")
            print("Gateway Address:\(connectAP!.gatewayAddress ?? "")")
            let message = "IP Address:\(connectAP!.ipAddress ?? "")\n" + "Mask Address:\(connectAP!.maskAddress ?? "")\n" + "Gateway Address:\(connectAP!.gatewayAddress ?? "")"
            let alertController = UIAlertController(title: "\(connectAP!.ssid ?? "WiFi Detail")", message: message, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
        }
        else {
            showErrorHud(msg: "GET WIFI STATUS FAILED")
            LogService.shared.addLogWithNewLine(log: "*** GET WIFI STATUS FAILED")
        }

    }
    
    func didReceivedWifiDisconnectRsp() {
        print("BLEWIFI_RSP_DISCONNECT")
        isConnecting = false
    }
  
    func didReceivedReadWiFiMacRsp(bytes:[UInt8]) {
        print("READ WIFI MAC RESPONSE")
        print("bytes:\(bytes)")
        //SVProgressHUD.dismiss()
        
        LogService.shared.add(log: "-> [TO_PROCESS_RX_PACKET]")
        LogService.shared.add(log: "-> [READ_WIFI_MAC_RSP]")
        
        //0316 0600 22334455 6686
        let successInt = HexConverter.byteToInt(byte: bytes[2])
        if successInt == 6 {
            print("READ WIFI MAC SUCCESS")
            //showSuccessHud(msg: "READ WIFI MAC SUCCESS")
            LogService.shared.addLogWithNewLine(log: "*** READ BLE MAC SUCCESS")
            
            let macAddressBytes = Array(bytes[4...bytes.count-1])
            let macAddress = HexConverter.bytesArrayToStringWithSemicolon(bytes: macAddressBytes)
            wifiMac = macAddress
            //readWifiMacTextField.text = macAddress
            LogService.shared.add(log: "WiFi MAC \(macAddress)")
        }
        else{
//            print("READ WIFI MAC FAILED")
//            showErrorHud(msg: "READ WIFI MAC FAILED")
            LogService.shared.addLogWithNewLine(log: "*** READ WIFI MAC FAILED")
        }
    }
    
    
}

extension WiFiSetupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return (isConnecting || didConnect) ? 2 : 1
        }
        return discoveredAP.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "" : "選擇網路..."
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            //WiFiResetCell
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WiFiResetCell", for: indexPath) as! WiFiResetCell
                cell.delegate = self
                return cell
            }
            //第二个cell 正在连接和已连接时显示
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WiFiCell", for: indexPath) as! WiFiCell
                if (didConnect) {
                    if let connectedAp = WiFiManager.sharedInstance().connectAP {
                        cell.config(ap: connectedAp, isConnecting: false, index: 1, section:0)
                        cell.didConnectWifi()
                    }
                    else{
                        cell.config(ap: discoveredAP[currentSelectAPIndex], isConnecting: true, index: 1, section:0)
                    }
                }
                else {
                    cell.config(ap: discoveredAP[currentSelectAPIndex], isConnecting: true, index: 1, section:0)
                }
                cell.delegate = self
                return cell
            }
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WiFiCell", for: indexPath) as! WiFiCell
            if (indexPath.row <= discoveredAP.count) {
                cell.config(ap: discoveredAP[indexPath.row], isConnecting: false, index: indexPath.row, section:1)
                cell.delegate = self
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 50 : 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension WiFiSetupViewController {
    
    func didFailToDiscoverServices(error: Error?) {
        isScanning = false
        showErrorHud(msg: scanningAPFailMessage)
    }
    
    func didFailToDiscoverCharacteritics(error: Error?) {
        isScanning = false
        showErrorHud(msg: scanningAPFailMessage)
    }
    
    
    func didFailToWriteValueFor(characteristic: CBCharacteristic, error: Error?) {
        isScanning = false
        showErrorHud(msg: scanningAPFailMessage)
    }
    
    
    func serviceDidTimeout() {
        print("serviceDidTimeout")
        isScanning = false
        if (isConnecting) {
            isConnecting = false
            didConnect = false
            
            WiFiManager.sharedInstance().isConnected = false
            WiFiManager.sharedInstance().connectAP = nil
            
            let deleteCellPath = IndexPath(item: 1, section: 0)
            if let _ = tableView.cellForRow(at: deleteCellPath) {
                tableView.deleteRows(at: [deleteCellPath], with: .automatic)
            }
            
            
            if connectAP != nil {
                discoveredAP.insert(connectAP!, at: currentSelectAPIndex)
                let addCellPath = IndexPath(item: currentSelectAPIndex, section: 1)
                tableView.insertRows(at: [addCellPath], with: .automatic)
            }
            
            showErrorHud(msg: "Connect to WiFi failed.")
        }
        else{
            showErrorHud(msg: "Time Out!")
        }
        
    }
    
    func didUpdateValueFor(characteristic:CBCharacteristic) {
        
        let data = characteristic.value
        if (data != nil) {
            let byteArray = [UInt8](data!)
            //print("Receive value byteArray:",byteArray)
            
            let receiveType = NetstrapService.checkReceivePacketType(data: data!)
            switch receiveType {
            case .EVT_BLEWIFI_RSP_RESET:
                didReceivedWifiResetRsp(byteArray:byteArray)
            case .EVT_BLEWIFI_RSP_DISCONNECT:
                didReceivedWifiDisconnectRsp()
            case .EVT_BLEWIFI_RSP_CONNECT:
                didReceivedWifiConnectRsp(byteArray:byteArray)
            case .EVT_BLEWIFI_RSP_SCAN_REPORT:
                didReceivedWifiScanRsp(byteArray:byteArray)
            case .EVT_BLEWIFI_RSP_SCAN_END:
                didReceivedWifiScanEndRsp(byteArray:byteArray)
            case .EVT_BLEWIFI_RSP_WIFI_STATUS:
                didReceivedWifiStatusRsp(byteArray:byteArray)
            case .UNKNOWN_TYPE: print("UNKNOWN PACKAGE TYPE")
            case .EVT_READ_WIFI_MAC_RSP:
                didReceivedReadWiFiMacRsp(bytes:byteArray)
            default:
                print("Receive package type:\(receiveType) not belong here.")
            }
            
        }
    }
}

