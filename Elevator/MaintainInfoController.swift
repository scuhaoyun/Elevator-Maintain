//
//  MaintainNormalInfo.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/10.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit
class MaintainInfoController : UIViewController,HYBottomToolBarButtonClickDelegate {
    @IBOutlet weak var twoCodeIdLabel: UILabel!
    @IBOutlet weak var sPositionLabel: UILabel!
    @IBOutlet weak var ePositionLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var ywstatusFlagLabel: UILabel!
    @IBOutlet weak var ywDetailLabel: UILabel!
    @IBOutlet weak var maintainTypeCodeLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var lastStartTimeLabel: UILabel!
    @IBOutlet weak var lastEndTimeLabel: UILabel!
    @IBOutlet weak var bottomToolBar: UIView!
    
    var maintainRecord:MaintainRecord?
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        loadMaintainInfo()
    }
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
            case "返回":break
            case "详情": detailBtnClick()
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
        newToolBar.secondButton.setTitle("详情", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar)
    }
    func  loadMaintainInfo() {
        if maintainRecord != nil {
            self.twoCodeIdLabel.text = maintainRecord!.twoCodeId[0...5]
            self.sPositionLabel.text = maintainRecord!.sPosition == "0" ? "轿厢":"机房"
            self.ePositionLabel.text = maintainRecord!.ePosition == "0" ? "轿厢":"机房"
            self.startTimeLabel.text = maintainRecord!.startTime
            self.endTimeLabel.text = maintainRecord!.endTime
            self.ywstatusFlagLabel.text = maintainRecord!.state
            if maintainRecord!.ywstatusFlag == "1" {
                if maintainRecord!.isUpload{
                    self.ywDetailLabel.text = "已上传，数据正常"
                }
                else{
                    self.ywDetailLabel.text = "未上传，数据正常"
                }
            }
            else {
                self.ywDetailLabel.textColor = UIColor.redColor()
                if maintainRecord!.isUpload{
                    self.ywDetailLabel.text = "已上传，数据异常"
                }
                else{
                    self.ywDetailLabel.text = "未上传，数据异常"
                }

            }
            self.maintainTypeCodeLabel.text = maintainRecord!.getTitleForMaintainTypeCode()
            self.remarkLabel.text = maintainRecord!.remark
            if let lastMaintainRecord = maintainRecord!.lastMaintainRecord() {
                self.lastStartTimeLabel.text = lastMaintainRecord.startTime
                self.lastEndTimeLabel.text = lastMaintainRecord.endTime
            }
            else {
                self.lastStartTimeLabel.text = ""
                self.lastEndTimeLabel.text = ""
            }
        }
    }
    func detailBtnClick(){
        let maitainStoryBoard = UIStoryboard(name:"Maintain", bundle: nil)
        let maintainDetailInfoController = maitainStoryBoard.instantiateViewControllerWithIdentifier("MaintainDetailInfoController") as! MaintainDetailInfoController
        maintainDetailInfoController.maintainRecord = self.maintainRecord
        self.presentViewController(maintainDetailInfoController, animated: true, completion: nil)
    }
    
    /**
    *  其他：如扩展等
    */
}

