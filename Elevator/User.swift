//
//  User.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/24.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import Foundation
import ObjectMapper
var loginUser:User?
var isLogin:Bool = false
class User: Mappable   {
    var binding: Int?
    var message: String?
    var role : Int?
    var taskFlag: String?
    var threedscanning: String?
    var userId: Int?
    var companyList: [Company]?
    var ywcompayId:Int? {
        get {
            if companyList == nil {
                return nil
            }
            else {
                for company in companyList! {
                    if company.ispasteyw! == 1 {
                        return company.companyId
                    }
                }
            }
            return nil
        }
    }
    var account:String?
    private init (){
        
    }
    required init?(_ map: Map) {
        
    }
    func mapping(map: Map) {
        binding <- map["binding"]
        message <- map["message"]
        role <- map["role"]
        taskFlag <- map["taskFlag"]
        threedscanning <- map["threedscanning"]
        userId <- map["userId"]
        companyList <- map["companyList"]
    }
    func checkLogin(viewController: UIViewController) ->Bool{
        var alertMessage:String = ""
        var isSucess = false
        if message != nil {
            switch self.message! {
                //用户名不正确
               case "0": alertMessage = "用户名不正确!"
                //登录成功
               case "1": isSucess = true
                //密码不正确
               case "2": alertMessage = "密码不正确!"
               default : alertMessage = "网络错误，请稍后再试！"
            }
        }
        else {
            alertMessage = "网络错误，请稍后再试！"
        }
        if alertMessage != "" {
            HYProgress.showErrorWithStatus(alertMessage)
        }
        return isSucess
    }
    
}