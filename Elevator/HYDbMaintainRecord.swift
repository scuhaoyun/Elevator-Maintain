//
//  HYDbMaintainRecord.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/11.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import SQLite
class HYDbMaintainRecord:NSObject {
    let db = try! Connection(Constants.dbPath)
    let maintainRecordTable = Table("maintainRecord")
    let id = Expression<Int>("id")
    let twoCodeId = Expression<String>("twoCodeId")
    let ywKind = Expression<String>("ywKind")
    let startTime = Expression<String>("startTime")
    let endTime = Expression<String>("endTime")
    let sPosition = Expression<String>("sPosition")
    let ePosition = Expression<String>("ePosition")
    let maintainTypecode = Expression<String>("maintainTypecode")
    let remark = Expression<String>("remark")
    let threedscanning = Expression<String>("threedscanning")
    let map_X0 = Expression<String>("map_X0")
    let map_Y0 = Expression<String>("map_Y0")
    let map_X1 = Expression<String>("map_X1")
    let map_Y1 = Expression<String>("map_Y1")
    let map_X2 = Expression<String>("map_X2")
    let map_Y2 = Expression<String>("map_Y2")
    let ywstatusFlag = Expression<String>("ywstatusFlag")
    let imgName = Expression<String>("imgName")
    let ywDetail = Expression<String>("ywDetail")
    let isUpload = Expression<Bool>("isUpload")
    let state = Expression<String>("state")
    let type = Expression<String>("type")
    override init() {
        super.init()
        self.createMaintainRecordTable()
    }
    func createMaintainRecordTable() {
        try! db.run(maintainRecordTable.create(ifNotExists: true){ t in
            t.column(id, primaryKey: .Autoincrement)
            t.column(twoCodeId,unique:true)
            t.column(ywKind)
            t.column(startTime)
            t.column(endTime)
            t.column(sPosition)
            t.column(ePosition)
            t.column(maintainTypecode)
            t.column(remark)
            t.column(threedscanning)
            t.column(map_X0)
            t.column(map_Y0)
            t.column(map_X1)
            t.column(map_Y1)
            t.column(map_X2)
            t.column(map_Y2)
            t.column(ywstatusFlag)
            t.column(imgName)
            t.column(ywDetail)
            t.column(isUpload)
            t.column(state)
            t.column(type)
            })
    }
    //查询
    func getAllMaintainRecord() -> [MaintainRecord] {
        return convertToArray(db.prepare(maintainRecordTable))
        
    }
    func getMaintainRecordForId(rowId:Int) -> [MaintainRecord]  {
        let query = maintainRecordTable.select(*).filter(id == rowId).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    func getMaintainRecordForQR(qrcode:String) -> [MaintainRecord]  {
        let query = maintainRecordTable.select(*).filter(twoCodeId == qrcode).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    func getLastMaintainRecordForQR(qrcode:String) -> MaintainRecord? {
        let query = maintainRecordTable.select(*).filter(twoCodeId == qrcode).order(id.desc)
        let array = convertToArray(db.prepare(query))
        if array.count > 0 {
            return array[0]
        }
        return nil
    }
    func getMaintainRecordForStartTime(time:String) -> MaintainRecord? {
        let query = maintainRecordTable.select(*).filter(startTime == time).order(id.desc)
        let array = convertToArray(db.prepare(query))
        if array.count > 0 {
            return array[0]
        }
        return nil
    }
    //插入
    func insert(object:MaintainRecord)-> Bool {
        do {
            try db.run(maintainRecordTable.insert(
                twoCodeId <- object.twoCodeId,
                ywKind <- object.ywKind,
                startTime <- object.startTime,
                endTime <- object.endTime,
                sPosition <- object.sPosition,
                ePosition <- object.ePosition,
                maintainTypecode <- object.maintainTypecode,
                remark <- object.remark,
                threedscanning <- object.threedscanning,
                map_X0 <- object.map_X0,
                map_Y0 <- object.map_Y0,
                map_X1 <- object.map_X1,
                map_Y1 <- object.map_Y1,
                map_X2 <- object.map_X2,
                map_Y2 <- object.map_Y2,
                ywstatusFlag <- object.ywstatusFlag,
                imgName <- object.imgName,
                ywDetail <- object.ywDetail,
                isUpload <- object.isUpload,
                state <- object.state,
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
            let row = maintainRecordTable.filter(id == rowId)
            try db.run(row.delete())
            return true
        } catch {
            return false
        }
    }
    //更新
    func update(object:MaintainRecord)-> Bool {
        if object.isExit {
            do {
                let row = maintainRecordTable.filter(startTime == object.startTime)
                for record in convertToArray(db.prepare(row)) {
                    if object.imgName != record.imgName {
                        HYImage.shareInstance.deleteFileForName(record.imgName)
                    }
                }
                try db.run(row.update(
                    twoCodeId <- object.twoCodeId,
                    ywKind <- object.ywKind,
                    startTime <- object.startTime,
                    endTime <- object.endTime,
                    sPosition <- object.sPosition,
                    ePosition <- object.ePosition,
                    maintainTypecode <- object.maintainTypecode,
                    remark <- object.remark,
                    threedscanning <- object.threedscanning,
                    map_X0 <- object.map_X0,
                    map_Y0 <- object.map_Y0,
                    map_X1 <- object.map_X1,
                    map_Y1 <- object.map_Y1,
                    map_X2 <- object.map_X2,
                    map_Y2 <- object.map_Y2,
                    ywstatusFlag <- object.ywstatusFlag,
                    imgName <- object.imgName,
                    ywDetail <- object.ywDetail,
                    isUpload <- object.isUpload,
                    state <- object.state,
                    type <- object.type
                    ))
                return true
            } catch {
                return false
            }
        }
        else{
            return insert(object)
        }
    }
    func convertToArray(rows:AnySequence<Row>) -> [MaintainRecord]{
        var maintainRecordArray = Array<MaintainRecord>()
        for row in rows {
            let maintainRecord = MaintainRecord()
            maintainRecord.id = row[id]
            maintainRecord.twoCodeId = row[twoCodeId]
            maintainRecord.ywKind = row[ywKind]
            maintainRecord.startTime = row[startTime]
            maintainRecord.endTime = row[endTime]
            maintainRecord.sPosition = row[sPosition]
            maintainRecord.ePosition = row[ePosition]
            maintainRecord.maintainTypecode = row[maintainTypecode]
            maintainRecord.remark = row[remark]
            maintainRecord.threedscanning = row[threedscanning]
            maintainRecord.map_X0 = row[map_X0]
            maintainRecord.map_Y0 = row[map_Y0]
            maintainRecord.map_X1 = row[map_X1]
            maintainRecord.map_Y1 = row[map_Y1]
            maintainRecord.map_X2 = row[map_X2]
            maintainRecord.map_Y2 = row[map_Y2]
            maintainRecord.ywstatusFlag = row[ywstatusFlag]
            maintainRecord.imgName = row[imgName]
            maintainRecord.ywDetail = row[ywDetail]
            maintainRecord.isUpload = row[isUpload]
            maintainRecord.state = row[state]
            maintainRecord.type = row[type]
            maintainRecordArray.append(maintainRecord)
        }
        return maintainRecordArray
    }
}

