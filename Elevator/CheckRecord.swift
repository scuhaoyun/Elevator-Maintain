//
//  CheckRecord.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/2.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
class CheckRecord: Mappable {
    var id:Int?
    var pid:String = "0"            //任务ID标识，上传核查数据时回传此信息
    var address:String = ""         //电梯所在地址
    var buildingName:String = ""   //电梯所在楼盘
    var building:String = ""        //电梯所在栋
    var unit:String = ""            //电梯所在单元
    var area:String = ""           //电梯所在区域
    var useNumber:String = ""     //电梯内部编号
    var registCode:String = ""     //电梯20位注册代码
    var registNumber:String = ""    //电梯6位编号
    var shenhe:String = "0"          //该电梯是否已经被核查过：1-已审核 0-未处理
    var shenHeState:String = "000000000"       //核查信息状态，为101100000九位数字字符串,按照：电梯编号-注册代码-地址-楼盘-栋-单元-内部编号-区域-停用状态的顺序组合成的字符串，其中1代表该项有错误，0代表无错误；现在只对电梯编号、地址、楼盘、区域进行核查，其它默认为0
    var shenHeBeiZhu:String = ""     //核查备注，有错误项此内容不能为空
    var shenheImgName:String = ""      //拍摄的近景图片，也可能是扫描二维码记录的编号图片；不能为空；上传时转换为base64编码的字符串
    var deviceId2:String = ""
    var date:String = Constants.curruntTimeString
    var isUpload:Bool = false
    var type:String = "缓存"
    var isExit:Bool {
        get {
            if CheckRecord.selectForQR(self.registNumber).count > 0 {
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
        pid <- map["pid"]
        address <- map["address"]
        buildingName <- map["buildingName"]
        building <- map["building"]
        unit <- map["unit"]
        area <- map["area"]
        useNumber <- map["useNumber"]
        registCode <- map["registCode"]
        registNumber <- map["registNumber"]
        shenhe <- map["shenhe"]
    }

    init() {
        
    }
    convenience init(registNumber:String){
        self.init()
        self.registNumber = registNumber
    }
    //增加记录
    func insertToDb() -> Bool {
        return HYDbCheckRecord().insert(self)
    }
    //删除记录
    func deleteFromDb() -> Bool {
        HYImage.shareInstance.deleteFileForName(self.shenheImgName)
        return HYDbCheckRecord().deleteRow(self.id!)
    }
    //更新记录
    func updateDb() -> Bool {
        if self.isCheckRecordExit() {
            return HYDbCheckRecord().update(self)
        }
        else {
            return HYDbCheckRecord().insert(self)
        }
        
    }
    //查询
    static func selectAll() -> [CheckRecord]{
        return HYDbCheckRecord().getAllCheckRecord()
    }
    static func selectForQR(qrcode:String) -> [CheckRecord]{
        return HYDbCheckRecord().getCheckRecordForQR(qrcode)
    }
    static func selectForType(type:String) -> [CheckRecord]{
        return HYDbCheckRecord().getCheckRecordForType(type)
    }
    static func selectForAdress(address:String,buildingName:String) -> [CheckRecord]{
        return HYDbCheckRecord().getCheckRecordForAddress(address, buildingNameStr: buildingName)
    }
    //判断是否异常
    func isNormal() -> Bool {
        var isNormal = true
        for index in 0 ... self.shenHeState.characters.count - 1 {
            if self.shenHeState[index ... index] == "1" {
                isNormal = false
                return isNormal
            }
        }
        return isNormal
    }
    func isCheckRecordExit() -> Bool {
        let result = HYDbCheckRecord().getCheckRecordForQR(self.registNumber)
        if result.count > 0 {
            return true
        }
        return false
    }
    //上传标签信息
    func uploadToServer(sender:UIViewController){
        if HYNetwork.isConnectToNetwork(sender) {
            guard  loginUser != nil else {
                HYProgress.showErrorWithStatus("您未登录，请先登录！")
                return
            }
            let image = HYImage.shareInstance.getImageForName(self.shenheImgName)
            let shenheImageStr:String = HYImage.get64encodingStr(image)
            let shenhefileLen = shenheImageStr.characters.count
            
            guard shenheImageStr != ""   else {
                HYProgress.showErrorWithStatus("未拍摄近景图片，请重新拍摄！")
                return
            }
            HYProgress.showWithStatus("正在上传，请稍后！")
            Alamofire.request(.POST, "http://cddt.zytx-robot.com/twoCodemobileweb/sjba/ddEleShenHeInfoUpTcMobile.do", parameters: [
                "pid":self.pid,
                "userId":"\(loginUser!.userId!)",
                "role":"\(loginUser!.role!)",
                "companyId":"\(loginUser!.companyList![0].companyId!)",
                "registNumber":self.registNumber,
                "shenHeState":self.shenHeState,
                "shenHeBeiZhu":self.shenHeBeiZhu,
                "shenheImgStr":shenheImageStr,
                "shenhefileLen":shenhefileLen,
                "deviceId2":self.deviceId2,
                ]).responseJSON { response in
                    HYProgress.dismiss()
                    print(response.request?.description)
                    if response.result.value != nil {
                        switch (response.result.value! as! Int){
                        case 1 :
                            HYProgress.showSuccessWithStatus("上传成功！")
                            self.isUpload = true
                            self.updateDb()
                            (sender as! CheckRecordViewController) .checkRecordDatas = CheckRecord.selectForType("记录")
                        case 3 :
                            HYProgress.showErrorWithStatus("上传失败,该电梯编号不存在!")
                        case 0 :
                            HYProgress.showErrorWithStatus("上传失败，请检查信息后重试!")
                        default :
                            HYProgress.showErrorWithStatus("服务器出错，请联系工作人员!")
                        }
                    }
                    else{
                        print(response.result.error?.description)
                        HYProgress.showErrorWithStatus("网络错误或该条记录有误!")
                    }
            }
        }
    }

}
