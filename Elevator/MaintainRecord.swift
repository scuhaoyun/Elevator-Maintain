//
//  MaintainRecord.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/11.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import KVNProgress
class MaintainRecord :NSObject,SwiftAlertViewDelegate {
    var id:Int?
    var twoCodeId:String = ""
    var userId:Int = -1
    var ywKind:String = "0"
    var startTime:String = ""
    var endTime:String = ""
    var sPosition:String = ""
    var ePosition:String = ""
    var maintainTypecode:String = "0"
    var remark:String = ""
    var threedscanning:String = ""
    var map_X0:String = "0"
    var map_Y0:String = "0"
    var map_X1:String = "0"
    var map_Y1:String = "0"
    var map_X2:String = "0"
    var map_Y2:String = "0"
    var ywstatusFlag:String = "0"
    var imgName:String = ""
    var ywDetail:String = ""
    var isUpload:Bool = false  //是否上传
    var state:String = "未完成"      //状态
    var type:String = "0"
    var isExit:Bool {
        get {
            if MaintainRecord.selectForTwoCodeId(self.twoCodeId).count > 0 {
                return true
            }
            else {
                return false
            }
        }
    }
    var isScan:Bool {
        get {
            if self.twoCodeId[8...23] == "0000000000000000" {
                return true
            }
            else {
                return false
            }
        }
    }

    override init() {
        super.init()
    }
    func lastMaintainRecord() -> MaintainRecord? {
        var qrStr1 = self.twoCodeId
        qrStr1.replace(7, withString: "0")
        let maintainRecord0 = HYDbMaintainRecord().getLastMaintainRecordForQR(qrStr1)
        qrStr1.replace(7, withString: "1")
        let maintainRecord1 = HYDbMaintainRecord().getLastMaintainRecordForQR(qrStr1)
        if maintainRecord0 != nil && maintainRecord1 != nil {
            if maintainRecord0!.id > maintainRecord1!.id {
                return maintainRecord0
            }
            else {
                return maintainRecord1
            }
        }
        else if maintainRecord0 != nil {
            return maintainRecord0
        }
        else {
            return maintainRecord1
        }
    }
    //增加记录
    func insertToDb() -> Bool {
        return HYDbMaintainRecord().insert(self)
    }
    //删除记录
    func deleteFromDb() -> Bool {
        HYImage.shareInstance.deleteFileForName(self.imgName)
        return HYDbMaintainRecord().deleteRow(self.id!)
    }
    //更新记录
    func updateDb() -> Bool {
        return HYDbMaintainRecord().update(self)
    }
    //查询
    static func selectAll() -> [MaintainRecord]{
        return HYDbMaintainRecord().getAllMaintainRecord()
    }
    static func selectForId(id:Int) -> [MaintainRecord] {
        return HYDbMaintainRecord().getMaintainRecordForId(id)
    }
    static func selectForStartTime(time:String) -> MaintainRecord? {
        return HYDbMaintainRecord().getMaintainRecordForStartTime(time)
    }
    static func selectForTwoCodeId(twoCodeId:String) -> [MaintainRecord]{
        let maintainRecord = HYDbMaintainRecord().getMaintainRecordForQR(twoCodeId)
        if maintainRecord.count > 0 {
            return maintainRecord
        }
        var qrStr1 = twoCodeId
        qrStr1.replace(7, withString: "0")
        let maintainRecord0 = HYDbMaintainRecord().getMaintainRecordForQR(qrStr1)
        if maintainRecord0.count > 0 {
            return maintainRecord0
        }
        qrStr1.replace(7, withString: "1")
        let maintainRecord1 = HYDbMaintainRecord().getMaintainRecordForQR(qrStr1)
        return maintainRecord1
    }
    func setMaintainTypeCodeForTitle(title:String) {
        switch title {
            case "半月保": self.maintainTypecode = "0"
            case "季度保": self.maintainTypecode = "1"
            case "半年保": self.maintainTypecode = "2"
            case "年保": self.maintainTypecode = "3"
            default:fatalError()
        }
    }
    func getTitleForMaintainTypeCode()-> String? {
        switch self.maintainTypecode {
            case "0": return "半月保"
            case "1": return "季度保"
            case "2": return "半年保"
            case "3": return "年保"
            default:return nil
        }
    }
    func setElevatorTypeForTitle(title:String) {
        switch title {
            case "客梯/货梯": self.type = "0"
            case "扶梯": self.type = "1"
            default:fatalError()
        }
    }
    func getTitleForElevatorType()-> String? {
        switch self.type {
            case "0": return "客梯/货梯"
            case "1": return "扶梯"
            default: return nil
        }
    }
    func uploadToServer(sender:UIViewController) {
        if HYNetwork.isConnectToNetwork(sender) {
            guard  loginUser != nil else {
                HYProgress.showErrorWithStatus("您未登录，请先登录！")
                return
            }
            HYProgress.showWithStatus("正在上传，请稍后！")
            Alamofire.request(.GET, URLStrings.tcBindInfoMobile, parameters: [
                "account":loginUser!.account!
                ]).responseJSON { response in
                    HYProgress.dismiss()
                    if response.result.value != nil {
                        let iMSI = HYJSON(response.result.value!)["iMSI"].string!
                        let iMEI = HYJSON(response.result.value!)["iMEI"].string!
                        //let binding = HYJSON(response.result.value!)["binding"].string!
                        let sysTime = HYJSON(response.result.value!)["sysTime"].string!
                        let timeDistance = HYHandler.getDateDistance(self.endTime, bigDateString: sysTime)!
                        if iMSI == Constants.iMSI && iMEI == Constants.iMEI {
                            if -3600 >  timeDistance  {
                                HYProgress.showErrorWithStatus("该条数据时间有误，不能上传!")
                            }
                            else if timeDistance > 15 * 24 * 3600{
                                HYProgress.showErrorWithStatus("该条数据过期，不能上传!")
                            }
                            else {
                                self.upload(sender)
                            }
                        }
                        else {
                            HYProgress.showErrorWithStatus("手机绑定信息有误!")
                        }
                    }
                    else{
                        HYProgress.showErrorWithStatus("网络错误或该条记录有误!")
                    }
            }
            
        }

    }
    //上传运维信息
    func upload(sender:UIViewController) {
        let image = HYImage.shareInstance.getImageForName(self.imgName)
        let imgStr:String = HYImage.get64encodingStr(image)
        let fileLen = imgStr.characters.count
        let maintainTypeString = self.getTitleForMaintainTypeCode()!
        let location = HYDbLocation()
        (self.map_X0,self.map_Y0) = location.getFrontLocation(self.startTime)
        (self.map_X1,self.map_Y1) = location.getEndLocation(self.startTime)
        (self.map_X2,self.map_Y2) = location.getFrontLocation(self.endTime)
        
        Alamofire.request(.POST, URLStrings.ywAddMobile3, parameters: [
            "twoCodeId":self.twoCodeId,
            "userId":"\(loginUser!.userId!)",
            "ywKind":self.ywKind,
            "startTime":self.startTime,
            "endTime":self.endTime,
            "sPosition":self.sPosition,
            "ePosition":self.ePosition,
            "maintainTypecode":maintainTypeString,
            "remark":self.remark,
            "threedscanning":self.threedscanning,
            "map_X0":self.map_X0,
            "map_Y0":self.map_Y0,
            "map_X1":self.map_X1,
            "map_Y1":self.map_Y1,
            "map_X2":self.map_X2,
            "map_Y2":self.map_Y2,
            "ywstatusFlag":self.ywstatusFlag,
            "imgStr":imgStr,
            "fileLen":fileLen,
            "ywDetail":self.ywDetail
            ]).responseJSON { response in
                if response.result.value != nil {
                    if self.ywstatusFlag != "1" {
                        if self.isLocationCorrect(HYJSON(response.result.value!)["map_X"].double!, map_Y: HYJSON(response.result.value!)["map_Y"].double!) {
                            self.ywstatusFlag = "1"
                        }
                    }
                    switch (HYJSON(response.result.value!)["message"].string!){
                    case "1" :
                        if self.isScan && self.ywstatusFlag == "1"{
                            self.state = "通过"
                        }
                        else {
                            self.state = "审核中"
                        }
                        HYProgress.showSuccessWithStatus("上传成功！")
                        self.isUpload = true
                        self.updateDb()
                        (sender as! MaintainRecordViewController) .maintainRecords = MaintainRecord.selectAll()
                    case "2" :
                        if self.isScan {
                            HYProgress.showErrorWithStatus("上传失败,该电梯不属于你公司运维!")
                        }
                        else{
                           self.state = "审核中"
                        }
                        
                    case "3" :
                        HYProgress.showErrorWithStatus("上传失败,手机未绑定!")
                    case "4" :
                        self.isUpload = true;
                        self.state = "补数据"
                        self.updateDb()
                        (sender as! MaintainRecordViewController) .maintainRecords = MaintainRecord.selectAll()
                        HYProgress.showErrorWithStatus("上传失败,电梯标签未注册!")
                    default :
                        HYProgress.showErrorWithStatus("未知错误!")
                    }
                }
                else{
                    HYProgress.showErrorWithStatus("网络错误或该条记录有误!")
                }
        }
    }
    //查询电梯状态
    func queryEleInfo(sender:UIViewController){
        if HYNetwork.isConnectToNetwork(sender) {
            HYProgress.showWithStatus("正在查询，请稍后！")
            Alamofire.request(.POST, URLStrings.tcqueryEleinfoMobile, parameters: [
                "twoCodeId":self.twoCodeId]).responseJSON { response in
                    HYProgress.dismiss()
                    if response.result.value != nil {
                        if HYJSON(response.result.value!)["eleisvalid"].int! == 1 {
                            self.state = "通过";
                            self.updateDb()
                            (sender as! MaintainRecordViewController) .maintainRecords = MaintainRecord.selectAll()
                        }
                    }
            }
        }

    }
    //更新审核状态
    func updateState(sender:UIViewController){
        let alertController = UIAlertController(title: "温馨提示", message: "确定要更新状态吗？", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            if HYNetwork.isConnectToNetwork(sender) {
                HYProgress.showWithStatus("正在查询，请稍后！")
                Alamofire.request(.POST, URLStrings.tcqueryEleinfoMobile, parameters: [
                    "twoCodeId":self.twoCodeId,"startTime":self.startTime]).responseJSON { response in
                        HYProgress.dismiss()
                        if response.result.value != nil {
                            var newState = self.state
                            switch HYJSON(response.result.value!)["Ywstatus"].int! {
                            case 1:
                                newState = "通过"
                            case 4:
                                newState = "无效"
                            case 0:
                                newState = "审核中"
                            case 5:
                                newState = "无权运维"
                            default:break
                            }
                            if newState != self.state {
                                self.state = newState;
                                self.updateDb()
                                (sender as! MaintainRecordViewController) .maintainRecords = MaintainRecord.selectAll()
                            }
                            HYProgress.showSuccessWithStatus("当前运维状态为: \(newState)")
                        }
                }
            }

            
        })
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        sender.presentViewController(alertController, animated: true, completion: nil)
        
    }
    func ywDetailToTuple() -> (Int,String,Array<String>)? {
        var array = self.ywDetail.componentsSeparatedByString("&")
        if array.count > 1 {
            let length = Int(array[0].componentsSeparatedByString("=")[1])
            let type = array[1].componentsSeparatedByString("=")[1]
            array.removeFirst()
            array.removeFirst()
            return (length!,type,array)
        }
        return nil
    }
    func setywDetail(listLength:Int,type:String) {
        self.ywDetail = "N=\(listLength)&T=\(type)"
    }
    func updateywDetailForIndex(index:Int,withStr:String) {
        var isExit = false
        if let (length,type,array) = ywDetailToTuple() {
            var newArray = array
            for var i = 0;i < newArray.count; i += 1 {
                let rowIndex = Int(newArray[i].componentsSeparatedByString("=")[0])
                let content = newArray[i].componentsSeparatedByString("=")[1]
                if rowIndex == index {
                    newArray[i] = "\(index)=\(content)"
                    isExit = true
                }
            }
            if !isExit {
                 newArray.append("\(index)=\(withStr)")
            }
            self.ywDetail = "N=\(length)&T=\(type)"
            for item in newArray {
                self.ywDetail += "&\(item)"
            }
        }
    }
    func getywDetailForIndex(index:Int) -> String? {
        if let (_,_,array) = ywDetailToTuple() {
            for record in array {
                let rowIndex = Int(record.componentsSeparatedByString("=")[0])
                let content = record.componentsSeparatedByString("=")[1]
                if rowIndex == index {
                    return content
                }
            }
        }
        return nil
    }
    func isLocationCorrect(map_X:Double,map_Y:Double)-> Bool {
        let distance0 = Location.getDistance(map_X, lat1: map_Y, long2: Double(map_X0)!, lat2: Double(map_Y0)!)
        let distance1 = Location.getDistance(map_X, lat1: map_Y, long2: Double(map_X1)!, lat2: Double(map_Y1)!)
        let distance2 = Location.getDistance(map_X, lat1: map_Y, long2: Double(map_X2)!, lat2: Double(map_Y2)!)
        return distance0 < 500 && distance1 < 500 && distance2 < 500
    }
}