//
//  RemarkInfo.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/9.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import ObjectMapper
class RemarkInfo: Mappable {
    var remarkLevel:String?
    var remarkInfo:String?
    var remarkDate:String?
    required init?(_ map: Map) {
        
    }
    func mapping(map: Map) {
        remarkLevel <- map["remarkLevel"]
        remarkInfo <- map["remarkInfo"]
        remarkDate <- map["remarkDate"]
    }
    func remarkLeverString () ->String {
        switch remarkLevel! {
        case "0": return "满    意"
        case "1": return "一    般"
        case "2": return "不满意"
        default:  return "满    意"
        }
    }
}