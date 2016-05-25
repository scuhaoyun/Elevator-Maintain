//
//  HYNetwork.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/8.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
class HYNetwork: NSObject {
   
    class func isConnectToNetwork(viewcontroller: UIViewController) -> Bool {
        var reachability:HYReachability?
        do {
            reachability = try HYReachability.reachabilityForInternetConnection()
        }
        catch{
            let alertController = UIAlertController(title: "温馨提示", message: "网络错误！", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)
            viewcontroller.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        if reachability!.isReachable(){
            return true
        }
        else {
            let alertController = UIAlertController(title: "温馨提示", message: "亲，您的网络连接未打开哦", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "前往打开", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                //打开设置页面  注：未测试成功
                let url = NSURL(string: "prefs:root=WIFI")
                UIApplication.sharedApplication().openURL(url!)
            } )
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            viewcontroller.presentViewController(alertController, animated: true, completion: nil)
            return false
        }
    }

    
}