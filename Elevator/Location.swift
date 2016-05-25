//
//  Location.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/15.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import INTULocationManager
class Location:NSObject {
    var currentLocationX:String = "0.000000"
    var currentLocationY:String = "0.000000"
    static let shareInstance = Location()
    var count:Int
    private override init(){
        count = 0
        super.init()
        let timer = NSTimer(timeInterval: 10.0, target: self, selector: "refreshLocation", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    func refreshLocation() -> Void {
        INTULocationManager.sharedInstance().requestLocationWithDesiredAccuracy(INTULocationAccuracy.House, timeout: 10.0, block: {(location,accuracy,status) in
            if (status == .Success) {
                self.currentLocationX = location.coordinate.longitude.description
                self.currentLocationY = location.coordinate.latitude.description
                self.count += 1
                if self.count >= 30 {
                    if HYDbLocation().insert(self.currentLocationX, latituteStr: self.currentLocationY) {
                        self.count = 0
                    }
                }
            }
            else if (status == .TimedOut) {
                print("定位超时")
            }
            else {
                print("定位出错")
            }
       })

    }
   
}