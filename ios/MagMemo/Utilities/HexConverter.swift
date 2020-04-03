//
//  HexConverter.swift
//  OBWApp
//
//  Created by Yon Lau on 2019/6/8.
//  Copyright © 2019 YonLau. All rights reserved.
//

import UIKit

class HexConverter: NSObject {

    class func intToHexString(decimal:Int) -> String{
        // Decimal to hexadecimal
        return String(decimal, radix: 16)
        //return decimal.toHexa
    }
    
    class func hexStringToInt(hexString:String) -> Int {
        // Hexadecimal to decimal
        return Int(hexString, radix: 16)!
    }
    
    //Example: 0x0a -> 10
    class func byteToInt(byte:UInt8) -> Int {
        
        let bytes : [UInt8] = [byte]
        var intValue : Int = 0
        for byte in bytes {
            intValue = intValue << 8
            intValue = intValue | Int(byte)
        }
        return intValue
    }
    
    // MARK: Bytes ->
    class func bytesDataToHexString(data:Data) -> String {
        return data.hexEncodedString()
    }
    
    class func bytesDataToBytesArray(data:Data) -> [UInt8] {
        let bytesArray = [UInt8](data)
        return bytesArray
    }
    
    class func bytesArrayToString(bytes:[UInt8]) -> String {
        let data = Data(bytes)
        return data.hexEncodedString()
    }
    
    //Example: 10:2b:3c:55 -> "10:2b:3c:55""
    class func bytesArrayToStringWithSemicolon(bytes:[UInt8]) -> String {
        
        let data = Data(bytes)
        let macString = data.hexEncodedString()
        var macAddress = ""
        var i = 1
        for c in macString {
            macAddress.append(c)
            if (i == 2) {
                macAddress.append(":")
                i = 0
            }
            i = i+1
        }
        macAddress.remove(at: macAddress.index(before: macAddress.endIndex))
        return macAddress
    }
    
    class func bytesArrayToMacAddressWithDot(bytes:[UInt8]) -> String {
        let data = Data(bytes)
        let macString = data.hexEncodedString()
        var macAddress = ""
        var i = 1
        for c in macString {
            macAddress.append(c)
            if (i == 2) {
                macAddress.append(".")
                i = 0
            }
            i = i+1
        }
        macAddress.remove(at: macAddress.index(before: macAddress.endIndex))
        var macArrayWithInt = [String]()
        let array = macAddress.components(separatedBy: ".")
        for hexStr in array {
            macArrayWithInt.append("\(HexConverter.hexStringToInt(hexString: hexStr))")
        }
        let joined = macArrayWithInt.joined(separator: ".")
        return joined
    }
    
    class func bytesArrayToStringWithSpace(bytes:[UInt8]) -> String {
        
        let data = Data(bytes)
        let macString = data.hexEncodedString()
        var macAddress = ""
        var i = 1
        for c in macString {
            macAddress.append(c)
            if (i == 2) {
                macAddress.append(" ")
                i = 0
            }
            i = i+1
        }
        macAddress.remove(at: macAddress.index(before: macAddress.endIndex))
        return macAddress
    }
    
    
    // MARK: HexString ->
    
    //Example: "a" -> 0x10
    class func oneHexStringToByte(hexString:String) -> UInt8? {
        if hexString == "" {
            return nil
        }
        if hexString.count > 1 {
            return nil
        }
        return UInt8(hexString, radix: 16)
    }
    
    //Example: "0xab,0xcd,0x00,ff,0xff,0xab,0xcd" -> [171, 205, 0, 255, 255, 171, 205]
    class func hexStringArrayToBytesArray(hexString:String) -> [UInt8] {
        //let hexString = "0xab,0xcd,0x00,0x01,0xff,0xff,0xab,0xcd"
        // Remove all of the "0x"
        let cleanString = hexString.replacingOccurrences(of: "0x", with: "")
        // Create an array of hex strings
        let hexStringArray = cleanString.components(separatedBy: ",")
        // Convert the array of hex strings into bytes (UInt8)
        let bytesArray = hexStringArray.compactMap { UInt8($0, radix: 16) }
        
        return bytesArray
    }
    
    //Example: "1A3B5C" -> ["1A", "3B", "5C"]
    class func hexStringToStringBytesArray(hexString:String) -> [String] {
        
        var checkHexString = ""
        if hexString.count % 2 != 0 {
            checkHexString = "0" + hexString
        }
        else{
            checkHexString = hexString
        }
        
        var hexStringArray = [String]()
        var byte = ""
        for char in checkHexString {
            byte.append(char)
            if (byte.count == 2) {
                hexStringArray.append(byte)
                byte = ""
            }
        }
        return hexStringArray
    }
    
    //Example: "1A3B5C" -> [0x1A, 0x3B, 0x5C]
    class func hexStringToBytesArray(hexString:String) -> [UInt8] {
        let hexStringArray = HexConverter.hexStringToStringBytesArray(hexString: hexString)
        let bytesArray = hexStringArray.compactMap { UInt8($0, radix: 16) }
        return bytesArray
    }

    //Example: "123ABC" -> [49, 50, 51, 65, 66, 67]
    class func stringToBytesArray(str:String) -> [UInt8] {
        var newString = str.replacingOccurrences(of: ":", with: "")
        newString = str.replacingOccurrences(of: " ", with: "")
        
        let data = newString.data(using: .utf8)!
        let hexString = HexConverter.bytesDataToHexString(data: data)
        var hexStringArray = [String]()
        var byte = ""
        for char in hexString {
            byte.append(char)
            if (byte.count == 2) {
                hexStringArray.append(byte)
                byte = ""
            }
        }
        let bytes = hexStringArray.compactMap { UInt8($0, radix: 16) }
        return bytes
    }
    
    
    class func dataLengthToBytesArray(dataLength:Int, arrayCount:Int) -> [UInt8] {
        
        let hexString = HexConverter.intToHexString(decimal: dataLength)
        let bytesArray = HexConverter.hexStringToBytesArray(hexString: hexString)
        
        var newBytesArray:[UInt8] = bytesArray
        if (arrayCount > bytesArray.count) {
            newBytesArray = bytesArray.reversed()
            let needEmptyBytes = arrayCount - bytesArray.count
            for _ in 1...needEmptyBytes {
                newBytesArray.append(0x00)
            }
            newBytesArray = newBytesArray.reversed()
        }
        
        return newBytesArray

    }
}
