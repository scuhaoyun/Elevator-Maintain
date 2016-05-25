//
//  HYDatabase.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/10.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import SQLite
class HYDbQueryRecord:NSObject {
    let db = try! Connection(Constants.dbPath)
    let queryRecordTable = Table("queryRecord")
    let id = Expression<Int>("id")
    let twoCodeId = Expression<String>("twoCodeId")  //URL
    let title = Expression<String>("title")
    let date = Expression<String>("date")
    //创建查询记录表
    override init() {
        super.init()
        self.createQueryRecordTable()
    }
    func createQueryRecordTable() {
        try! db.run(queryRecordTable.create(ifNotExists: true){ t in
            t.column(id, primaryKey: .Autoincrement)
            t.column(twoCodeId, unique: true)
            t.column(title)
            t.column(date)
        })
    }
    //查询
    func getAllQueryRecord() -> [QueryRecord] {
         return convertToArray(db.prepare(queryRecordTable))
    }
    func getQueryRecordForTitle(titleString:String) -> [QueryRecord]  {
        let query = queryRecordTable.select(*).filter(title.like("%\(titleString)%")).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    func getQueryRecordForTwoCodeId(twoCodeIdStr:String) -> [QueryRecord]{
        let query = queryRecordTable.select(*).filter(twoCodeId == twoCodeIdStr).order(id.desc)
        return convertToArray(db.prepare(query))
    }
    //插入
    func insert(object:QueryRecord)-> Bool {
        do {
            try db.run(queryRecordTable.insert(twoCodeId <- object.twoCodeId,title <- object.title,date <- object.date!))
            return true
        } catch {
            return false
        }
    }
    //删除
    func deleteRow(rowId:Int)-> Bool {
        do {
            let row = queryRecordTable.filter(id == rowId)
            try db.run(row.delete())
            return true
        } catch {
            return false
        }
    }
    //更新
    func update(object:QueryRecord)-> Bool {
        if getQueryRecordForTwoCodeId(object.twoCodeId).count > 0 {
            do {
                let row = queryRecordTable.filter(twoCodeId == object.twoCodeId)
                try db.run(row.update(twoCodeId <- object.twoCodeId,title <- object.title,date <- object.date!))
                return true
            } catch {
                return false
            }

        }
        else {
            return insert(object)
        }
    }
    func convertToArray(rows:AnySequence<Row>) -> [QueryRecord]{
        var queryRecordArray = Array<QueryRecord>()
        for row in rows {
            var queryRecord = QueryRecord()
            queryRecord.id = row[id]
            queryRecord.title = row[title]
            queryRecord.twoCodeId = row[twoCodeId]
            queryRecord.date = row[date]
            queryRecordArray.append(queryRecord)
        }
        return queryRecordArray
    }

    
}
