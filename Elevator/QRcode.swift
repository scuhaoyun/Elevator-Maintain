//
//  QRcode.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/17.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
struct QRcode {
    var isScan = false
    var QR6String:String = "" {
        didSet {
            if self.QR24String == "" {
                self.QR24String = self.QR6String + "000000000000000000"
            }
        }
    }
    var QR24String:String = "" {
        didSet {
            if self.QR6String == "" {
                self.QR6String = self.QR24String[0 ... 5]
            }
        }
    }

    var QRUrlString:String = "" {
        didSet {
            let startIndex = self.QRUrlString.characters.count - 24
            self.QR24String = self.QRUrlString[startIndex ... startIndex + 23]
            self.QR6String = self.QR24String[0 ... 5]
            isScan = true
        }
    }

}