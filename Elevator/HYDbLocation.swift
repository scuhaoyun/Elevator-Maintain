//
//  HYDbLocation.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/15.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import SQLite
class HYDbLocation:NSObject {
    let db = try! Connection(Constants.dbPath)
    let locationTable = Table("Location")
    let id = Expression<Int>("id")
    let longitute = Expression<String>("longitute")
    let latitute = Expression<String>("latitute")
    let timestamp = Expression<Double>("timestamp")
    
    override init() {
        super.init()
        self.createLocationTable()
    }
    func createLocationTable() {
        try! db.run(locationTable.create(ifNotExists: true){ t in
            t.column(id, primaryKey: .Autoincrement)
            t.column(longitute)
            t.column(latitute)
            t.column(timestamp)
        })
    }
    //查询
    func getFrontLocation(dateString:String) -> (String,String) {
       let timeInterval = timeIntervalFromDateString(dateString)
       let query = locationTable.select(*).filter(timestamp >= timeInterval).order(timestamp.desc).limit(0, offset: 1)
       let rows = db.prepare(query)
        for row in rows {
            return (row[longitute],row[latitute])
        }
        return ("0","0")
    }
    func getEndLocation(dateString:String) -> (String,String) {
        let timeInterval = timeIntervalFromDateString(dateString)
        let query = locationTable.select(*).filter(timestamp <= timeInterval).order(timestamp.asc).limit(0, offset: 1)
        let rows = db.prepare(query)
        for row in rows {
            return (row[longitute],row[latitute])
        }
        return ("0","0")
    }
    //插入
    func insert(longtituteStr:String,latituteStr:String)-> Bool {
        do {
            try db.run(locationTable.insert(
                longitute <- longtituteStr,
                latitute <- latituteStr,
                timestamp <- NSDate().timeIntervalSince1970
            ))
            return true
        } catch {
            return false
        }
    }
    //删除
    func deleteAll()-> Bool {
        do {
            try db.run(locationTable.delete())
                return true
        } catch {
            return false
        }
    }
    func timeIntervalFromDateString(dateString:String) -> Double {
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = timeFormatter.dateFromString(dateString)
        return date!.timeIntervalSince1970
    }
}


