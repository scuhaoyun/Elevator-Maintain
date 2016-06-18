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
            self.currentLocationX = location.coordinate.longitude.description
            self.currentLocationY = location.coordinate.latitude.description
            self.count += 1
            if self.count >= 15 {
                if HYDbLocation().insert(self.currentLocationX, latituteStr: self.currentLocationY) {
                    self.count = 0
                }
            }
       })

    }
    class func getDistance(long1:Double,lat1:Double,long2:Double,lat2:Double)->Double{
        let R:Double = 6367000
        let pi = 3.1415926
        let nLong1 = long1 * pi / 180
        let nLat1 = lat1 * pi / 180
        let nLong2 = long2 * pi / 180
        let nLat2 = lat2 * pi / 180
        let calLong = nLong2 - nLong1
        let calLat = nLat2 - nLat1
        let step1 = pow(sin(calLat/2), 2) + cos(lat1) * cos(lat2) * pow(sin(calLong/2), 2)
        let step2 = 2 * asin(min(1, sqrt(step1)))
        let distance = R * step2
        return round(distance)
    }
}