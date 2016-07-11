//
//  URLStrings.swift
//  Elevator
//
//  Created by 郝赟 on 16/5/18.
//  Copyright © 2016年 haoyun. All rights reserved.
//
var baseURLString:String = {
    if let domain = HYDefaults[.applicationAddress], let port = HYDefaults[.applicationPort] {
        return "http://" + domain + ":" + port + "/twoCodemobileweb/sjba/"
    }
    return "http://cddt.zytx-robot.com/twoCodemobileweb/sjba/"
}()
struct URLStrings {
    static var   queryddEleShenHeInfoTcMobile = baseURLString + "queryddEleShenHeInfoTcMobile.do"
    static var   ddEleShenHeInfoUpTcMobile = baseURLString + "ddEleShenHeInfoUpTcMobile.do"
    static var   newqueryddEleShenHeInfoTcMobile = baseURLString + "newqueryddEleShenHeInfoTcMobile.do"
    static var   tcBindAddMobile = baseURLString + "tcBindAddMobile.do"
    static var   ywAddMobile3 = baseURLString + "ywAddMobile3.do"
    static var   remarkAddMobile = baseURLString + "remarkAddMobile.do"
    static var   remarkListMobile = baseURLString + "remarkListMobile.do"
    static var   queryEleInfoMobile1 = baseURLString + "queryEleInfoMobile1.do"
    static var   queryEleInfoMobile = baseURLString + "queryEleInfoMobile.do"
    static var   tcIsValidMobile = baseURLString + "tcIsValidMobile.do"
    static var   addpasteddeinfoMobile = baseURLString + "addpasteddeinfoMobile.do"
    static var   queryddeTaskListMobile = baseURLString + "queryddeTaskListMobile.do"
    static var   newqueryddeTaskListMobile = baseURLString + "newqueryddeTaskListMobile.do"
    static var   queryEleInfoByAddressTcMobile2 = baseURLString + "queryEleInfoByAddressTcMobile2.do"
    static var   queryTaskTotalMobile = baseURLString + "queryTaskTotalMobile.do"
    static var   tcnbdlogin = baseURLString + "tcnbdlogin.do"
}
