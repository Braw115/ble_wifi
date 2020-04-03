//
//  Extension.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/5/25.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension Notification.Name {
    static let passwordTextFieldDidEndSetting = Notification.Name("kPasswordTextFieldDidEndSetting")
}

extension DefaultsKeys {
    static let wifiAP = DefaultsKey<String?>("wifiAP")
    static let wifiPassword = DefaultsKey<String?>("wifiPassword")
}

extension UIButton {
    private func actionHandler(action:(() -> Void)? = nil) {
        struct __ { static var action :(() -> Void)? }
        if action != nil { __.action = action }
        else { __.action?() }
    }
    @objc private func triggerActionHandler() {
        self.actionHandler()
    }
    func actionHandler(controlEvents control :UIControl.Event, ForAction action:@escaping () -> Void) {
        self.actionHandler(action: action)
        self.addTarget(self, action: #selector(triggerActionHandler), for: control)
    }
}

extension UITextView {
    func scrollToBotom() {
        let range = NSMakeRange(text.count - 1, 1);
        scrollRangeToVisible(range);
    }
}


extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
    
    // 16进制转10进制
    var hexaToDecimal: Int {
        return Int(strtoul(self, nil, 16))
    }
    // 16进制转2进制
    var hexaToBinary: String {
        return hexaToDecimal.toBinary
    }
    // 2进制转10进制
    var binaryToDecimal: Int {
        return Int(strtoul(self, nil, 2))
    }
    // 2进制转16进制
    var binaryToHexa: String {
        return binaryToDecimal.toHexa
    }
    
    var hexStringAddComma: String {
        var result = ""
        var i = 1
        for c in self {
            result.append(c)
            if (i == 2) {
                result.append(",")
                i = 0
            }
            i = i+1
        }
        result.remove(at: result.index(before: result.endIndex))
        return result
    }
}

extension Int {
    public var toU8: UInt8{ get{return UInt8(self)} }
    public var to8: Int8{ get{return Int8(self)} }
    public var toU16: UInt16{get{return UInt16(self)}}
    public var to16: Int16{get{return Int16(self)}}
    public var toU32: UInt32{get{return UInt32(self)}}
    public var to32: Int32{get{return Int32(self)}}
    public var toU64: UInt64{get{
        return UInt64(self) //No difference if the platform is 32 or 64
        }}
    public var to64: Int64{get{
        return Int64(self) //No difference if the platform is 32 or 64
        }}
    
    // 10进制转2进制
    var toBinary: String {
        return String(self, radix: 2, uppercase: true)
    }
    // 10进制转16进制
    var toHexa: String {
        return String(self, radix: 16)
    }
}



extension Data {
    /*
     let data = Data(bytes: [0, 1, 127, 128, 255])
     print(data.hexEncodedString()) // 00017f80ff
     print(data.hexEncodedString(options: .upperCase)) // 00017F80FF
     */
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}



