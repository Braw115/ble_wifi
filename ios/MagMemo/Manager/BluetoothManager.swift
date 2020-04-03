//
//  BLECentralManager.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/31.
//  Copyright © 2019 YonLau. All rights reserved.
//

import CoreBluetooth

extension Notification.Name {
    static let didDisconnectPeripheral = Notification.Name("didDisconnectPeripheralNotification")
}

@objc protocol BluetoothManagerDelegate {
    
    @objc optional func didUpdateState(state:CBManagerState)
    @objc optional func didDiscover(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    @objc optional func didConnect(peripheral: CBPeripheral)
    @objc optional func didFailToConnect(peripheral: CBPeripheral, error: Error?)
    @objc optional func didDisconnect(peripheral: CBPeripheral)
    @objc optional func didDiscoverServices(peripheral: CBPeripheral)
    @objc optional func didFailToDiscoverServices(error:Error?)
    @objc optional func didDiscoverCharacteritics(service :CBService)
    @objc optional func didFailToDiscoverCharacteritics(error: Error?)
    @objc optional func didDiscoverDescriptors(characteristic: CBCharacteristic)
    @objc optional func didFailToDiscoverDescriptors(error: Error?)
    @objc optional func didUpdateValueFor(characteristic:CBCharacteristic)
    @objc optional func didFailToUpdateValueFor(characteristic:CBCharacteristic)
    @objc optional func didWriteValueFor(characteristic: CBCharacteristic)
    @objc optional func didFailToWriteValueFor(characteristic: CBCharacteristic, error: Error?)
    @objc optional func didUpdateNotificationStateFor(characteristic: CBCharacteristic)
    @objc optional func didFailToUpdateNotificationStateFor(error: Error?)
    @objc optional func serviceDidTimeout()
    @objc optional func connectingBleDidTimeout()
    
    
}

public class BluetoothManager : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var delegate : BluetoothManagerDelegate?
    var centralManager : CBCentralManager?
    var state: CBManagerState? {
        guard centralManager != nil else {
            return nil
        }
        return CBManagerState(rawValue: (centralManager?.state.rawValue)!)
    }
    
    var connected = false
    var isConnecting = false
    var isScanning = false
    var timer: Timer!
    var monitorTime: Int = 0
    var connectedPeripheralName : String?
    
    public var otaCountingEnable = false
    var sendOTAReqCount = 0
    var sendOTAReqSuccessCount = 0
    var receiveOTARspCount = 0
    
    private let notifCenter = NotificationCenter.default
    private var connectedPeripheral : CBPeripheral?
    private var connectingPeripheral : CBPeripheral?
    private var connectedServices : [CBService]?
    private var characteristic_read: CBCharacteristic?
    private var characteristic_write: CBCharacteristic?
    private var characteristic_writeWithoutResponse: CBCharacteristic?
    private var characteristic_notify: CBCharacteristic?
    private var characteristicArray:[CBCharacteristic]?
    
    
    private static var mInstance:BluetoothManager?
    static func sharedInstance() -> BluetoothManager {
        if mInstance == nil {
            mInstance = BluetoothManager()
            
        }
        return mInstance!
    }
    
    
    
//    static private var instance : BluetoothManager {
//        return sharedInstance
//    }
    
//    static let sharedInstance = BluetoothManager()

    private override init() {
        super.init()
        initCBCentralManager()
    }
    
    // MARK: Custom functions
    /**
     Initialize CBCentralManager instance
     */
    func initCBCentralManager() {
        var dic : [String : Any] = Dictionary()
        dic[CBCentralManagerOptionShowPowerAlertKey] = false
        //centralManager = CBCentralManager.init(delegate: self, queue: .main)
        centralManager = CBCentralManager(delegate: self, queue: .main, options: dic)
    }
    
    // MARK: Delegate
    /**
     Invoked whenever the central manager's state has been updated.
     */
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("State : Powered Off")
        case .poweredOn:
            print("State : Powered On")
        case .resetting:
            print("State : Resetting")
        case .unauthorized:
            print("State : Unauthorized")
        case .unknown:
            print("State : Unknown")
        case .unsupported:
            print("State : Unsupported")
        @unknown default:
            fatalError()
        }
        
        if let state = self.state {
            delegate?.didUpdateState?(state:state)
        }
    }

    
    /**
     The method provides for starting scan near by peripheral
     */
    func startScanPeripheral() {
        isScanning = true
        centralManager?.stopScan()
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
    }
    
    /**
     The method provides for stopping scan near by peripheral
     */
    func stopScanPeripheral() {
        isScanning = true
        centralManager?.stopScan()
    }
    
    /**
     The method provides for connecting the special peripheral
     
     - parameter peripher: The peripheral you want to connect
     */
    func connectPeripheral(_ peripheral: CBPeripheral) {
        
        if (peripheral == self.connectedPeripheral) {
            delegate?.didConnect?(peripheral: peripheral)
        }
        
        startTimer()
        isConnecting = true
        LogService.shared.addLogWithNewLine(log: "-> [TO CONNECT DEVICE]")
        connectingPeripheral = peripheral
        centralManager!.connect(peripheral, options: nil)
        //centralManager?.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : true])
    }
    
    /**
     The method provides for disconnecting with the peripheral which has connected
     */
    func disconnectPeripheral() {
        if (connected) {
            connected = false
            if connectedPeripheral != nil && connectedPeripheral?.state == CBPeripheralState.connected {
                centralManager?.cancelPeripheralConnection(connectedPeripheral!)
                connectedPeripheral = nil
                startScanPeripheral()
            }
        }
    }
    
    func discoverService() {
        connectedPeripheral?.discoverServices(nil)
    }
    
    
    /**
     The method provides for the user who want to obtain the descriptor
     
     - parameter characteristic: The character which user want to obtain descriptor
     */
    func discoverDescriptor(_ characteristic: CBCharacteristic) {
        if connectedPeripheral != nil  {
            connectedPeripheral?.discoverDescriptors(for: characteristic)
        }
    }
    
    /**
     This method provides for discovering the characteristics.
     */
    func discoverCharacteristics() {
        if connectedPeripheral == nil {
            return
        }
        let services = connectedPeripheral!.services
        if services == nil || services!.count < 1 { // Validate service array
            return;
        }
        for service in services! {
            connectedPeripheral!.discoverCharacteristics(nil, for: service)
        }
    }
    
    /**
     Read characteristic value from the peripheral
     
     - parameter characteristic: The characteristic which user should
     */
    func readValueForCharacteristic(characteristic: CBCharacteristic) {
        if connectedPeripheral == nil {
            return
        }
        connectedPeripheral?.readValue(for: characteristic)
    }
    
    /**
     Start or stop listening for the value update action
     
     - parameter enable:         If you want to start listening, the value is true, others is false
     - parameter characteristic: The characteristic which provides notifications
     */
    func setNotification(enable: Bool, forCharacteristic characteristic: CBCharacteristic){
        if connectedPeripheral == nil {
            return
        }
        connectedPeripheral?.setNotifyValue(enable, for: characteristic)
    }
    
    /**
     Write value to the peripheral which is connected
     
     - parameter data:           The data which will be written to peripheral
     - parameter characteristic: The characteristic information
     - parameter type:           The write of the operation
     */
    
    func writeValue(data: Data, writeLog: Bool = false) {
        if connectedPeripheral == nil && connectedPeripheral?.state == .connected {
            delegate?.serviceDidTimeout?()
            return
        }
        
        if (otaCountingEnable) {
            sendOTAReqCount += 1
            print("sendOTAReqCount:\(sendOTAReqCount)")
        }
        
        startTimer()
        
        if (characteristicArray != nil && characteristicArray!.count > 0) {
            for c: CBCharacteristic in characteristicArray! {
                
                if c.properties.contains(.write) {
                    connectedPeripheral?.writeValue(data, for: c, type: .withResponse)
                }
                if c.properties.contains(.writeWithoutResponse) {
                    //connectedPeripheral?.writeValue(data, for: c, type: .withoutResponse)
                }
            }
        }
        else{
            if (characteristic_write != nil) {
/*                let subDataLength = 20
                var subDataCount = 0
                let dataLength = data.count
                        
                if (dataLength > subDataLength) {
                 while (subDataCount < dataLength) && (dataLength - subDataCount > subDataLength) {
                             let subData = data.subdata(in: subDataCount..<subDataLength)
                                 connectedPeripheral?.writeValue(subData, for: characteristic_write!, type: .withResponse)
                                 subDataCount += subDataLength
                            }
                }
                        
                if (subDataCount < dataLength) {
                 let subData = data.subdata(in: subDataCount..<dataLength)
                            connectedPeripheral?.writeValue(subData, for: characteristic_write!, type: .withResponse)
                }
*/
            connectedPeripheral?.writeValue(data, for: characteristic_write!, type: .withResponse)
            }
            
            if (characteristic_writeWithoutResponse != nil) {
                //connectedPeripheral?.writeValue(data, for: characteristic_writeWithoutResponse!, type: .withoutResponse)
            }
        }
        if (writeLog) {
            let hexString = HexConverter.bytesArrayToStringWithSpace(bytes: [UInt8](data))
            LogService.shared.addLogWithNewLine(log: "*** Tx \(hexString)")
        }
        
    }
    
    // MARK: Timer
    func startTimer() {
        if (timer == nil) {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerStatus), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        monitorTime = 0
        if (timer != nil) {
            timer.invalidate()
            timer = nil
        }
        
    }

    @objc func updateTimerStatus() {
        if self.monitorTime > 4 {
            timer.invalidate()
            timer = nil
            
            if (isConnecting) {
                connectingBleTimeout()
            }
            else if (connected) {
                sendCmdTimeout()
            }
            
        }
        else{
            monitorTime += 1
            print("monitorTime:",monitorTime)
        }
    }
    
    func connectingBleTimeout() {
        print("Bluetooth Manager --> Connecting BLE TIMEOUT!")
        
        monitorTime = 0
        isConnecting = false
        connected = false
        
        if connectingPeripheral != nil {
            centralManager?.cancelPeripheralConnection(connectingPeripheral!)
            connectingPeripheral = nil
        }
        delegate?.connectingBleDidTimeout?()
    }
    
    func sendCmdTimeout() {
        print("Bluetooth Manager --> Waiting RSP TIMEOUT!")
        LogService.shared.addLogWithNewLine(log: "-> Waiting Respond Timeout!")
        monitorTime = 0
        isConnecting = (isConnecting) ? false : isConnecting
        delegate?.serviceDidTimeout?()
    }
    
    //MARK: CBCentralManagerDelegate
    /**
     This method is invoked while scanning, upon the discovery of peripheral by central
     
     - parameter central:           The central manager providing this update.
     - parameter peripheral:        The discovered peripheral.
     - parameter advertisementData: A dictionary containing any advertisement and scan response data.
     - parameter RSSI:              The current RSSI of peripheral, in dBm. A value of 127 is reserved and indicates the RSSI
     *                                was not available.
     */
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("Bluetooth Manager --> didDiscoverPeripheral, RSSI:\(RSSI)")
        delegate?.didDiscover?(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
    
    /**
     This method is invoked when a connection succeeded
     
     - parameter central:    The central manager providing this information.
     - parameter peripheral: The peripheral that has connected.
     */
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Bluetooth Manager --> didConnectPeripheral")
        
        if (isConnecting) {
            isConnecting = false
            stopTimer()
        }
        
        connected = true
        connectingPeripheral = nil
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices(nil)
        
        LogService.shared.add(log: "-> [TO_CONNECT_DEVICE]")
        LogService.shared.addLogWithNewLine(log: "*** OPL1000 Device Connected.")
        delegate?.didConnect?(peripheral: peripheral)
        stopScanPeripheral()
    }
    
    /**
     This method is invoked where a connection failed.
     
     - parameter central:    The central manager providing this information.
     - parameter peripheral: The peripheral that you tried to connect.
     - parameter error:      The error infomation about connecting failed.
     */
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Bluetooth Manager --> didFailToConnectPeripheral")
        isConnecting = false
        connected = false
        delegate?.didFailToConnect?(peripheral: peripheral, error: error!)
    }
    
    /**
     The method is invoked where services were discovered.
     
     - parameter peripheral: The peripheral with service informations.
     - parameter error:      Errot message when discovered services.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Bluetooth Manager --> didDiscoverServices")
        connectedPeripheral = peripheral
        if error != nil {
            print("Bluetooth Manager --> Discover Services Error, error:\(error?.localizedDescription ?? "")")
            delegate?.didFailToDiscoverServices?(error: error!)
            return
        }
        
        LogService.shared.add(log: "-> [TO_DISCOVER_SERVICES]")
        for service: CBService in peripheral.services! {
//            print("外设中的服务有：\(service)")
            LogService.shared.add(log: "    service:\(service.uuid)")
            //peripheral.discoverCharacteristics([CBUUID.init(string: Characteristic_UUID)], for: service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
         LogService.shared.addLogWithNewLine(log: "")
        self.delegate?.didDiscoverServices?(peripheral: peripheral)
    }
    
    /**
     The method is invoked where characteristics were discovered.
     
     - parameter peripheral: The peripheral provide this information
     - parameter service:    The service included the characteristics.
     - parameter error:      If an error occurred, the cause of the failure.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Bluetooth Manager --> didDiscoverCharacteristicsForService")
        if error != nil {
            print("Bluetooth Manager --> Fail to discover characteristics! Error: \(error?.localizedDescription ?? "")")
            delegate?.didFailToDiscoverCharacteritics?(error: error!)
            return
        }
        
        LogService.shared.add(log: "-> [TO_DISCOVER_CHARACTERISTICS]")
        for c: CBCharacteristic in service.characteristics! {
//            print("外设中的特征有：\(c)")
            characteristicArray?.append(c)
            if service.uuid == CBUUID(string: "0xAAAA"){
            LogService.shared.add(log: "   Characteristic: \(c.uuid)")
            
            if c.properties.contains(.read) {
                //print("\(c.uuid): properties contains .read")
                characteristic_read = c
            }
            if c.properties.contains(.write) {
                //print("\(c.uuid): properties contains .write")
                characteristic_write = c
                
            }
            if c.properties.contains(.writeWithoutResponse) {
                //print("\(c.uuid): properties contains .writeWithoutResponse")
                characteristic_writeWithoutResponse = c
                
            }
            if c.properties.contains(.notify) {
                //print("\(c.uuid): properties contains .notify")
                characteristic_notify = c
                setNotification(enable: true, forCharacteristic: c)
            }
        }
        LogService.shared.addLogWithNewLine(log: "*** The Tx/Rx service is ready.")
        delegate?.didDiscoverCharacteritics?(service: service)
        }
    }
    
    /**
     This method is invoked when the peripheral has found the descriptor for the characteristic
     
     - parameter peripheral:     The peripheral providing this information
     - parameter characteristic: The characteristic which has the descriptor
     - parameter error:          The error message
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("Bluetooth Manager --> didDiscoverDescriptorsForCharacteristic")
        if error != nil {
            print("Bluetooth Manager --> Fail to discover descriptor for characteristic Error:\(error?.localizedDescription ?? "")")
            delegate?.didFailToDiscoverDescriptors?(error: error!)
            return
        }
        delegate?.didDiscoverDescriptors?(characteristic: characteristic)
    }
    
    /**
     This method is invoked when the peripheral has been disconnected.
     
     - parameter central:    The central manager providing this information
     - parameter peripheral: The disconnected peripheral
     - parameter error:      The error message
     */
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Bluetooth Manager --> didDisconnectPeripheral")
        isConnecting = false
        connected = false
        connectedPeripheralName = ""
        sendOTAReqCount = 0
        sendOTAReqSuccessCount = 0
        receiveOTARspCount = 0
        
        self.delegate?.didDisconnect?(peripheral: peripheral)
        
        LogService.shared.addLogWithNewLine(log: "*** BLE Device Disconnected.")
        notifCenter.post(name: Notification.Name("didDisconnectPeripheral"), object: nil, userInfo: nil)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Bluetooth Manager --> didWriteValueForCharacteristic")
        if error != nil {
            print("Bluetooth Manager --> Failed to write value for characteristic. Error:\(error!.localizedDescription)")
            delegate?.didFailToWriteValueFor?(characteristic: characteristic, error: error)
            //delegate?.didFailToReadValueForCharacteristic?(error!)
            return
        }
        print("写入数据成功 characteristic:\(characteristic)")
        
        if (otaCountingEnable) {
            sendOTAReqSuccessCount += 1
            print("sendOTAReqCount:\(sendOTAReqSuccessCount) 次 Success")
            print("")
        }
        
        delegate?.didWriteValueFor?(characteristic: characteristic)
    }
    
    /**
     Thie method is invoked when the user call the peripheral.readValueForCharacteristic
     
     - parameter peripheral:     The periphreal which call the method
     - parameter characteristic: The characteristic with the new value
     - parameter error:          The error message
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Bluetooth Manager --> didUpdateValueForCharacteristic")
        
        stopTimer()
        
        if error != nil {
            print("Bluetooth Manager --> Failed to read value for the characteristic. Error:\(error!.localizedDescription)")
            delegate?.didFailToUpdateValueFor?(characteristic: characteristic)
            return
        }
        print("接收到数据 characteristic:\(characteristic)")
        
        if (otaCountingEnable) {
            receiveOTARspCount += 1
            //print("🍭 receiveOTARspCount:\(receiveOTARspCount)")
            //print("")
        }
        
        delegate?.didUpdateValueFor?(characteristic: characteristic)
        
    }
    
    private func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("Bluetooth Manager --> didUpdateNotificationStateForCharacteristic")
        if error != nil {
            print("Bluetooth Manager --> Failed to update notification state for the characteristic. Error:\(error!.localizedDescription)")
            print("订阅失败: \(error!)")
            delegate?.didFailToUpdateNotificationStateFor?(error: error)
        }

        //Notification has started
        if(characteristic.isNotifying){
            print("\(characteristic)订阅成功")
            peripheral.readValue(for: characteristic);
        }
        else{
            print("\(characteristic)取消订阅")
        }
        
        delegate?.didUpdateNotificationStateFor?(characteristic: characteristic)
    }
    
}


