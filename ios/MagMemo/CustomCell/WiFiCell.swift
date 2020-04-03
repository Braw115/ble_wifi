//
//  WiFiCell.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/30.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit

protocol WiFiCellDelegate {
    func connectButtonDidClick(name:String, section:Int)
}

class WiFiCell: UITableViewCell {
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var section: Int = 0
    
    var delegate: WiFiCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(ap: APModel, isConnecting: Bool, index: Int, section: Int) {
        self.tag = index
        self.section = section
        
        self.nameLabel.text = ap.ssid
        self.loadingView.isHidden = true
        self.tickImageView.isHidden = true
        self.lockImageView.isHidden = (ap.authMode == 0) ? true : false
        
        if (isConnecting) {
            self.loadingView.isHidden = false
            self.loadingView.startAnimating()
        }

    }
    
    func didConnectWifi() {
        self.loadingView.stopAnimating()
        self.loadingView.isHidden = true
        self.tickImageView.isHidden = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func infoButton(_ sender: Any) {
        print("more info")
        delegate?.connectButtonDidClick(name:nameLabel.text ?? "unknown", section: section)
    }
    

}
