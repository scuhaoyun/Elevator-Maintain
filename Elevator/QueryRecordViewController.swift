//
//  QueryRecordViewController.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/28.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import UIKit
class QueryRecordViewController : UIViewController,HYBottomToolBarButtonClickDelegate,RecordCellDelegate,SwiftAlertViewDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var topToolBar: UIView!
    @IBOutlet weak var queryTableview: UITableView!
    @IBOutlet weak var bottomToolBar: UIView!
    var queryRecordData:[QueryRecord] = [] {
        didSet {
            queryTableview.reloadData()
        }
    }
    var changeAlertView:SwiftAlertView?
    var filterAlertView:SwiftAlertView?
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        loadRecordData()
        queryTableview.delegate = self
        queryTableview.dataSource = self
        
    }
    override func viewWillAppear(animated: Bool) {
        queryTableview.separatorInset = UIEdgeInsetsZero
    }
    
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
            case "返回" :
                break
            case "筛选":filterBtnOnToolBarClick()
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
    func RecordCellBtnClick(cell: UITableViewCell, clickBtn: UIButton) {
        if clickBtn.currentTitle == "编辑" {
            var array = NSBundle.mainBundle().loadNibNamed("QueryRecordCellEditView", owner: self, options: nil) as! [QueryRecordCellEditView]
            let alertContentView = array[0]
            alertContentView.frame = CGRectMake(0, 0, 270, 150)
            alertContentView.queryRecord = (cell as! QueryRecordCell).queryRecord
            changeAlertView = SwiftAlertView(contentView: alertContentView, delegate: self, cancelButtonTitle: "取消",otherButtonTitles: "确认")
            changeAlertView!.buttonAtIndex(0)?.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            changeAlertView!.backgroundColor = UIColor.whiteColor()
            HYKeyboardAvoiding.setAvoidingView(changeAlertView)
            changeAlertView!.show()
        }
        else {
            var isAllSelect = true
            for cell in queryTableview.visibleCells {
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
    //SwiftAlertViewDelegate协议方法
    func alertView(alertView: SwiftAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1 && alertView.isEqual(changeAlertView){
            let contentView = alertView.getContentView() as! QueryRecordCellEditView
            if contentView.qrTitleTextField.text != "" {
                contentView.queryRecord?.title = contentView.qrTitleTextField.text!
                if contentView.queryRecord!.updateDb() {
                    HYProgress.showSuccessWithStatus("修改成功！")
                    self.loadRecordData()
                }
                else{
                    HYProgress.showErrorWithStatus("操作失败！")
                }
                
            }
            else{
                HYProgress.showErrorWithStatus("输入不能为空！")
            }
        }
        if buttonIndex == 1 && alertView.isEqual(filterAlertView){
            let contentView = alertView.getContentView() as! QueryRecordFilterView
            if let title = contentView.filterTitleTextField.text {
                self.queryRecordData = QueryRecord.select(title)
            }
        }
    }

    /**
    *tableView所需实现的协议方法
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryRecordData.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier   = "QueryRecordCell"
        var cell         = queryTableview.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            var array        = NSBundle.mainBundle().loadNibNamed("QueryRecordCell", owner: self, options: nil)
            let newCell      = array[0] as! QueryRecordCell
            newCell.delegate = self
            newCell.queryRecord = queryRecordData[indexPath.row]
            cell             = newCell
        }

        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let queryStoryBoard = UIStoryboard(name:"Query", bundle: nil)
        let queryViewController = queryStoryBoard.instantiateViewControllerWithIdentifier("QueryInfoViewController") as! QueryInfoViewController
        queryViewController.twoCodeId = (tableView.cellForRowAtIndexPath(indexPath) as! QueryRecordCell).queryRecord?.twoCodeId
        queryViewController.qrcodeTitle = (tableView.cellForRowAtIndexPath(indexPath) as! QueryRecordCell).qrcodeTitleLabel.text
        self.showViewController(queryViewController, sender: self)
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }

    /**
    *  自定义函数
    */
    func loadToolBar(){
        var array                = NSBundle.mainBundle().loadNibNamed("HYBottomToolBar", owner: self, options: nil) as! [HYBottomToolBar]
        let newToolBar           = array[0]
        newToolBar.delegate      = self
        newToolBar.frame.size    = topToolBar.frame.size
        newToolBar.frame.origin  = CGPoint(x: 0, y: 0)
        newToolBar.firstButton.setTitle("返回", forState: UIControlState.Normal)
        newToolBar.secondButton.setTitle("筛选", forState: UIControlState.Normal)
        topToolBar.addSubview(newToolBar)

        var array1               = NSBundle.mainBundle().loadNibNamed("HYBottomToolBar", owner: self, options: nil) as! [HYBottomToolBar]
        let newToolBar1          = array1[0]
        newToolBar1.delegate     = self
        newToolBar1.frame.size   = bottomToolBar.frame.size
        newToolBar1.frame.origin = CGPoint(x: 0, y: 0)
        newToolBar1.firstButton.setTitle("全选", forState: UIControlState.Normal)
        newToolBar1.secondButton.setTitle("删除", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar1)
    }
    func loadRecordData() {
        queryRecordData = QueryRecord.selectAll()
    }
    func filterBtnOnToolBarClick() {
        var array = NSBundle.mainBundle().loadNibNamed("QueryRecordFilterView", owner: self, options: nil) as! [QueryRecordFilterView]
        let alertContentView = array[0]
        alertContentView.frame = CGRectMake(0, 0, 270, 80)
        filterAlertView = SwiftAlertView(contentView: alertContentView, delegate: self, cancelButtonTitle: "取消",otherButtonTitles: "确认")
        filterAlertView!.buttonAtIndex(0)?.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        HYKeyboardAvoiding.setAvoidingView(filterAlertView)
        filterAlertView!.show()
    }
    func removeBtnOnToolBarClick() {
        let alertController = UIAlertController(title: "温馨提示", message: "确定删除吗？", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            var isAllSuccess = true
            var haveSelected = false
            for cell in self.queryTableview.visibleCells {
                let queryCell = cell  as! QueryRecordCell
                if queryCell.checkboxIsSelected {
                    haveSelected = true
                    let record = self.queryRecordData[self.queryTableview.indexPathForCell(queryCell)!.row]
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
                self.loadRecordData()
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
        if queryTableview.visibleCells.count > 0 {
            if sender.currentTitle == "全选" {
                sender.setTitle("取消全选", forState: UIControlState.Normal)
                isSelect = true
            }
            else {
                sender.setTitle("全选", forState: UIControlState.Normal)
            }
            for cell in queryTableview.visibleCells {
                let queryCell = cell  as! QueryRecordCell
                queryCell.checkboxIsSelected = isSelect
            }
            
        }

    }
    

    /**
    *  其他：如扩展等
    */
}
