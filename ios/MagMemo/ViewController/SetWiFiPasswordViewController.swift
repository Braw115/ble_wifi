//
//  SetWiFiPasswordViewController.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/4.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit

class SetWiFiPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var topNavBar: UINavigationBar!
    @IBOutlet weak var secondNavBar: UINavigationBar!
    @IBOutlet weak var joinButtonItem: UIBarButtonItem!
    @IBOutlet weak var passwordTextField: UITextField!
    
    public var apName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        topNavBar.topItem?.title = "Enter-the password for \(apName!)"
        joinButtonItem.isEnabled = false
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func join(_ sender: Any) {
        if let password = self.passwordTextField.text {
            NotificationCenter.default.post(name: .passwordTextFieldDidEndSetting, object: nil, userInfo: ["ssid": apName!, "password": password])
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        //passwordTextField.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let _ = textField.text {
            joinButtonItem.isEnabled = true
        }
        else {
            joinButtonItem.isEnabled = false
        }
        
        return true
    }


}


