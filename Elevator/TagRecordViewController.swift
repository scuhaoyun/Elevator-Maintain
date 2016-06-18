//
//  TagRecordViewController.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/30.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import UIKit
import KVNProgress
class TagRecordViewController : UIViewController,HYBottomToolBarButtonClickDelegate,RecordCellDelegate,SwiftAlertViewDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tagTableview: UITableView!
    @IBOutlet weak var topToolBar: UIView!
    @IBOutlet weak var bottomToolBar: UIView!
    var tagDatas:[Tag] = [] {
        didSet {
            tagTableview.reloadData()
        }
    }

    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        
        tagTableview.delegate = self
        tagTableview.dataSource = self
        self.view.autoresizesSubviews = false
        
    }
    override func viewWillAppear(animated: Bool) {
        tagTableview.separatorInset = UIEdgeInsetsZero
        loadTagData()
    }
    
    /**
    *  协议方法
    */
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
        default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
        }
    }
    //上传接口
    func RecordCellBtnClick(cell: UITableViewCell, clickBtn: UIButton) {
        if clickBtn.currentTitle == "上传" {
            let alertController = UIAlertController(title: "温馨提示", message: "确定要上传吗？", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                    let tagRecord = (cell as! QueryRecordCell).tagRecord!
                     tagRecord.uploadToServer(self)
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
            for cell in tagTableview.visibleCells {
                let queryCell = cell  as! QueryRecordCell
                if !queryCell.checkboxIsSelected {
                    isAllSelect = false
                    break
                }
            }
            if !isAllSelect && (bottomToolBar.subviews[0] as! HYBottomToolBar).firstButton.currentTitle == "取消全选" {
                (bottomToolBar.subviews[0] as! HYBottomToolBar).firstButton.setTitle("全选", forState: UIControlState.Normal)
            }
            
        }
    }
    
    
    /**
    *tableView所需实现的协议方法
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagDatas.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "TagRecordCell"
        var cell  = tagTableview.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            var array = NSBundle.mainBundle().loadNibNamed("QueryRecordCell", owner: self, options: nil)
            let newCell = array[0] as! QueryRecordCell
            newCell.tagRecord = self.tagDatas[indexPath.row]
            newCell.delegate = self
            cell = newCell
        }
        
        return cell!
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tagStoryBoard = UIStoryboard(name:"Tag", bundle: nil)
        let tagViewController = tagStoryBoard.instantiateViewControllerWithIdentifier("TagInstallViewController") as! TagInstallViewController
        tagViewController.tagRecord = (tableView.cellForRowAtIndexPath(indexPath) as! QueryRecordCell).tagRecord
        var rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        while rootViewController?.presentedViewController != nil {
            rootViewController = rootViewController?.presentedViewController
        }
        rootViewController?.presentViewController(tagViewController, animated: true, completion: nil)
        //self.presentViewController(queryViewController, animated: true, completion: nil)
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
    func loadTagData() {
        self.tagDatas = Tag.selectForType("记录")
    }
    func removeBtnOnToolBarClick() {
        let alertController = UIAlertController(title: "温馨提示", message: "确定删除吗？", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            var isAllSuccess = true
            var haveSelected = false
            for cell in self.tagTableview.visibleCells {
                let tagCell = cell  as! QueryRecordCell
                if tagCell.checkboxIsSelected {
                    haveSelected = true
                    let record = self.tagDatas[self.tagTableview.indexPathForCell(tagCell)!.row]
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
                self.loadTagData()
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
        if tagTableview.visibleCells.count > 0 {
            if sender.currentTitle == "全选" {
                sender.setTitle("取消全选", forState: UIControlState.Normal)
                isSelect = true
            }
            else {
                sender.setTitle("全选", forState: UIControlState.Normal)
            }
            for cell in tagTableview.visibleCells {
                let queryCell = cell  as! QueryRecordCell
                queryCell.checkboxIsSelected = isSelect
            }
            
        }
        
    }
    
    
    /**
    *  其他：如扩展等
    */
}
