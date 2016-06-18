//
//  Tag.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/13.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import KVNProgress
class Tag:NSObject,Mappable,SwiftAlertViewDelegate {
    var pid:String = "0"             //任务ID标识，搜索任务时获得，新建时为0
    var userId:String = ""            //用户ID标识
    var role:String = ""             //用户角色标识
    var companyId:String = ""         //公司ID标识
    var registNumber:String = ""       //6位电梯编号，不能为空  例：Id=ZYT00E11111010031DC5192C4184D63或者手动输入6位数字
    var address:String = ""            //电梯所在地址，如图30所示，该内容不能为空
    var buildingName:String = ""       //电梯所在楼盘，如图30所示，该内容不能为空
    var building:String = ""           //电梯所在栋，如图30所示
    var unit:String = ""               //电梯所在单元，如图30所示
    var area:String = ""              //电梯所在区域，如图30所示
    var useNumber:String = ""        //电梯内部编号，如图30所示
    var registCode:String = ""         //电梯20位注册代码，如图30所示
    var eleStopFlag:String = ""         //电梯停用状态，如图30所示 0-在用 1-停用
    var mobileUploadbeizhu:String = ""   //电梯备注信息，如图31所示
    var pasteTime:String = ""            //标签粘帖时间，即记录保存时的时间
    var map_X:String = ""             //记录保存时，定位到的经度
    var map_Y:String = ""             //记录保存时，定位到的纬度
    var imgStr1Name:String = ""           //标签远景图片，拍照一张，上传时转换为base64编码的字符串，如图31
    var imgStr2Name:String = "" 			//注册合格证图片，拍照一张，上传时转换为base64编码的字符串，
    var imgStr3Name:String = ""           //扫描二维码过程中所保存的一张图片，在没有扫描到二维码字符串时需要上传此图片，且转换为base64编码的字符串
    var deviceId2:String = ""         //绑定宣传画上的二维码编号，和电梯编号类似（6位编号）
    
    var id:Int?
    var isUpload:Bool = false
    var type:String = "缓存"
    var arrangeTime:String = "0000.0.0 00.0.0"
    var isExit:Bool {
        get {
            if Tag.selectForRegistNumber(self.registNumber).count > 0 {
                return true
            }
            else {
                return false
            }
        }
    }


    required init?(_ map: Map) {
        
    }
    func mapping(map: Map) {
        pid <- map["id"]
        address <- map["address"]
        buildingName <- map["buildingName"]
        building <- map["building"]
        unit <- map["unit"]
        area <- map["area"]
        useNumber <- map["useNumber"]
        registCode <- map["registCode"]
        arrangeTime <- map["arrangeTime"]
    }
   
    override init() {
        super.init()
        self.pasteTime = Constants.curruntTimeString
        self.map_X = Location.shareInstance.currentLocationX
        self.map_Y = Location.shareInstance.currentLocationY
    }
    //增加记录
    func insertToDb() -> Bool {
        return HYDbTagRecord().insert(self)
    }
    //删除记录
    func deleteFromDb() -> Bool {
        HYImage.shareInstance.deleteFileForName(self.imgStr1Name)
        HYImage.shareInstance.deleteFileForName(self.imgStr2Name)
        HYImage.shareInstance.deleteFileForName(self.imgStr3Name)
        return HYDbTagRecord().deleteRow(self.id!)
    }
    //更新记录
    func updateDb() -> Bool {
        return HYDbTagRecord().update(self)
    }
    //查询
    static func selectAll() -> [Tag]{
        return HYDbTagRecord().getAllTagRecord()
    }
    static func selectForId(id:Int) -> [Tag] {
        return HYDbTagRecord().getTagRecordForId(id)
    }
    static func selectForType(type:String) -> [Tag]{
        return HYDbTagRecord().getTagRecordForType(type)
    }
    static func selectForRegistNumber(registNumber:String) -> [Tag]{
        return HYDbTagRecord().getTagRecordForRegistNumber(registNumber)
    }
    static func selectForAdress(address:String,buildingName:String,building:String,unit:String) -> [Tag]{
        return HYDbTagRecord().getTagRecordForAddress(address, buildingNameStr: buildingName,buildingStr: building,unitStr:unit)
    }

    //上传标签信息
    func uploadToServer(sender:UIViewController) {
        if HYNetwork.isConnectToNetwork(sender) {
            guard  loginUser != nil else {
                HYProgress.showErrorWithStatus("您未登录，不能请先登录！")
                return
            }
            guard loginUser!.companyList!.count > 0 else {
                HYProgress.showErrorWithStatus("您不属于任何公司，不能进行此操作！")
                return
            }
            let image1 = HYImage.shareInstance.getImageForName(self.imgStr1Name)
            let imgStr1:String = HYImage.get64encodingStr(image1)
            let fileLen1 = imgStr1.characters.count
            
            let image2 = HYImage.shareInstance.getImageForName(self.imgStr2Name)
            let imgStr2:String = HYImage.get64encodingStr(image2)
            let fileLen2 = imgStr2.characters.count
            
            let image3 = HYImage.shareInstance.getImageForName(self.imgStr3Name)
            let imgStr3:String = HYImage.get64encodingStr(image3)
            let fileLen3 = imgStr3.characters.count
            guard imgStr1 != "" && imgStr2 != "" else {
                HYProgress.showErrorWithStatus("图片不存在或已被删除，请重新拍摄！")
                return
            }
            HYProgress.showWithStatus("正在上传，请稍后！")
            Alamofire.request(.POST, "http://cddt.zytx-robot.com/twoCodemobileweb/sjba/addpasteddeinfoMobile.do", parameters: [
                "pid":self.pid,
                "userId":"\(loginUser!.userId!)",
                "role":"\(loginUser!.role!)",
                "companyId":"\(loginUser!.companyList![0].companyId!)",
                "registNumber":self.registNumber,
                "address":self.address,
                "buildingName":self.buildingName,
                "building":self.building,
                "unit":self.unit,
                "area":self.area,
                "useNumber":self.useNumber,
                "registCode":self.registCode,
                "eleStopFlag":self.eleStopFlag,
                "mobileUploadbeizhu":self.mobileUploadbeizhu,
                "pasteTime":self.pasteTime,
                "map_X":self.map_X,
                "map_Y":self.map_Y,
                "imgStr1":imgStr1,
                "fileLen1":fileLen1,
                "imgStr2":imgStr2,
                "fileLen2":fileLen2,
                "imgStr3":imgStr3,
                "fileLen3":fileLen3,
                "deviceId2":self.deviceId2,
                ]).responseJSON { response in
                    HYProgress.dismiss()
                    if response.result.value != nil {
                        switch (response.result.value! as! Int){
                            case 1 :
                                HYProgress.showSuccessWithStatus("上传成功！")
                                self.isUpload = true
                                self.updateDb()
                                (sender as! TagRecordViewController).tagDatas = Tag.selectForType("记录")
                            case 2 :
                                HYProgress.showErrorWithStatus("上传失败,已存在相同地理位置的记录!")
                            case 3 :
                                HYProgress.showErrorWithStatus("上传失败,已存在相同电梯编号的记录!")
                            case 4 :
                                HYProgress.showErrorWithStatus("上传失败,已存在相同注册代码的记录!")
                            case 5 :
                                HYProgress.showErrorWithStatus("上传失败,该任务已上传过!")
                            case 0 :
                                HYProgress.showErrorWithStatus("上传失败，请检查信息后重试!")
                            default :
                                HYProgress.showErrorWithStatus("服务器出错，请联系工作人员!")
                        }
                    }
                    else{
                        HYProgress.showErrorWithStatus("网络错误或该条记录有误!")
                    }
                }
            }
        }
    
}