//
//  String-extension.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/9.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = self.startIndex.advancedBy(r.endIndex)
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    subscript (index:Int) -> String {
        get {
            return self[index...index]
        }
    }
    mutating func replace(index:Int,withString:String){
        let startIndex = self.startIndex.advancedBy(index)
        let endIndex = self.startIndex.advancedBy(index + 1)
        let range = Range<String.Index>(start: startIndex, end: endIndex)
        self.replaceRange(range, with: withString)
    }
}