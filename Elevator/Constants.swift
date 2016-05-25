//
//  Constants.swift
//  Database
//
//  Created by ZERO. on 15/3/19.
//  Copyright (c) 2015年 ZERO. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import CoreLocation
import CoreTelephony
class Constants {
    class var dbPath: String {
        get {
            let fileManager = NSFileManager.defaultManager()
            let documentPath: String = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]).stringByAppendingString("/elevator.database")
            let exist = fileManager.fileExistsAtPath(documentPath)
            if exist == false {
              try! fileManager.createDirectoryAtPath(documentPath, withIntermediateDirectories: true, attributes: nil)
            }
            let path = documentPath.stringByAppendingString("/db.sqlite3")
            print(path)
            return path
        }
    }
    class var maintainItems:JSON {
        get {
            let path = NSBundle.mainBundle().pathForResource("maintain", ofType: "json")
            let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: path!)!, options: NSJSONReadingOptions.AllowFragments)
            return JSON(json!)["string-array"]
        }
    }
    
    class var curruntTimeString:String {
        get {
            let date = NSDate()
            let timeFormatter = NSDateFormatter()
            timeFormatter.dateFormat = "yyy-MM-dd HH:mm"
            let curruntTimeString = timeFormatter.stringFromDate(date) as String
            return curruntTimeString
        }
    }
    class var alertViewWidth:CGFloat {
        get {
            return UIScreen.mainScreen().bounds.size.width - 20
        }
    }
    class var iMSI:String {
        get {
            var iMSIString =  HYDefaults[.iMSI]
            if iMSIString == nil {
                iMSIString = NSDate().timeIntervalSinceReferenceDate.description.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                if iMSIString!.characters.count == 15 {
                    return iMSIString!
                }
                else {
                    if iMSIString!.characters.count > 15 {
                        return iMSIString![0...14]
                    }
                    else {
                        for _ in 0 ..< (15 - iMSIString!.characters.count) {
                            iMSIString! += "0"
                        }
                        return iMSIString!
                    }
                    
                }

            }
            return iMSIString!
        }
    }
    class var iMEI:String {
        get {
            var iMEIString =  HYDefaults[.iMEI]
            if iMEIString == nil {
                iMEIString = NSDate().timeIntervalSince1970.description.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                if iMEIString!.characters.count == 15 {
                    return iMEIString!
                }
                else {
                    if iMEIString!.characters.count > 15 {
                        return iMEIString![0...14]
                    }
                    else {
                        for _ in 0 ..< (15 - iMEIString!.characters.count) {
                            iMEIString! += "0"
                        }
                        return iMEIString!
                    }
                    
                }
            }
            return iMEIString!
        }
    }

}
