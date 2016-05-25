//
//  QueryElevatorInfoViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/5.
//  Copyright © 2016年 haoyun. All rights reserved.
//
import UIKit
class QueryElevatorInfoViewController : UIViewController,HYBottomToolBarButtonClickDelegate {
    @IBOutlet weak var bottomToolBar: UIView!
    
    @IBOutlet weak var twoCodeId: UILabel!
    @IBOutlet weak var device_idTxt: UILabel!
    
    @IBOutlet weak var verTxt: UILabel!
    
    @IBOutlet weak var fix_AddrTxt: UILabel!
    
    @IBOutlet weak var maitenUnitTxt: UILabel!
    
    @IBOutlet weak var userNumberTxt: UILabel!
    
    @IBOutlet weak var inspectorTxt: UILabel!
    
    @IBOutlet weak var nextInspectDateTxt: UILabel!
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
        case "返回":break
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
        self.device_idTxt.text = elevatorInfo?.device_id
        self.verTxt.text = elevatorInfo?.ver
        self.fix_AddrTxt.text = elevatorInfo?.fix_Addr
        self.maitenUnitTxt.text = elevatorInfo?.maintenUnit
        self.userNumberTxt.text = elevatorInfo?.useNumber
        self.inspectorTxt.text = elevatorInfo?.inspector
        self.nextInspectDateTxt.text = elevatorInfo?.nextInspectDate
        self.twoCodeId.text = self.qrcodeTitle
    }
    
    /**
    *  其他：如扩展等
    */
}
