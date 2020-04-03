//
//  BLEScanViewController.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/25.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import CoreBluetooth
import SVProgressHUD

class BLEScanViewController: OBWViewController, BLECellDelegate,
UISearchControllerDelegate {


  @IBAction func goBack(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var navigationBar: UINavigationBar!
  @IBOutlet weak var bottomView: UIView!
  
  @IBOutlet weak var scanButton: UIButton!
  
  @IBAction func scanning() {
    self.startScan()
  }
  var stopScanBarButtonItem: UIBarButtonItem!
    var startScanBarButtonItem: UIBarButtonItem!
    var searchController:UISearchController!
    var discoveredBLE = [BLEDevice]()
    var searchBLEResult = [BLEDevice]()
 
    var isScanning = false
    var previousScanTime:TimeInterval = 0
    
    //當 controller 是從 storyboard 生成時，它將呼叫 init(coder:)，因此我們可在其中初始 property 的內容。
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.navigationBar.shadowImage=UIImage()
      self.scanButton.layer.cornerRadius=25
      self.tableView.separatorStyle = .none
      self.tableView.isScrollEnabled = false
        //styleNavigationBar()
        
//        searchController = UISearchController(searchResultsController: nil)
//        searchController.searchBar.sizeToFit()
//        searchController.searchBar.placeholder = "Filter by Name"
//        searchController.delegate = self
//        searchController.searchResultsUpdater = self
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.hidesNavigationBarDuringPresentation = true
        
//        if #available(iOS 11.0, *) {
//            navigationItem.searchController = searchController
//            navigationItem.hidesSearchBarWhenScrolling = false
//            searchController.searchBar.tintColor = .white
//
//            for textField in searchController.searchBar.subviews.first!.subviews where textField is UITextField {
//                textField.subviews.first?.backgroundColor = .white
//                textField.subviews.first?.layer.cornerRadius = 5
//                textField.subviews.first?.layer.masksToBounds = true
//            }
//
//        } else {
//            tableView.tableHeaderView = searchController.searchBar
//        }
        definesPresentationContext = true
        
        BluetoothManager.sharedInstance().delegate = self
        if (BluetoothManager.sharedInstance().state == .poweredOn) {
            startScan()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.navigationBar.barTintColor = .init(red: 63.0/255, green: 81.0/255, blue: 181.0/255, alpha: 1.0)
//        navigationController?.navigationBar.tintColor = .white
//        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white,
//                                                                 .font : UIFont.init(name: "Verdana", size: 20.0)!]
      navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //navigationController?.navigationBar.barTintColor = .init(red: 63.0/255, green: 81.0/255, blue: 181.0/255, alpha: 1.0)
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //navigationController?.setNavigationBarHidden(true, animated: true)
        stopScan()
    }
    
//    func styleNavigationBar() {
//
//        self.title = "Device"
//
//        stopScanBarButtonItem = UIBarButtonItem(title: "Stop Scanning...", style: UIBarButtonItem.Style.plain, target: self, action: #selector(BLEScanViewController.toggleScan(_:)))
//        startScanBarButtonItem = UIBarButtonItem(title: "Scan", style: UIBarButtonItem.Style.plain, target: self, action: #selector(BLEScanViewController.toggleScan(_:)))
//        styleUIBarButton(self.startScanBarButtonItem)
//        styleUIBarButton(self.stopScanBarButtonItem)
//        navigationItem.rightBarButtonItem = startScanBarButtonItem
//
//
//        navigationController?.navigationBar.tintColor = .white
//        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white,
//                                                                   .font : UIFont.init(name: "Verdana", size: 20.0)!]
//    }
    
    func styleUIBarButton(_ button:UIBarButtonItem) {
        let font = UIFont(name:"Thonburi", size:16.0)
        var titleAttributes: [NSAttributedString.Key: Any]
        if let defaultTitleAttributes = UINavigationBar.appearance().titleTextAttributes {
            titleAttributes = defaultTitleAttributes
        } else {
            titleAttributes = [NSAttributedString.Key: Any]()
        }
        titleAttributes[NSAttributedString.Key.font] = font
        button.setTitleTextAttributes(titleAttributes, for:UIControl.State())
    }
    
  @objc func toggleScan(_ sender: AnyObject) {
        if (isScanning) {
            stopScan()
        }
        else{
            startScan()
        }
    }
    
    func startScan() {
        
        //SVProgressHUD.dismiss() //Scan不會ShowLoading, 不過還在Connecting的要dimiss
        
        isScanning = true
        navigationItem.rightBarButtonItem = stopScanBarButtonItem
        
        BluetoothManager.sharedInstance().stopScanPeripheral()
        discoveredBLE.removeAll()
        searchBLEResult.removeAll()
        tableView.reloadData()
        
        previousScanTime = NSDate().timeIntervalSince1970
        BluetoothManager.sharedInstance().startScanPeripheral()
        
    }
    
    func stopScan() {
        SVProgressHUD.dismiss()
        isScanning = false
        navigationItem.rightBarButtonItem = startScanBarButtonItem
        
        BluetoothManager.sharedInstance().stopScanPeripheral()
        previousScanTime = 0
    }
    
    
    func connectButton(index:Int) {
        print("Connect to \(index) Bluetooth device.")
        stopScan()
        
//        if (searchController.isActive) {
//            if index <= searchBLEResult.count {
//                let peripheral = searchBLEResult[index].peripheral
//                BluetoothManager.sharedInstance().connectPeripheral(peripheral)
//                SVProgressHUD .show(withStatus: "Connecting...")
//            }
//        }
//        else{
            if index <= discoveredBLE.count {
                let peripheral = discoveredBLE[index].peripheral
                BluetoothManager.sharedInstance().connectPeripheral(peripheral)
                SVProgressHUD .show(withStatus: "Connecting...")
            }
        //}

    }
}

extension BLEScanViewController {

  override func didUpdateState(state:CBManagerState) {
        if (state == .poweredOn) {
            startScan()
        }
        else{
            let alertController = UIAlertController(title: "Bluetooth is unavailable!", message: "Please go to enable bluetooth first! ", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func didDiscover(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let newBLE = BLEDevice(peripheral:peripheral, UUID: peripheral.identifier.uuidString, advertisementDictionary:advertisementData, rssi: RSSI)
        var deviceName = ""
        if let localName = advertisementData["kCBAdvDataLocalName"]as? String{
            newBLE.localName = localName
            deviceName = localName
        }else{
            deviceName = newBLE.peripheral.name ?? "Unknown Device"
        }
        if !deviceName.contains("Apple") {
                   return
        }
        let UUIDString = peripheral.identifier.uuidString
        let currentTime = NSDate().timeIntervalSince1970
        let pingTime = (currentTime - previousScanTime)*1000
        previousScanTime = currentTime
        
        if discoveredBLE.contains(where: {$0.UUID == UUIDString}) {
            
            // it exists, do something
            for (idx, BLE) in discoveredBLE.enumerated() {
                if BLE.UUID == UUIDString {
                    let oldNode = discoveredBLE[idx]
                    oldNode.updateRSSI(RSSI)
                    
                    let newPingTime = Int(pingTime) - oldNode.pingTime
                    oldNode.pingTime = (newPingTime > 0) ? newPingTime : oldNode.pingTime
                    
                    let reloadCellPath = IndexPath(item: Int(idx), section: 0)
                    let aCell = tableView.cellForRow(at: reloadCellPath) as? BLEDeviceTableViewCell
                    DispatchQueue.main.async {
                        aCell?.update(rssi: RSSI, ping: Int(oldNode.pingTime))
                    }
                    break
                }
            }
            
        } else {
            newBLE.pingTime = Int(pingTime)
            discoveredBLE.append(newBLE)
            self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
            let addCellPath = IndexPath(item: Int(self.discoveredBLE.count - 1), section: 0)
            self.tableView.insertRows(at: [addCellPath], with: .automatic)
            
        
            //DispatchQueue.main.async {
                
            //}
        }
    }
    
    func didConnect(peripheral: CBPeripheral) {
      print("didConnect-----")
     
        for ble in discoveredBLE {
            if ble.peripheral == peripheral {
              if(ble.localName ?? ble.peripheral.name == BluetoothManager.sharedInstance().connectedPeripheralName){
                     return
                   }
                BluetoothManager.sharedInstance().connectedPeripheralName = ble.localName ?? ble.peripheral.name
            }
        }
        
        SVProgressHUD .showSuccess(withStatus: "Connection successful.")
        SVProgressHUD .dismiss(withDelay: 1)
        
        // Waiting time for discover services and characteristics
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.performSegue(withIdentifier: "showReadyContentWIFI", sender: self)
        }
        
    }
    
    func didFailToConnect(peripheral: CBPeripheral, error: Error?) {
        SVProgressHUD.showError(withStatus: "Connection failed.")
    }
    
    
    func serviceDidTimeout() {
        print("serviceDidTimeout")
        SVProgressHUD.dismiss()
    }
    
    func connectingBleDidTimeout() {
        print("connectingBleDidTimeout")
        SVProgressHUD.showError(withStatus: "BLE Connection Timeout.")
    }
    
    override func didDisconnect(peripheral: CBPeripheral) {
        print("didDisconnect!")
    }
}

extension BLEScanViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (searchController.isActive) {
//            return searchBLEResult.count
//        }
//        else{
            return discoveredBLE.count
        //}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BLEDeviceCell", for: indexPath) as! BLEDeviceTableViewCell
//        if (searchController.isActive) {
//            if indexPath.row <= searchBLEResult.count {
//                cell.config(BLE: searchBLEResult[indexPath.row], index:indexPath.row)
//                cell.delegate = self
//            }
//        }
//        else{
            if indexPath.row <= discoveredBLE.count {
                cell.config(BLE: discoveredBLE[indexPath.row], index:indexPath.row)
                cell.delegate = self
                //cell.connectButton.actionHandler(controlEvents: .touchUpInside) {
                //}
            }
        //}
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}

//extension BLEScanViewController: UISearchResultsUpdating, UISearchBarDelegate {
//    
//    func updateSearchResults(for searchController: UISearchController) {
//        stopScan()
//        
//        if  let searchText = searchController.searchBar.text{
//            filterContentForSearchText(searchText.lowercased())
//            tableView.reloadData()
//        }
//    }
//    
//    func filterContentForSearchText(_ searchText: String) {
//        guard searchText != " " else {
//            return
//        }
//        searchBLEResult = discoveredBLE.filter({ (ble: BLEDevice) -> Bool in
//            let nameMatch = ble.peripheral.name?.lowercased().range(of: searchText)
//            let localNameMatch = ble.localName?.lowercased().range(of: searchText)
//            return nameMatch != nil || localNameMatch != nil
//        })
//    }
//    
//}





