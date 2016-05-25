//
//  Elevator.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/9.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import ObjectMapper
class ElevatorInfo: Mappable {
    var device_id:String?
    var fix_Addr:String?     //电梯安装地址
    var ver:String?
    var maintenUnit:String?
    var mainteTelephone:String?
    var inspectionUnit:String?     //检验单位
    var useNumber:String?           //使用编号
    var inspector:String?          //检验人员
    var nextInspectDate:String? //下次检验日期
    var subTime:String?
    var ywKind:String?
    required init?(_ map: Map) {
        
    }
    func mapping(map: Map) {
        device_id <- map["device_id"]
        fix_Addr <- map["fix_Addr"]
        ver <- map["ver"]
        maintenUnit <- map["maintenUnit"]
        mainteTelephone <- map["mainteTelephone"]
        inspectionUnit <- map["inspectionUnit"]
        useNumber <- map["useNumber"]
        inspector <- map["inspector"]
        nextInspectDate <- map["nextInspectDate"]
        subTime <- map["subTime"]
        ywKind <- map["ywKind"]
    }
    
}