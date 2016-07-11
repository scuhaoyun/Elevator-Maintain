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
    static let  applicationAddress = DefaultsKey<String?>("applicationAddress")
    static let  applicationPort = DefaultsKey<String?>("applicationPort")
    static let  severAddress = DefaultsKey<String?>("severAddress")
    static let  serverPort = DefaultsKey<String?>("serverPort")
    static let  deviceAddress = DefaultsKey<String?>("deviceAddress")
    static let  devicePort = DefaultsKey<String?>("")
    static let  mediaAddress = DefaultsKey<String?>("devicePort")
    static let  mediaPort = DefaultsKey<String?>("mediaPort")
    static let  noticeAddress = DefaultsKey<String?>("")
    static let  noticePort = DefaultsKey<String?>("noticeAddress")
    static let  blackBtn = DefaultsKey<Bool?>("blackBtn")
    static let  autoUploadBtn = DefaultsKey<Bool?>("autoUploadBtn")
    static let  receiveBtn = DefaultsKey<Bool?>("receiveBtn")
}
