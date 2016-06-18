//
//  HYDbTagRecord.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/14.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import SQLite
class HYDbTagRecord:NSObject {
    let db = try! Connection(Constants.dbPath)
    let tagRecordTable = Table("tagRecord")
    
    let pid = Expression<String>("pid")             //任务ID标识，搜索任务时获得，新建时为0
    let userId = Expression<String>("userId")            //用户ID标识
    let role = Expression<String>("role")              //用户角色标识
    let companyId = Expression<String>("companyId")         //公司ID标识
    let registNumber = Expression<String>("registNumber")       //6位电梯编号，不能为空  例：Id=ZYT00E11111010031DC5192C4184D63或者手动输入6位数字
    let address = Expression<String>("address")            //电梯所在地址，如图30所示，该内容不能为空
    let buildingName = Expression<String>("buildingName")       //电梯所在楼盘，如图30所示，该内容不能为空
    let building = Expression<String>("building")           //电梯所在栋，如图30所示
    let unit = Expression<String>("unit")               //电梯所在单元，如图30所示
    let area = Expression<String>("area")              //电梯所在区域，如图30所示
    let useNumber = Expression<String>("useNumber")        //电梯内部编号，如图30所示
    let registCode = Expression<String>("registCode")         //电梯20位注册代码，如图30所示
    let eleStopFlag = Expression<String>("eleStopFlag")         //电梯停用状态，如图30所示 0-在用 1-停用
    let mobileUploadbeizhu = Expression<String>("mobileUploadbeizhu")   //电梯备注信息，如图31所示
    let pasteTime = Expression<String>("pasteTime")            //标签粘帖时间，即记录保存时的时间
    let map_X = Expression<String>("map_X")             //记录保存时，定位到的经度
    let map_Y = Expression<String>("map_Y")             //记录保存时，定位到的纬度
    let imgStr1Name = Expression<String>("imgStr1Name")           //标签远景图片，拍照一张，上传时转换为base64编码的字符串，如图31
    let imgStr2Name = Expression<String>("imgStr2Name") 			//注册合格证图片，拍照一张，上传时转换为base64编码的字符串，
    let imgStr3Name = Expression<String>("imgStr3Name")           //扫描二维码过程中所保存的一张图片，在没有扫描到二维码字符串时需要上传此图片，且转换为base64编码的字符串
    let deviceId2 = Expression<String>("deviceId2")         //绑定宣传画上的二维码编号，和电梯编号类似（6位编号）
    
    let id = Expression<Int>("id")
    let isUpload = Expression<Bool>("isUpload")
    let type = Expression<String>("type")
    let arrangeTime = Expression<String>("arrangeTime")
    //创建查询记录表
    override init() {
        super.init()
        self.createTagRecordTable()
    }
    func createTagRecordTable() {
        try! db.run(tagRecordTable.create(ifNotExists: true){ t in
            t.column(id, primaryKey: .Autoincrement)
            t.column(pid)
            t.column(userId)
            t.column(role)
            t.column(companyId)
            t.column(registNumber,unique: true)
            t.column(address)
            t.column(buildingName)
            t.column(building)
            t.column(unit)
            t.column(area)
            t.column(useNumber)
            t.column(registCode)
            t.column(eleStopFlag)
            t.column(mobileUploadbeizhu)
            t.column(pasteTime)
            t.column(map_X)
            t.column(map_Y)
            t.column(imgStr1Name)
            t.column(imgStr2Name)
            t.column(imgStr3Name)
            t.column(deviceId2)
            t.column(isUpload)
            t.column(type)
            t.column(arrangeTime)
        })
    }
    //查询
    func getAllTagRecord() -> [Tag] {
        return convertToArray(db.prepare(tagRecordTable))
        
    }
    func getTagRecordForId(rowId:Int) -> [Tag]  {
        let query = tagRecordTable.select(*).filter(id == rowId).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    func getTagRecordForType(typeStr:String) -> [Tag]  {
        let query = tagRecordTable.select(*).filter(type == typeStr).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    func getTagRecordForAddress(addressStr:String,buildingNameStr:String,buildingStr:String,unitStr:String) -> [Tag]  {
        let query = tagRecordTable.select(*).filter(address.like("%\(addressStr)%") && buildingName.like("%\(buildingNameStr)%") && building.like("%\(buildingStr)%") && unit.like("%\(unitStr)%")).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    func getTagRecordForRegistNumber(registNumberStr:String) -> [Tag]  {
        let query = tagRecordTable.select(*).filter(registNumber == registNumberStr).order(id.desc)
        return convertToArray(db.prepare(query))
    }
//    //插入
    func insert(object:Tag)-> Bool {
        do {
            try db.run(tagRecordTable.insert(
                pid <- object.pid,
                userId <- object.userId,
                role <- object.role,
                companyId <- object.companyId,
                registNumber <- object.registNumber,
                address <- object.address,
                buildingName <- object.buildingName,
                building <- object.building,
                unit <- object.unit,
                area <- object.area,
                useNumber <- object.useNumber,
                registCode <- object.registCode,
                eleStopFlag <- object.eleStopFlag,
                mobileUploadbeizhu <- object.mobileUploadbeizhu,
                pasteTime <- object.pasteTime,
                map_X <- object.map_X,
                map_Y <- object.map_Y,
                imgStr1Name <- object.imgStr1Name,
                imgStr2Name <- object.imgStr2Name,
                imgStr3Name <- object.imgStr3Name,
                deviceId2 <- object.deviceId2,
                isUpload <- object.isUpload,
                type <- object.type,
                arrangeTime <- object.arrangeTime
            ))
            return true
        } catch {
            return false
        }
    }
    //删除
    func deleteRow(rowId:Int)-> Bool {
        do {
            let row = tagRecordTable.filter(id == rowId)
            try db.run(row.delete())
            return true
        } catch {
            return false
        }
    }
    //更新
    func update(object:Tag)-> Bool {
        if getTagRecordForRegistNumber(object.registNumber).count > 0 {
            do {
                let row = tagRecordTable.filter(registNumber == object.registNumber)
//                for record in convertToArray(db.prepare(row)) {
//                    if object.imgStr1Name != record.imgStr1Name {
//                        HYImage.shareInstance.deleteFileForName(record.imgStr1Name)
//                    }
//                    if object.imgStr2Name != record.imgStr2Name {
//                        HYImage.shareInstance.deleteFileForName(record.imgStr1Name)
//                    }
//                    if object.imgStr3Name != record.imgStr3Name {
//                        HYImage.shareInstance.deleteFileForName(record.imgStr1Name)
//                    }
//                }

                try db.run(row.update( pid <- object.pid,
                    userId <- object.userId,
                    role <- object.role,
                    companyId <- object.companyId,
                    registNumber <- object.registNumber,
                    address <- object.address,
                    buildingName <- object.buildingName,
                    building <- object.building,
                    unit <- object.unit,
                    area <- object.area,
                    useNumber <- object.useNumber,
                    registCode <- object.registCode,
                    eleStopFlag <- object.eleStopFlag,
                    mobileUploadbeizhu <- object.mobileUploadbeizhu,
                    pasteTime <- object.pasteTime,
                    map_X <- object.map_X,
                    map_Y <- object.map_Y,
                    imgStr1Name <- object.imgStr1Name,
                    imgStr2Name <- object.imgStr2Name,
                    imgStr3Name <- object.imgStr3Name,
                    deviceId2 <- object.deviceId2,
                    isUpload <- object.isUpload,
                    type <- object.type,
                    arrangeTime <- object.arrangeTime
              ))
                return true
            } catch {
                return false
            }
        }
        else {
            return insert(object)
        }
    }
    func convertToArray(rows:AnySequence<Row>) -> [Tag]{
        var tagArray = Array<Tag>()
        for row in rows {
            let tag = Tag()
            tag.id = row[id]
            tag.pid = row[pid]
            tag.userId = row[userId]
            tag.role = row[role]
            tag.companyId = row[companyId]
            tag.registNumber = row[registNumber]
            tag.address = row[address]
            tag.buildingName = row[buildingName]
            tag.building = row[building]
            tag.unit = row[unit]
            tag.area = row[area]
            tag.useNumber = row[useNumber]
            tag.registCode = row[registCode]
            tag.eleStopFlag = row[eleStopFlag]
            tag.mobileUploadbeizhu = row[mobileUploadbeizhu]
            tag.pasteTime = row[pasteTime]
            tag.map_X = row[map_X]
            tag.map_Y = row[map_Y]
            tag.imgStr1Name = row[imgStr1Name]
            tag.imgStr2Name = row[imgStr2Name]
            tag.imgStr3Name = row[imgStr3Name]
            tag.deviceId2 = row[deviceId2]
            tag.isUpload = row[isUpload]
            tag.type = row[type]
            tag.arrangeTime = row[arrangeTime]
            tagArray.append(tag)
        }
        return tagArray
    }
    
    
}

