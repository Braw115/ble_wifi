//
//  IOSIntentModule.swift
//  MagMemo
//
//  Created by liang115 on 2020/2/12.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import UIKit




@objc(IOSIntentModule)
class IOSIntentModule: NSObject {
  @objc(openBlePage:andToken:)
  func openBlePage(uuid: String,token:String) -> Void {
    DispatchQueue.main.async {
      UserDefaults.standard.set(token,forKey: "token")
      UserDefaults.standard.set(uuid, forKey: "uuid")
      let storyboard = UIStoryboard(name: "Ble", bundle: nil)
      let viewController = storyboard.instantiateViewController(withIdentifier: "BLEScanVC")
      let delegate = (UIApplication.shared.delegate) as? AppDelegate
      let rootNav = delegate?.window.rootViewController as? UINavigationController
      rootNav?.setNavigationBarHidden(false, animated: true)
      rootNav?.pushViewController(viewController, animated: true)
      //rootNav?.present(viewController, animated: true, completion: nil)
      
  }
}
}

