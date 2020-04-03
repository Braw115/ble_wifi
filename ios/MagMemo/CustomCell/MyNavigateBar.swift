//
//  MyNavigateBar.swift
//  MagMemo
//
//  Created by liang115 on 2020/3/18.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import UIKit


@objc
protocol GoBackDelegate{
  func goBackButtonDidClick()
}

@IBDesignable
class MyNavigateBar:UIView{
  
  @IBAction func goBackButton(_ sender: Any) {
  }
  @IBInspectable var goBackButton: UIButton!
  var containerView: UIView!
  var delegate: GoBackDelegate?
  var isFirstLayout:Bool = true
  @IBInspectable var lala:UIColor = .black{
    didSet{
      self.backgroundColor = lala
    }
  }
  override func prepareForInterfaceBuilder() {
    self.backgroundColor = lala
  }
  
  //MARK: - init
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
   fileprivate func commonInit() -> Void {
          self.containerView = UIView()
          self.containerView.backgroundColor = UIColor.clear
          self.goBackButton = UIButton()
          self.goBackButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

          let gobackImage = UIImage(named: "goback")
          self.goBackButton.setBackgroundImage(gobackImage, for:.normal)
          self.containerView.addSubview(goBackButton)
          self.addSubview(containerView)
      }
  
  /************ 设置子控件的位置 *****************************/
  override func layoutSubviews() {
    super.layoutSubviews()
    // 设置 子控件 frame, 也可以在这里使用自动布局
    if isFirstLayout{
      goBackButton.frame = CGRect.init(x:20, y: 20, width:50, height:40)
      isFirstLayout = false
    }
  }
  

  
  @IBAction func goBack(_ sender: UIButton) {
    print("goBack")
    delegate?.goBackButtonDidClick()
    
  }
  
}
