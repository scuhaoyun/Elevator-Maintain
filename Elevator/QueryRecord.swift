//
//  QueryRecord.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/14.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import SQLite
struct QueryRecord {
    var id:Int?
    var twoCodeId:String = ""  //URL
    var title:String = ""
    var date:String?
    
    init() {
        self.date = Constants.curruntTimeString
    }
    init(title:String,twoCodeId:String){
        self.init()
        self.title = title
        self.twoCodeId = twoCodeId
    }
    //增加记录
    func insertToDb() -> Bool {
       return HYDbQueryRecord().insert(self)
    }
    //删除记录
    func deleteFromDb() -> Bool {
        return HYDbQueryRecord().deleteRow(self.id!)
    }
    //更新记录
    func updateDb() -> Bool {
        return HYDbQueryRecord().update(self)
    }
    //查询
    static func selectAll() -> [QueryRecord]{
        return HYDbQueryRecord().getAllQueryRecord()
    }
    static func select(title:String) -> [QueryRecord] {
        return HYDbQueryRecord().getQueryRecordForTitle(title)
    }
}