//
//  CheckViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/27.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
class CheckViewController : UIViewController,HYBottomToolBarButtonClickDelegate,SwiftAlertViewDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var totalTasksLabel: UILabel!
    @IBOutlet weak var curruntTasksLabel: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var topToolBar: UIView!
    @IBOutlet weak var bottomToolBar: UIView!
    var remoteSearchAlertView:SwiftAlertView?
    var localSearchAlertView:SwiftAlertView?
    var isLoadData:Bool = false
    var checkRecords:[CheckRecord] = [] {
        didSet {
            taskTableView.reloadData()
            isLoadData = true
            updateTaskNum()
        }
    }
    /**
     *  View生命周期函数
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        taskTableView.delegate = self
        taskTableView.dataSource = self
        
    }
    override func viewDidAppear(animated: Bool) {
        if !isLoadData {
            let checkInfo = HYDefaults[.checkInfo]
            if checkInfo != nil {
                self.checkRecords = CheckRecord.selectForAdress(checkInfo![0], buildingName: checkInfo![1])
            }
            else {
                HYToast.showString("没有可执行的任务！")
            }
        }

    }
    @IBAction func refreshBtnClick(sender: UIButton) {
        let checkInfo = HYDefaults[.checkInfo]
        if checkInfo != nil {
            let parameters = ["address": checkInfo![0],"buildingName":checkInfo![1]]
           remoteSearch(URLStrings.queryddEleShenHeInfoTcMobile, parameters: parameters)
        }
        else {
            HYToast.showString("没有可执行的任务！")
        }

    }
    @IBAction func searchBtnClick(sender: UIButton) {
        searchForTitle(title: "本地搜索")
    }
    
    /**
     *  协议方法
     */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "返回" :
            break
        case "搜索":searchForTitle(title: "远程搜索")
            break
        case "扫描" :scanBtnOnToolBarClick()
            break
        default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
        }
    }
    //SwiftAlertViewDelegate协议方法
    func alertView(alertView: SwiftAlertView, clickedButtonAtIndex buttonIndex: Int){
        let contentView = alertView.getContentView() as! AdressAndBuildingNameSearchView
        let isLocalSearch = contentView.titleLabel.text! == "本地搜索" ? true : false
        if contentView.addressTxt.text != "" || contentView.buildingNameTxt.text != "" {
            //远程搜索
            if buttonIndex == 1 && !isLocalSearch{
                let parameters = ["address": contentView.addressTxt.text!,"buildingName":contentView.buildingNameTxt.text!]
                remoteSearch(URLStrings.newqueryddEleShenHeInfoTcMobile,parameters: parameters)
            }
            //本地搜索
            if buttonIndex == 1 && isLocalSearch {
                self.checkRecords = CheckRecord.selectForAdress(contentView.addressTxt.text!, buildingName: contentView.buildingNameTxt.text!)
                     HYToast.showString("搜索成功！")
            }
        }
        else{
            HYToast.showString("查询条件不能都为空！")
        }

    }

    /**
     *tableView所需实现的协议方法
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkRecords.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "CheckTaskCell"
        var cell  = taskTableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            var array = NSBundle.mainBundle().loadNibNamed("CheckTaskCell", owner: self, options: nil)
            let newCell = array[0] as! CheckTaskCell
            newCell.checkRecord = checkRecords[indexPath.row]
            cell = newCell
        }
        
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let checkStoryBoard = UIStoryboard(name:"Check", bundle: nil)
        let checkViewController = checkStoryBoard.instantiateViewControllerWithIdentifier("CheckInfoViewController") as! CheckInfoViewController
        checkViewController.checkRecord = checkRecords[indexPath.row]
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
        newToolBar.secondButton.setTitle("搜索", forState: UIControlState.Normal)
        topToolBar.addSubview(newToolBar)
        
        var array1 = NSBundle.mainBundle().loadNibNamed("HYBottomToolBar", owner: self, options: nil) as! [HYBottomToolBar]
        let newToolBar1 = array1[0]
        newToolBar1.delegate = self
        newToolBar1.frame.size = bottomToolBar.frame.size
        newToolBar1.frame.origin = CGPoint(x: 0, y: 0)
        newToolBar1.firstButton.hidden = true
        newToolBar1.secondButton.setTitle("扫描", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar1)
    }
    
    func scanBtnOnToolBarClick() {
        let qrcodeViewController = QRScanViewController(completion: {
            QRUrlString in
            var checkRecord:CheckRecord?
            if QRUrlString != nil {
                if QRUrlString! == "recordBtnClick" {
                    let tagStoryboard = UIStoryboard(name:"Record", bundle: nil)
                    let  checkRecordViewController = tagStoryboard.instantiateViewControllerWithIdentifier("CheckRecordViewController") as! CheckRecordViewController
                    self.presentViewController(checkRecordViewController, animated: true, completion: nil)
                    return
                }
                else{
                    var qrcode = QRcode()
                    qrcode.QRUrlString = QRUrlString!
                    checkRecord = CheckRecord()
                    checkRecord!.registNumber = qrcode.QR6String
                }
                
            }
           
            let checkStoryBoard = UIStoryboard(name:"Check", bundle: nil)
            let checkInfoViewController = checkStoryBoard.instantiateViewControllerWithIdentifier("CheckInfoViewController") as! CheckInfoViewController
            checkInfoViewController.checkRecord = checkRecord
            self.presentViewController(checkInfoViewController, animated: true, completion: nil)
            
        })
        self.showViewController(qrcodeViewController, sender: nil)
    }
    func searchForTitle(title title:String){
        var array = NSBundle.mainBundle().loadNibNamed("AdressAndBuildingNameSearchView", owner: self, options: nil) as! [AdressAndBuildingNameSearchView]
        let alertContentView = array[0]
        alertContentView.frame = CGRectMake(0, 0, Constants.alertViewWidth, 150)
        alertContentView.titleLabel.text = title
        remoteSearchAlertView = SwiftAlertView(contentView: alertContentView, delegate: self, cancelButtonTitle: "取消",otherButtonTitles: "确认")
        remoteSearchAlertView!.buttonAtIndex(0)?.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        HYKeyboardAvoiding.setAvoidingView(remoteSearchAlertView)
        remoteSearchAlertView!.show()
    }
    func remoteSearch(urlString:String,parameters:Dictionary<String,String>){
        if HYNetwork.isConnectToNetwork(self) {
            HYProgress.showWithStatus("正在查询，请稍等！")
            Alamofire.request(.GET, urlString, parameters: parameters)
                .responseJSON { response in
                    HYProgress.dismiss()
                    if response.result.isSuccess {
                        if HYJSON(response.result.value!)["stotal"].int == 0 {
                            self.checkRecords = Mapper<CheckRecord>().mapArray(HYJSON(response.result.value!)["listArray"].arrayObject)!
                            if self.checkRecords.count > 0 {
                                HYToast.showString("获取成功！")
                                HYDefaults[.checkInfo] = [parameters["address"]!,parameters["buildingName"]!]
                                for checkRd in self.checkRecords {
                                    if CheckRecord.selectForQR(checkRd.registNumber).count > 0 {
                                        checkRd.updateDb()
                                    }
                                    else {
                                        checkRd.insertToDb()
                                    }
                                }
                            }
                            else{
                                HYToast.showString("没有可执行的任务！")
                            }
                        }
                        else {
                            HYToast.showString("结果条数过多，请增加搜索条件重新搜索！")
                        }
                        
                    }
                    else{
                        HYToast.showString("获取失败")
                    }

                }
        }

    }
    
    func updateTaskNum(){
        self.totalTasksLabel.text = "任务数:\(self.checkRecords.count)"
        var waitNum = 0
        for checkRecord in checkRecords {
            if checkRecord.shenhe == "0" {
                waitNum += 1
            }
        }
        self.curruntTasksLabel.text = "未完成:\(waitNum)"
    }
       /**
     *  其他：如扩展等
     */
}

