//
//  ReadyConnectWIFIViewController.swift
//  MagMemo
//
//  Created by liang115 on 2020/3/31.
//  Copyright © 2020 Facebook. All rights reserved.
//
import UIKit

//enum ReadyType:Int {
//    case BLEDisconnect = 0
//    case WIFISetup
//    case BLEOTA
//    case ReadWriteMac
//    case SendCMD
//}

class ReadyConnectWIFIViewController: OBWViewController {

    //@IBOutlet weak var tableView: UITableView!
  
    
  @IBOutlet weak var readyBtn: UIButton!
  @IBOutlet weak var cancelBtn: UIButton!
  override func viewDidLoad() {
        super.viewDidLoad()
    self.readyBtn.layer.cornerRadius = 25
    self.cancelBtn.layer.cornerRadius = 25

//        navigationController?.navigationBar.tintColor = .white
//        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white,
//                                                                   .font : UIFont.init(name: "Verdana", size: 15.0)!]
//        self.title = (BluetoothManager.sharedInstance().connectedPeripheralName ?? "Device") + " Connected"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        self.navigationItem.setHidesBackButton(false, animated:true);
    }
  
  @IBAction func readyToSetup(_ sender: Any) {
    print("showWifiSetup-----")
    self.performSegue(withIdentifier: "showWifiSetup", sender: self)
    
  }
  //断开链接返回上一个页面
  @IBAction func disConnect(_ sender: Any) {
     self.navigationController?.popViewController(animated: true)
     BluetoothManager.sharedInstance().disconnectPeripheral()
    
  }
}


//extension ReadyConnectWIFIViewController: FunctinMenuCellDelegate {
//
//    func buttonDidClick(index: Int) {
//        switch index {
//        case 0:
//            self.navigationController?.popViewController(animated: true)
//            BluetoothManager.sharedInstance().disconnectPeripheral()
//        case 1:
//            self.performSegue(withIdentifier: "showWifiSetup", sender: self)
//        case 2:
//            self.performSegue(withIdentifier: "showBleOta", sender: self)
//        case 3:
//            if (AppConfig.internalDebug) {
//                self.performSegue(withIdentifier: "showReadWriteMac", sender: self)
//            }
//            else{
//                self.performSegue(withIdentifier: "showReadMac", sender: self)
//            }
//        case 4:
//            self.performSegue(withIdentifier: "showSendCmd", sender: self)
//        default:
//            print("default")
//        }
//
//    }
//
//}

//extension ReadyConnectWIFIViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return (AppConfig.internalDebug) ? 5 : 4
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "FunctionMenuCell", for: indexPath) as! FunctionMenuCell
//        cell.delegate = self
//        cell.button.tag = indexPath.row
//        switch indexPath.row {
//        case 0:
//            cell.button.setTitle("BLE Disconnect", for: .normal)
//            cell.button.backgroundColor = .red
//        case 1:
//            cell.button.setTitle("WiFi Setup", for: .normal)
//            cell.button.backgroundColor = .red
//        case 2:
//            cell.button.setTitle("BLE OTA", for: .normal)
//            cell.button.backgroundColor = .blue
//        case 3:
//            cell.button.setTitle(AppConfig.internalDebug ? "Read/Write MAC" : "Read MAC", for: .normal)
//            cell.button.backgroundColor = .red
//        case 4:
//            cell.button.setTitle("Send CMD", for: .normal)
//            cell.button.backgroundColor = .blue
//        default:
//            break
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return self.view.frame.size.height/6
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//}

