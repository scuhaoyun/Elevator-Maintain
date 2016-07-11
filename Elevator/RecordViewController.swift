//
//  RecordViewController.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/27.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import UIKit
class RecordViewController : UIViewController {
    /**
    *  View生命周期函数
    */
    //var pageIndex = 0
    var pagesView:SwiftPages?
    override  func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.view.autoresizesSubviews = false
        self.view.autoresizingMask = UIViewAutoresizing.None
        loadPagesView()
    }
    override func viewWillAppear(animated: Bool) {
        
    }
    override func viewDidAppear(animated: Bool) {
         //loadPagesView()
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChange", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
     }
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }
    
    func loadPagesView(){
        let newPageView = SwiftPages()
        newPageView.pageIndex = pagesView != nil ? pagesView!.pageIndex : 0
        for subview in self.view.subviews {
            subview.removeFromSuperview()
        }
        let VCIDs : [String] = ["QueryRecordViewController", "MaintainRecordViewController", "TagRecordViewController"]
        var buttonTitles : [String] = ["查询记录", "运维记录", "标签记录"]
        if UIScreen.mainScreen().bounds.size.width == 320 {
            buttonTitles = ["查询", "运维", "标签"]
        }
        var frame = self.view.frame
        frame.origin.y += 22
        frame.size.height -= 22
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation){
            frame.origin.y -= 22
            frame.size.height += 22
        }
        newPageView.frame = frame
        newPageView.setOriginY(0.0)
        newPageView.enableAeroEffectInTopBar(true)
        newPageView.setButtonsTextColor(UIColor.whiteColor())
        newPageView.setAnimatedBarColor(UIColor.whiteColor())
        newPageView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
        newPageView.autoresizesSubviews = false
        newPageView.autoresizingMask = UIViewAutoresizing.None
        self.view.addSubview(newPageView)
        pagesView = newPageView
    }
    func orientationChange(){
        loadPagesView()
        
    }
    /**
    *  协议方法
    */
    
    /**
    *  自定义函数
    */
    
    /**
    *  其他：如扩展等
    */
}

