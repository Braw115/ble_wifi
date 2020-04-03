//
//  BLEDeviceTableViewCell.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/25.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit

protocol BLECellDelegate {
    func connectButton(index:Int)
}

class BLEDeviceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var macAddressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var pingLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    
    var delegate : BLECellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        connectButton.layer.cornerRadius = 8
    }
    
    func config(BLE:BLEDevice, index:Int) {
        var deviceName = ""
        if let localName = BLE.localName, localName.count > 0 {
            deviceName = localName
        }
        else{
            deviceName = BLE.peripheral.name ?? "Unknown Device"
        }
        
        if deviceName.contains("Unknown") {
            iconImageView.image = UIImage(named: "unknow")
        }
        else{
            iconImageView.image = UIImage(named: "bluetooth")
        }
        
        let uuidStr = BLE.peripheral.identifier.uuidString
        let idx = uuidStr.index(uuidStr.startIndex, offsetBy: 23)
        let uuidSubStr = uuidStr[..<idx] // Hello
        self.deviceNameLabel.text = deviceName
        self.macAddressLabel.text = "\(uuidSubStr)"
        self.rssiLabel.text = BLE.rssi.stringValue + " dbm"
        self.pingLabel.text = "\(BLE.pingTime) ms"

        switch BLE.peripheral.state.rawValue {
        case 0: self.statusLabel.text = "Not Bonded"
        case 1: self.statusLabel.text = "Bonding"
        case 2: self.statusLabel.text = "Bonded"
        default:
            self.statusLabel.text = "Unknown Status"
        }
    
        connectButton.tag = index
    }
    
    func update(rssi:NSNumber, ping:Int) {
        self.rssiLabel.text = rssi.stringValue + " dbm"
        self.pingLabel.text = "\(ping) ms"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func connect(_ sender: Any) {
        self.delegate?.connectButton(index: connectButton.tag)
    }
    

}
