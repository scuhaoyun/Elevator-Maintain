//
//  MaintainDetailInfo.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/10.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
typealias MaintainSubCompletion = (String) -> Void
class MaintainDetailInfoController : UIViewController,HYBottomToolBarButtonClickDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var maintainItemTableview: UITableView!
    @IBOutlet weak var bottomToolBar: UIView!
    var maintainRecord:MaintainRecord?
    var onCompletion:MaintainCompletion?
    var maintainItems:JSON = []
    var maintainNeeds:JSON = []/**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        loadMaintainInfo()
        maintainItemTableview.delegate = self
        maintainItemTableview.dataSource = self
        setExtraCellLineHidden()
    }
    override func viewDidLayoutSubviews() {
        maintainItemTableview.separatorInset = UIEdgeInsetsZero
        maintainItemTableview.layoutMargins = UIEdgeInsetsZero
    }
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
            case "返回":break
            case "确认":saveData()
            default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
        }
    }
    
    /**
    *tableView所需实现的协议方法
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maintainItems["item"].count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier   = "QueryRecordCell"
        var cell         = maintainItemTableview.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
           cell = UITableViewCell()
            cell?.textLabel?.text = maintainItems["item"][indexPath.row].string
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell?.backgroundColor = UIColor.darkGrayColor()
            cell?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell?.textLabel?.textColor = UIColor.whiteColor()
            cell?.textLabel?.font = UIFont(descriptor: UIFontDescriptor(), size: 17)
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let maitainStoryBoard = UIStoryboard(name:"Maintain", bundle: nil)
        let maintainSubDetailInfoController = maitainStoryBoard.instantiateViewControllerWithIdentifier("MaintainSubDetailInfoController") as! MaintainSubDetailInfoController
        maintainSubDetailInfoController.titleString = maintainNeeds["name"].string
        maintainSubDetailInfoController.content = maintainItems["item"][indexPath.row].string
        maintainSubDetailInfoController.need = maintainNeeds["item"][indexPath.row].string
        maintainSubDetailInfoController.remark = self.maintainRecord?.getywDetailForIndex(indexPath.row + 1)
        maintainSubDetailInfoController.onCompletion = {
            remarkStr in
            if remarkStr != "" &&  self.maintainRecord != nil {
                if self.maintainRecord!.ywDetail == "" {
                    self.maintainRecord!.setywDetail(self.maintainItems["item"].count, type: self.maintainRecord!.type)
                }
                self.maintainRecord?.updateywDetailForIndex(indexPath.row + 1, withStr:remarkStr)
            }
        }
        self.showViewController(maintainSubDetailInfoController, sender: self)
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
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
        newToolBar.secondButton.setTitle("确认", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar)
    }
    func  loadMaintainInfo() {
        guard self.maintainRecord != nil else {
            return
        }
        maintainItems = HYHandler.getMaintainItemsContents(maintainType:self.maintainRecord!.getTitleForMaintainTypeCode()! , elevatorType: self.maintainRecord!.getTitleForElevatorType()!)
        maintainNeeds = HYHandler.getMaintainItemsRequire(maintainType:self.maintainRecord!.getTitleForMaintainTypeCode()! , elevatorType: self.maintainRecord!.getTitleForElevatorType()!)
        titleLabel.text = maintainItems["name"].string
        //self.maintainRecord!.setywDetail(maintainItems["item"].count, type:self.maintainRecord!.type)
    }
    func saveData(){
        onCompletion?(self.maintainRecord)
    }
    func setExtraCellLineHidden(){
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        maintainItemTableview.tableFooterView = view
    }
    /**
    *  其他：如扩展等
    */
}
