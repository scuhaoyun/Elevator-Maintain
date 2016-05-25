//
//  ReachabilitySwift-extension.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/8.
//  Copyright © 2016年 haoyun. All rights reserved.
//

//import ReachabilitySwift
//extension Reachability {
//    class func isConnectToNetwork(viewcontroller: UIViewController){
//        if Reachability.isReachable() {
//            
//        }
//        else {
//            var alertController = UIAlertController(title: "温馨提示", message: "亲，您的网络连接未打开哦", preferredStyle: UIAlertControllerStyle.Alert)
//            var okAction = UIAlertAction(title: "前往打开", style: UIAlertActionStyle.Default, handler:{
//                (action: UIAlertAction!) -> Void in
//                //打开设置页面  注：未测试成功
//                var url = NSURL(string: "prefs:root=WIFI")
//                UIApplication.sharedApplication().openURL(url!)
//            } )
//            var cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
//            alertController.addAction(okAction)
//            alertController.addAction(cancelAction)
//            self.presentViewController(alertController, animated: true, completion: nil)
//            
//        }
//        return IJReachability.isConnectedToNetwork()
//    }
//}