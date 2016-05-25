//
//  CheckRecordViewController.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/30.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import UIKit
class CheckRecordViewController: UIViewController,HYBottomToolBarButtonClickDelegate,CheckRecordCellDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var checkTableview: UITableView!
    @IBOutlet weak var topToolBar: UIView!
    @IBOutlet weak var bottomToolBar: UIView!
    var checkRecordDatas:[CheckRecord] = [] {
        didSet {
            checkTableview.reloadData()
        }
    }

    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        self.checkRecordDatas = CheckRecord.selectForType("记录")
        checkTableview.delegate = self
        checkTableview.dataSource = self
        
    }
    override func viewWillAppear(animated: Bool) {
        checkTableview.separatorInset = UIEdgeInsetsZero
    }
    
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "返回" :backBtnOnToolBarClick()
            break
        case "全选" :selectBtnOnToolBarClick(sender)
            break
        case "取消全选" :selectBtnOnToolBarClick(sender)
            break
        case "删除":removeBtnOnToolBarClick()
        
            break
        default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
        }
    }
    func CheckRecordCellBtnClick(cell: UITableViewCell, clickBtn: UIButton) {
        if clickBtn.currentTitle == "上传" {
            let alertController = UIAlertController(title: "温馨提示", message: "确定要上传吗？", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                let checkRecord = (cell as! CheckRecordCell).checkRecord!
                checkRecord.uploadToServer(self)
            })
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if clickBtn.currentTitle == "已上传" {
            HYProgress.showSuccessWithStatus("该条记录已上传过，不能重复上传")
        }

        else {
            var isAllSelect = true
            for cell in checkTableview.visibleCells {
                let checkCell = cell  as! CheckRecordCell
                if !checkCell.checkboxIsSelected {
                    isAllSelect = false
                    break
                }
            }
            if !isAllSelect && (bottomToolBar.subviews[0] as! HYBottomToolBar).firstButton.currentTitle == "取消全选" {
                (bottomToolBar.subviews[0] as! HYBottomToolBar).firstButton.setTitle("全选", forState: UIControlState.Normal)
            }
            
        }
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    /**
    *tableView所需实现的协议方法
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkRecordDatas.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "CheckRecordCell"
        var cell  = checkTableview.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            var array = NSBundle.mainBundle().loadNibNamed("CheckRecordCell", owner: self, options: nil)
            let newCell = array[0] as! CheckRecordCell
            newCell.delegate = self
            newCell.checkRecord = checkRecordDatas[indexPath.row]
            cell = newCell
        }
        return cell!
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let checkStoryBoard = UIStoryboard(name:"Check", bundle: nil)
        let checkViewController = checkStoryBoard.instantiateViewControllerWithIdentifier("CheckInfoViewController") as! CheckInfoViewController
        checkViewController.checkRecord = (tableView.cellForRowAtIndexPath(indexPath) as! CheckRecordCell).checkRecord
        self.showViewController(checkViewController, sender: self)

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
    func backBtnOnToolBarClick() {
        
    }
    func removeBtnOnToolBarClick() {
        let alertController = UIAlertController(title: "温馨提示", message: "确定删除所选记录吗？", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            var isAllSuccess = true
            var haveSelected = false
            for cell in self.checkTableview.visibleCells {
                let tagCell = cell  as! CheckRecordCell
                if tagCell.checkboxIsSelected {
                    haveSelected = true
                    let record = self.checkRecordDatas[self.checkTableview.indexPathForCell(tagCell)!.row]
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
                self.checkRecordDatas = CheckRecord.selectForType("记录")
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
        if checkTableview.visibleCells.count > 0 {
            if sender.currentTitle == "全选" {
                sender.setTitle("取消全选", forState: UIControlState.Normal)
                isSelect = true
            }
            else {
                sender.setTitle("全选", forState: UIControlState.Normal)
            }
            for cell in checkTableview.visibleCells {
                let checkCell = cell  as! CheckRecordCell
                checkCell.checkboxIsSelected = isSelect
            }
            
        }
        
    }
    
//    func loadCheckRecordDatas(){
//        self.checkRecordDatas = CheckRecord.selectAll()
//    }
    /**
    *  其他：如扩展等
    */
}
