//
//  File.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/6.
//  Copyright © 2016年 haoyun. All rights reserved.
//


import SwiftyUserDefaults
extension DefaultsKeys {
    static let username = DefaultsKey<String?>("username")
    static let password = DefaultsKey<String?>("password")
    static let checkInfo = DefaultsKey<Array<String>?>("checkInfo")
    static let tagInfo = DefaultsKey<Array<String>?>("tagInfo")
    static let allTagTaskNum = DefaultsKey<Int?>("allTagTaskNum")
    static let allCheckTaskNum = DefaultsKey<Array<String>?>("allCheckTaskNum")
    static let iMSI = DefaultsKey<String?>("iMSI")
    static let iMEI = DefaultsKey<String?>("iMEI")
}
