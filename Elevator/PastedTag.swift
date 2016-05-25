//
//  PastedTag.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/10.
//  Copyright © 2016年 haoyun. All rights reserved.
//


import Foundation
import ObjectMapper
import Alamofire
import KVNProgress
class PastedTag:NSObject,Mappable {
    var buildingName:String = ""
    var sourceType:Int = 0
    var pasteTotal:Int = 0
    required init?(_ map: Map) {
        
    }
    func mapping(map: Map) {
        buildingName <- map["buildingName"]
        sourceType <- map["sourceType"]
        pasteTotal <- map["pasteTotal"]
    }
    
    override init() {
        super.init()
    }
    static func merge(pastedTags:[PastedTag]) -> [PastedTag] {
        var newAarry:[PastedTag] = []
        for oldPastedTag in pastedTags {
            var isExit = false
            for newPastedTag in newAarry {
                if oldPastedTag.buildingName == newPastedTag.buildingName {
                    newPastedTag.pasteTotal += oldPastedTag.pasteTotal
                    isExit = true
                }
            }
            if !isExit {
                newAarry.append(oldPastedTag)
            }
        }
        return newAarry
    }
}
