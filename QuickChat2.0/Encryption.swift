//
//  Encryption.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 12/11/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation


func EncryptText(chatRoomID: String, string: String) -> String {
    
    let data = string.data(using: String.Encoding.utf8)
    
    let encryptedData = RNCryptor.encrypt(data: data!, withPassword: chatRoomID)
    
    return encryptedData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
}


func DecryptText(chatRoomID: String, string: String) -> String {
    
    let decryptor = RNCryptor.Decryptor(password: chatRoomID)
    
    let encryptedData = NSData(base64Encoded: string, options: NSData.Base64DecodingOptions(rawValue: 0))
    
    var message: NSString = ""
    
    
    do {
        let decryptedData = try decryptor.decrypt(data: encryptedData! as Data)
        
        message = NSString(data: decryptedData, encoding: String.Encoding.utf8.rawValue)!
    } catch {
        
        
        print("Error decoding text: \(error)")
    }
    
    return message as String
}
