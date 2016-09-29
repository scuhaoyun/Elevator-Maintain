//
//  ElevatorRecordViewController.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/30.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import UIKit
class MaintainRecordViewController : UIViewController,HYBottomToolBarButtonClickDelegate,RecordCellDelegate,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var topToolBar: UIView!
    @IBOutlet weak var bottomToolBar: UIView!
    var maintainRecords:[MaintainRecord]=[]{
        didSet {
            self.tableview.reloadData()
        }
    }
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        maintainRecords = MaintainRecord.selectAll()
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    /**
    *  协议方法
    */
    func RecordCellBtnClick(cell: UITableViewCell, clickBtn: UIButton) {
        if clickBtn.currentTitle == "上传" {
            let alertController = UIAlertController(title: "温馨提示", message: "确定要上传吗？", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                let maintainRecord = (cell  as! MaintainRecordCell).maintainRecord
                maintainRecord!.uploadToServer(self)
                
            })
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if clickBtn.currentTitle == "审核中" {
            let maintainRecord = (cell  as! MaintainRecordCell).maintainRecord
            maintainRecord?.updateState(self)
        }
        else if clickBtn.currentTitle == "补数据" {
            HYProgress.showErrorWithStatus("该条记录已上传过，不能重复上传")
        }
        else if clickBtn.currentTitle == nil || clickBtn.currentTitle == "" {
            var isAllSelect = true
            for cell in tableview.visibleCells {
                let maintainCell = cell  as! MaintainRecordCell
                if !maintainCell.checkboxIsSelected {
                    isAllSelect = false
                    break
                }
            }
            if !isAllSelect && (bottomToolBar.subviews[0] as! HYBottomToolBar).firstButton.currentTitle == "取消全选" {
                (bottomToolBar.subviews[0] as! HYBottomToolBar).firstButton.setTitle("全选", forState: UIControlState.Normal)
            }
            
        }
    }

    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "返回" :
            break
        case "全选" :selectBtnOnToolBarClick(sender)
            break
        case "取消全选" :selectBtnOnToolBarClick(sender)
            break
        case "删除":removeBtnOnToolBarClick()
        
            break
        default:  break
        }
    }
    /**
    *tableView所需实现的协议方法
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maintainRecords.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "MaintainRecordCell"
        var cell  = tableview.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            var array = NSBundle.mainBundle().loadNibNamed("MaintainRecordCell", owner: self, options: nil)
            let newCell = array[0] as! MaintainRecordCell
            newCell.delegate = self
            newCell.maintainRecord = maintainRecords[indexPath.row]
            cell = newCell
        }

        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let maitainStoryBoard = UIStoryboard(name:"Maintain", bundle: nil)
        let maintainInfoController = maitainStoryBoard.instantiateViewControllerWithIdentifier("MaintainInfoController") as! MaintainInfoController
        maintainInfoController.maintainRecord = maintainRecords[indexPath.row]
        self.showViewController(maintainInfoController, sender: self)
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
        newToolBar.frame.size = topToolBar.frame.size
        newToolBar.frame.origin = CGPoint(x: 0, y: 0)
        newToolBar.firstButton.setTitle("返回", forState: UIControlState.Normal)
        newToolBar.secondButton.hidden = true
        topToolBar.addSubview(newToolBar)
        
        var array1 = NSBundle.mainBundle().loadNibNamed("HYBottomToolBar", owner: self, options: nil) as! [HYBottomToolBar]
        let newToolBar1 = array1[0]
        newToolBar1.delegate = self
        newToolBar1.frame.size = bottomToolBar.frame.size
        newToolBar1.frame.origin = CGPoint(x: 0, y: 0)
        newToolBar1.firstButton.setTitle("全选", forState: UIControlState.Normal)
        newToolBar1.secondButton.setTitle("删除", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar1)
    }
   
    func removeBtnOnToolBarClick() {
        let alertController = UIAlertController(title: "温馨提示", message: "确定删除所选记录吗？", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            var isAllSuccess = true
            var haveSelected = false
            for cell in self.tableview.visibleCells {
                let maintainCell = cell  as! MaintainRecordCell
                if maintainCell.checkboxIsSelected {
                    haveSelected = true
                    let record = self.maintainRecords[self.tableview.indexPathForCell(maintainCell)!.row]
                    if !record.deleteFromDb() {
                        isAllSuccess = false
                    }
                }
            }
            if haveSelected {
                if isAllSuccess {
                    HYProgress.showSuccessWithStatus("删除成功！")
                }
                else {
                    HYProgress.showErrorWithStatus("操作失败！")
                }
                self.maintainRecords = MaintainRecord.selectAll()
            }
            else {
                HYProgress.showErrorWithStatus("未选择删除对象！")
            }
        })
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func selectBtnOnToolBarClick(sender: UIButton) {
        var isSelect = false
        if tableview.visibleCells.count > 0 {
            if sender.currentTitle == "全选" {
                sender.setTitle("取消全选", forState: UIControlState.Normal)
                isSelect = true
            }
            else {
                sender.setTitle("全选", forState: UIControlState.Normal)
            }
            for cell in tableview.visibleCells {
                let queryCell = cell  as! MaintainRecordCell
                queryCell.checkboxIsSelected = isSelect
            }
            
        }
        
    }
    /**
    *  其他：如扩展等
    */
}

