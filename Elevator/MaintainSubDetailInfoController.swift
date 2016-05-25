//
//  MaintainSubDetailInfoController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/10.
//  Copyright © 2016年 haoyun. All rights reserved.
//


import UIKit

class MaintainSubDetailInfoController : UIViewController,HYBottomToolBarButtonClickDelegate{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var needLabel: UILabel!
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var remarkTxt: HYTextView!
    var content:String?
    var need:String?
    var titleString:String?
    var remark:String?
    var onCompletion:MaintainSubCompletion?
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        loadInfo()
    }
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "确认":
            self.dismissViewControllerAnimated(true, completion: nil)
            onCompletion?(self.remarkTxt.text!)
        default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
        }
    }
    
       /**
    *  自定义函数
    */
    func loadToolBar(){
        var array = NSBundle.mainBundle().loadNibNamed("HYBottomToolBar", owner: self, options: nil) as! [HYBottomToolBar]
        let newToolBar = array[0]
        newToolBar.delegate = self
        newToolBar.frame.size = bottomToolBar.frame.size
        newToolBar.frame.origin = CGPoint(x: 0, y: 0)
        newToolBar.firstButton.setTitle("确认", forState: UIControlState.Normal)
        newToolBar.secondButton.hidden = true
        bottomToolBar.addSubview(newToolBar)
    }
    func loadInfo(){
        self.titleLabel.text = titleString
        self.contentLabel.text = content
        self.needLabel.text = need
        if remark != nil {
            self.remarkTxt.text = remark!
        }
    }
      /**
    *  其他：如扩展等
    */
}

