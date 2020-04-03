//
//  FunctionMenuCell.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/29.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit

protocol FunctinMenuCellDelegate {
    func buttonDidClick(index:Int)
}

class FunctionMenuCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    var delegate : FunctinMenuCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        button.layer.cornerRadius = 5
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func buttonClick(_ sender: Any) {
        self.delegate?.buttonDidClick(index: button.tag)
    }
    
}
