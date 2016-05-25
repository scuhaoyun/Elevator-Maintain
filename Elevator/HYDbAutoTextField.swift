//
//  HYDbAutoTextField.swift
//  Elevator
//
//  Created by 郝赟 on 16/4/7.
//  Copyright © 2016年 haoyun. All rights reserved.
//


import Foundation
import SQLite
class HYDbAutoTextField: NSObject {
    let db = try! Connection(Constants.dbPath)
    let textfieldTable = Table("TextField")
    let id = Expression<Int>("id")
    let text = Expression<String>("text")
    let indexStr = Expression<String>("indexStr")
    let timestamp = Expression<Double>("timestamp")
    
    override init() {
        super.init()
        self.createTextFieldTable()
    }
    func createTextFieldTable() {
        try! db.run(textfieldTable.create(ifNotExists: true){ t in
            t.column(id, primaryKey: .Autoincrement)
            t.column(text,unique: true)
            t.column(indexStr)
            t.column(timestamp)
            })
    }
    //根据索引字符串查询出字符串数组，没有排序
    func getStringsForIndexStr(indexString:String) ->[String] {
        let query = textfieldTable.select(text).filter(indexStr == indexString).order(timestamp.desc)
        let rows = db.prepare(query)
        return convertToArray(rows)
    }
    //排序后的数
    func getStringsForIndexStr(indexString:String,andText:String) ->[String] {
        return HYHandler.sortStrings(getStringsForIndexStr(indexString), text: andText)
    }

    //插入
    func insert(textString:String,indexString:String) -> Bool {
        if textString != "" {
            let query = textfieldTable.select(text).filter(indexStr == indexString && text == textString)
            let rows = db.prepare(query)
            if convertToArray(rows).count == 0 {
                do {
                    try db.run(textfieldTable.insert(
                        text <- textString,
                        indexStr <- indexString,
                        timestamp <- NSDate().timeIntervalSince1970
                        ))
                    return true
                } catch {
                    return false
                }
            }
        }
        return false
    }
    //删除
    func deleteAll()-> Bool {
        do {
            try db.run(textfieldTable.delete())
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
    func convertToArray(rows:AnySequence<Row>) -> [String]{
        var textArray = Array<String>()
        for row in rows {
            textArray.append(row[text])
        }
        return textArray
    }
    //
   
}
