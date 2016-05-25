//
//  QueryMaintainInfoViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/9.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit
class QueryMaintainInfoViewController: UIViewController,HYBottomToolBarButtonClickDelegate {
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var subTimeLabel: UILabel!
    @IBOutlet weak var ywKindLabel: UILabel!
    @IBOutlet weak var maintenUnitLabel: UILabel!
    @IBOutlet weak var maintenTelephone: UILabel!
    @IBOutlet weak var bottomToolBar: UIView!
    var qrcodeTitle:String?
    var elevatorInfo:ElevatorInfo?
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        loadElevatorInfo()
    }
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "返回": break
        /**
        *  返回的主菜单
        */
            
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
        newToolBar.firstButton.setTitle("返回", forState: UIControlState.Normal)
        newToolBar.secondButton.hidden = true
        bottomToolBar.addSubview(newToolBar)
    }
    func  loadElevatorInfo() {
        self.subTimeLabel.text = elevatorInfo?.subTime
        self.maintenUnitLabel.text = elevatorInfo?.maintenUnit
        self.maintenTelephone.text = elevatorInfo?.mainteTelephone
        switch elevatorInfo!.ywKind! {
            case "0" : self.ywKindLabel.text = "日常维护"
            case "1": self.ywKindLabel.text = "季度保"
            case "2": self.ywKindLabel.text = "半年保"
            case "3": self.ywKindLabel.text = "年保"
            case "4": self.ywKindLabel.text = "其他"
            default : self.ywKindLabel.text = "正在建设中"
        }
        self.topTitleLabel.text = "编号:" + self.qrcodeTitle!
    }
    
    /**
    *  其他：如扩展等
    */

}
