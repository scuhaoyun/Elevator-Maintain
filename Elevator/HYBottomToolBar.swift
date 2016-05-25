//
//  HYBottomToolBar.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/26.
//  Copyright © 2015年 haoyun. All rights reserved.
//


import UIKit

//@IBDesignable
protocol HYBottomToolBarButtonClickDelegate{
    func toolBarButtonClicked(sender:UIButton)
}
class HYBottomToolBar: UIView {
    
   
    @IBOutlet weak var firstButton: UIButton!
  
    @IBOutlet weak var secondButton: UIButton!
    var delegate:HYBottomToolBarButtonClickDelegate?
    @IBAction func firstButtonClicked(sender: UIButton) {
        if sender.currentTitle == "返回" {
            closeCurrentViewController()
        }
        self.delegate?.toolBarButtonClicked(sender)
    }
    
    @IBAction func secondButtonClicked(sender: UIButton) {
        if sender.currentTitle == "返回" {
            closeCurrentViewController()
        }
         self.delegate?.toolBarButtonClicked(sender)
    }
    //返回按钮
    func closeCurrentViewController(){
        var rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        while rootViewController?.presentedViewController != nil {
            rootViewController = rootViewController?.presentedViewController
        }
        rootViewController?.dismissViewControllerAnimated(true , completion: nil)
    }
}
