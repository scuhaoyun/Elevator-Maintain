//
//  BASE64Encoder.swift
//  Elevator
//
//  Created by 郝赟 on 16/7/11.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
class BASE64Encoder: NSObject {
    private static let codec_table:Array<Character> = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P","Q", "R", "S", "T","U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g","h", "i", "j", "k", "l", "m", "n", "o","p", "q", "r", "s", "t","u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6","7", "8", "9","+","/"]
    override init() {
        super.init()
    }
    static func encode(a:Array<UInt8>) -> String {
        let totalBits = a.count * 8
        let nn = totalBits % 6
        var curPos = 0
        var toReturn:String = String()
        while curPos < totalBits {
            let bytePos = curPos / 8
            switch curPos % 8 {
            case 0:
                toReturn.append(codec_table[Int((a[bytePos] & 0xfc) >> 2)])
                break
            case 2:
                toReturn.append(codec_table[Int(a[bytePos] & 0x3f)])
                break
            case 4:
                if (bytePos == a.count - 1) {
                    toReturn.append(codec_table[Int(((a[bytePos] & 0x0f) << 2) & 0x3f)]);
                } else {
                    let pos = (((a[bytePos] & 0x0f) << 2) | ((a[bytePos + 1] & 0xc0) >> 6)) & 0x3f;
                    toReturn.append(codec_table[Int(pos)]);
                }
                break;
            case 6:
                if (bytePos == a.count - 1) {
                    toReturn.append(codec_table[Int(((a[bytePos] & 0x03) << 4) & 0x3f)]);
                } else {
                    let pos = (((a[bytePos] & 0x03) << 4) | ((a[bytePos + 1] & 0xf0) >> 4)) & 0x3f;
                    toReturn.append(codec_table[Int(pos)]);
                }
                break;
            default:
                break;
            }
            curPos += 6;
        }
        if nn == 2 {
            toReturn += "=="
        }
        else if (nn == 4) {
            toReturn += "="
        }
        return toReturn
    }
    static func encode(data:NSData) -> String{
       return encode(Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length)))
    }
    
}