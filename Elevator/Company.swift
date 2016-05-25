//
//  Company.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/8.
//  Copyright © 2016年 haoyun. All rights reserved.
//
import AlamofireObjectMapper
import ObjectMapper
class Company: Mappable {
    var companyId:Int?
    var companyName: String?
    var ispasteyw: Int?
    required init?(_ map: Map) {
        
    }
    func mapping(map: Map) {
        companyId <- map["companyId"]
        companyName <- map["companyName"]
        ispasteyw <- map["ispasteyw"]
    }

}
