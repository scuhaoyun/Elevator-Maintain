//
//  HYHandler.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/13.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
class HYHandler {
    class func getMaintainItemsContents(maintainType maintainType:String, elevatorType:String) -> HYJSON {
        let queryString = elevatorType + " " + maintainType + "内容"
        for item in Constants.maintainItems.array! {
            if item["name"].string == queryString {
                return item
            }
        }
        return nil
    }
    class func getMaintainItemsRequire(maintainType maintainType:String, elevatorType:String) -> HYJSON {
        let queryString = elevatorType + " " + maintainType + "要求"
        for item in Constants.maintainItems.array! {
            if item["name"].string == queryString {
                return item
            }
        }
        return nil
    }
    //根据输入字符串匹配程度来排序字符串
    class func sortStrings(Strings:[String],text:String)-> [String]{
        var countAarry = Array<Int>(count: Strings.count, repeatedValue: 0)
        var newStrings = Strings
        for (index,itemString) in newStrings.enumerate() {
            for char in text.unicodeScalars {
                if itemString.containsString("\(char)") {
                    countAarry[index] += 1
                }
            }
        }
        //冒泡排序
        for var i = 0; i < newStrings.count - 1; i++ {
            for var j = i + 1; j < newStrings.count; j++ {
                if countAarry[i] < countAarry[j] {
                    let temp = newStrings[i]
                    newStrings[i] = newStrings[j]
                    newStrings[j] = temp
                }
            }
        }
        return newStrings
        
    }

}