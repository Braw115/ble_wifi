//
//  OBWViewController.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/8.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import CoreBluetooth
import SVProgressHUD

class OBWViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (BluetoothManager.sharedInstance().delegate == nil) {
            BluetoothManager.sharedInstance().delegate = self
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
        BluetoothManager.sharedInstance().delegate = nil
    }
    
    func showAlertWith(msg:String) {
        let alertController = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okayAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showHud() {
        SVProgressHUD.show()
    }
    
    func dismissHud() {
        SVProgressHUD.dismiss()
    }
    
    func showInfoHud(msg:String) {
        SVProgressHUD.showInfo(withStatus: msg)
        SVProgressHUD.dismiss(withDelay: 1)
    }
    
    func showSuccessHud(msg:String) {
        SVProgressHUD.showSuccess(withStatus: msg)
        SVProgressHUD.dismiss(withDelay: 1)
    }
    
    func showErrorHud(msg:String) {
        SVProgressHUD.showError(withStatus: msg)
        SVProgressHUD.dismiss(withDelay: 1)
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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


extension OBWViewController: BluetoothManagerDelegate {
    
    func didUpdateState(state:CBManagerState) {
        if (state != .poweredOn) {
            let alertController = UIAlertController(title: "Bluetooth is unavailable!", message: "Please go to enable bluetooth first! ", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func didDisconnect(peripheral: CBPeripheral) {
        SVProgressHUD.dismiss()
        let alertController = UIAlertController(title: "Warning", message: "Please reconnect the Bluetooth device.", preferredStyle: .alert)
        
        //let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            if let arrayVC = self.navigationController?.viewControllers {
                var foundScanPage = false
                for vc in arrayVC {
                    if (vc .isKind(of: BLEScanViewController.self)) {
                        self.navigationController?.popToViewController(vc, animated: true)
                        foundScanPage = true
                        break
                    }
                }
                if (!foundScanPage) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
        
        alertController.addAction(okayAction)
        present(alertController, animated: true, completion: nil)
    }
}

