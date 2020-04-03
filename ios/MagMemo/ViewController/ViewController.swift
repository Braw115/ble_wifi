//
//  ViewController.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/25.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import LTMorphingLabel
import SVProgressHUD

class ViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabelCenter: LTMorphingLabel!
    @IBOutlet weak var toolButton: UIButton!
    
    var secretButtonTapCount = 0
    var secretTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var title = "OPL1000"
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            title = title + " v\(appVersion)"
        }
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            title = title + " (\(build))"
        }
        self.title = title
        
        toolButton.layer.cornerRadius = 8
        
        titleLabelCenter.text = "WE KNOW\nHOW TO \nCONNECT ANYTHING &\nEVERYTHING"
        titleLabelCenter.adjustsFontSizeToFitWidth = true
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.navigationBar.barTintColor = .init(red: 63.0/255, green: 81.0/255, blue: 181.0/255, alpha: 1.0)
//        navigationController?.navigationBar.tintColor = .blue
//        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white,
//                                                                   .font : UIFont.init(name: "Verdana", size: 20.0)!]
        //隐藏默认navigationBar
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    
    @IBAction func internalDebug(_ sender: Any) {
        if (secretTimer == nil) {
            secretTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDownTimer), userInfo: nil, repeats: false)
        }
        secretButtonTapCount += 1
        //print("secretButtonTapCount:\(secretButtonTapCount)")
    }
    
    @objc func countDownTimer()
    {
        secretTimer?.invalidate()
        secretTimer = nil
        
        if (secretButtonTapCount >= 5) {
            AppConfig.internalDebug = true
            SVProgressHUD.showInfo(withStatus: "Internal Debug Mode")
        }
    }
    

}

