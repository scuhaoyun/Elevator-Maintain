//
//  HYDbCheckRecord.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/2.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import SQLite
class HYDbCheckRecord:NSObject {
    let db = try! Connection(Constants.dbPath)
    
    let checkRecordTable = Table("checkRecord")
    
    let id = Expression<Int>("id")
    let pid = Expression<String>("pid")             //任务ID标识，搜索任务时获得，新建时为0
    let address = Expression<String>("address")            //电梯所在地址，如图30所示，该内容不能为空
    let buildingName = Expression<String>("buildingName")       //电梯所在楼盘，如图30所示，该内容不能为空
    let building = Expression<String>("building")           //电梯所在栋，如图30所示
    let unit = Expression<String>("unit")               //电梯所在单元，如图30所示
    let area = Expression<String>("area")              //电梯所在区域，如图30所示
    let useNumber = Expression<String>("useNumber")        //电梯内部编号，如图30所示
    let registCode = Expression<String>("registCode")         //电梯20位注册代码，如图30所示
    let registNumber = Expression<String>("registNumber")       //6位电梯编号，不能为空  
    let shenhe = Expression<String>("shenhe")
    let shenHeState = Expression<String>("shenHeState")
    let shenHeBeiZhu = Expression<String>("shenHeBeiZhu")
    let shenheImgName = Expression<String>("shenheImgName")
    let deviceId2 = Expression<String>("deviceId2")
    let date = Expression<String>("date")
    let isUpload = Expression<Bool>("isUpload")
    let type = Expression<String>("type")
    //创建核查记录表
    override init() {
        super.init()
        self.createCheckRecordTable()
    }
    func createCheckRecordTable() {
        try! db.run(checkRecordTable.create(ifNotExists: true){ t in
            t.column(id, primaryKey: .Autoincrement)
            t.column(pid)
            t.column(registNumber,unique: true)
            t.column(address)
            t.column(buildingName)
            t.column(building)
            t.column(unit)
            t.column(area)
            t.column(useNumber)
            t.column(registCode)
            t.column(shenhe)
            t.column(shenHeState)
            t.column(shenHeBeiZhu)
            t.column(shenheImgName)
            t.column(deviceId2)
            t.column(date)
            t.column(isUpload)
            t.column(type)
        })
    }
    //查询
    func getAllCheckRecord() -> [CheckRecord] {
        return convertToArray(db.prepare(checkRecordTable))
        
    }
    func getCheckRecordForId(rowId:Int) -> [CheckRecord]  {
        let query = checkRecordTable.select(*).filter(id == rowId).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    func getCheckRecordForQR(qrcode:String) -> [CheckRecord]  {
        let query = checkRecordTable.select(*).filter(registNumber == qrcode).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    func getCheckRecordForAddress(addressStr:String,buildingNameStr:String) -> [CheckRecord]  {
        let query = checkRecordTable.select(*).filter(address.like("%\(addressStr)%") && buildingName.like("%\(buildingNameStr)%")).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    func getCheckRecordForType(typeStr:String) -> [CheckRecord]  {
        let query = checkRecordTable.select(*).filter(type == typeStr).order(id.desc)
        return convertToArray(db.prepare(query))
    }
     //插入
    func insert(object:CheckRecord)-> Bool {
        do {
            try db.run(checkRecordTable.insert(
                pid <- object.pid,
                registNumber <- object.registNumber,
                address <- object.address,
                buildingName <- object.buildingName,
                building <- object.building,
                unit <- object.unit,
                area <- object.area,
                useNumber <- object.useNumber,
                registCode <- object.registCode,
                shenhe <- object.shenhe,
                shenHeState <- object.shenHeState,
                shenHeBeiZhu <- object.shenHeBeiZhu,
                shenheImgName <- object.shenheImgName,
                deviceId2 <- object.deviceId2,
                date <- object.date,
                isUpload <- object.isUpload,
                type <- object.type
             ))
            return true
        } catch {
            return false
        }
    }
    //删除
    func deleteRow(rowId:Int)-> Bool {
        do {
            let row = checkRecordTable.filter(id == rowId)
            try db.run(row.delete())
            return true
        } catch {
            return false
        }
    }
    //更新
    func update(object:CheckRecord)-> Bool {
        do {
            let row = checkRecordTable.filter(registNumber == object.registNumber)
            for record in convertToArray(db.prepare(row)) {
                if object.shenheImgName != record.shenheImgName {
                    HYImage.shareInstance.deleteFileForName(record.shenheImgName)
                }
            }
            try db.run(row.update(
                pid <- object.pid,
                registNumber <- object.registNumber,
                address <- object.address,
                buildingName <- object.buildingName,
                building <- object.building,
                unit <- object.unit,
                area <- object.area,
                useNumber <- object.useNumber,
                registCode <- object.registCode,
                shenhe <- object.shenhe,
                shenHeState <- object.shenHeState,
                shenHeBeiZhu <- object.shenHeBeiZhu,
                shenheImgName <- object.shenheImgName,
                deviceId2 <- object.deviceId2,
                date <- object.date,
                isUpload <- object.isUpload,
                type <- object.type
            ))
            return true
        } catch {
            return false
        }
    }
    func convertToArray(rows:AnySequence<Row>) -> [CheckRecord]{
        var checkRecordArray = Array<CheckRecord>()
        for row in rows {
            let checkRecord = CheckRecord()
            checkRecord.id = row[id]
            checkRecord.pid = row[pid]
            checkRecord.registNumber = row[registNumber]
            checkRecord.address = row[address]
            checkRecord.buildingName = row[buildingName]
            checkRecord.building = row[building]
            checkRecord.unit = row[unit]
            checkRecord.area = row[area]
            checkRecord.useNumber = row[useNumber]
            checkRecord.registCode = row[registCode]
            checkRecord.shenhe = row[shenhe]
            checkRecord.shenHeState = row[shenHeState]
            checkRecord.shenHeBeiZhu = row[shenHeBeiZhu]
            checkRecord.shenheImgName = row[shenheImgName]
            checkRecord.deviceId2 = row[deviceId2]
            checkRecord.date = row[date]
            checkRecord.isUpload = row[isUpload]
            checkRecord.type = row[type]
            checkRecordArray.append(checkRecord)
        }
        return checkRecordArray
    }
    
    
}

