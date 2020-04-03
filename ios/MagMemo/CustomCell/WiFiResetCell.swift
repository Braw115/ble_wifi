//
//  WiFiResetCell.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/30.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit

protocol WiFiResetCellDelegate {
    func resetButtonDidClick()
}

class WiFiResetCell: UITableViewCell {
    
    @IBOutlet weak var resetButton: UIButton!
    
    var delegate: WiFiResetCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        resetButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func reset(_ sender: Any) {
        print("reset Wifi")
        delegate?.resetButtonDidClick()
    }
    

}
