//
//  TagViewController.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/30.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
enum SearchType {
    case remoteSearch
    case localSearch
    case pasteSearch
}
class TagViewController : UIViewController,HYBottomToolBarButtonClickDelegate,SwiftAlertViewDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var totalTasksLabel: UILabel!
    @IBOutlet weak var curruntTasksLabel: UILabel!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var topToolBar: UIView!
    @IBOutlet weak var bottomToolBar: UIView!
    var alertView:SwiftAlertView?
    var searchType = SearchType.localSearch
    var isLoadData:Bool = false
    var tagDatas:[Tag] = []{
        didSet {
            taskTableView.reloadData()
            isLoadData = true
            curruntTasksLabel.text = "当前任务: \(oldValue.count)"
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
            let tagInfo = HYDefaults[.tagInfo]
            let tagTaskNum = HYDefaults[.allTagTaskNum]
            if tagInfo != nil {
                self.tagDatas = Tag.selectForAdress(tagInfo![0], buildingName: tagInfo![1], building: tagInfo![2], unit: tagInfo![3])
            }
            else {
                curruntTasksLabel.text = "当前任务: 0"
                HYToast.showString("没有可执行的任务！")
            }
            if tagTaskNum != nil {
                totalTasksLabel.text = "总的任务: \(tagTaskNum)"
            }
            else{
                totalTasksLabel.text = "总的任务: 0"
            }
        }
        
    }
    @IBAction func refreshBtnClick(sender: UIButton) {
        let tagInfo = HYDefaults[.tagInfo]
        if tagInfo != nil {
            let parameters = ["ywcompayId":loginUser!.ywcompayId!,"address":tagInfo![0],"buildingName":tagInfo![1],"building":tagInfo![2],"unit":tagInfo![3]]
            remoteSearch(URLStrings.queryddeTaskListMobile,parameters: parameters as! Dictionary<String, String>)
        }
        else{
            curruntTasksLabel.text = "当前任务: 0"
        }
       getPasteNumber()
    }
    @IBAction func searchBtnClick(sender: UIButton) {
       searchForTitle(title: "本地搜索")
       self.searchType = .localSearch
    }
    
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "返回" :
            break
        case "搜索":
            searchForTitle(title: "远程搜索")
            self.searchType = .remoteSearch
            break
        case "粘贴查询" :pasteBtnOnToolBarClick(sender)
            break
        case "新建":createBtnOnToolBarClick()
            break
        default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
        }
    }
    //SwiftAlertViewDelegate协议方法
    func alertView(alertView: SwiftAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1 {
            switch self.searchType {
                case .localSearch :
                    let contentView = alertView.getContentView() as! TagTaskSearchView
                    if contentView.buildingNameTxt.text == "" {
                        HYProgress.showErrorWithStatus("楼盘不能为空！")
                    }
                    else {
                      HYToast.showString("搜索成功！")
                    }
                    
                    break
                case .remoteSearch:
                    if loginUser?.ywcompayId != nil  {
                        let contentView = alertView.getContentView() as! TagTaskSearchView
                        if contentView.buildingNameTxt.text == "" {
                            HYProgress.showErrorWithStatus("楼盘不能为空！")
                        }
                        else {
                            let parameters = ["ywcompayId":loginUser!.ywcompayId!,"address":contentView.addressTxt.text! ,"buildingName":contentView.buildingNameTxt.text!,"building":contentView.buidingTxt.text!,"unit":contentView.unitTxt.text!]
                            remoteSearch(URLStrings.newqueryddeTaskListMobile,parameters: parameters as! Dictionary<String, String>)
                        }
                    }
                    else if loginUser == nil {
                        HYProgress.showErrorWithStatus("您未登录,不能进行该操作！")
                    }
                    else {
                        HYProgress.showErrorWithStatus("您的公司不是运维公司，不能进行该操作！")
                    }
                    break
                case .pasteSearch:
                    let contentView = alertView.getContentView() as! AdressAndBuildingNameSearchView
                    if contentView.buildingNameTxt.text == "" {
                        HYProgress.showErrorWithStatus("楼盘不能为空！")
                    }
                    else {
                        let parameters = ["address":contentView.addressTxt.text! ,"buildingName":contentView.buildingNameTxt.text!]
                        getPastedTagInfo(URLStrings.queryEleInfoByAddressTcMobile2,parameters: parameters)
                    }
                 break
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
        return 70
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "TagTaskCell"
        var cell  = taskTableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            var array = NSBundle.mainBundle().loadNibNamed("TagTaskCell", owner: self, options: nil)
            let newCell = array[0] as! TagTaskCell
            newCell.tagRecord = tagDatas[indexPath.row]
            cell = newCell
        }
        
        return cell!
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let tagStoryBoard = UIStoryboard(name:"Tag", bundle: nil)
        let tagInstallViewController = tagStoryBoard.instantiateViewControllerWithIdentifier("TagInstallViewController") as! TagInstallViewController
        tagInstallViewController.tagRecord = tagDatas[indexPath.row]
        self.showViewController(tagInstallViewController, sender: self)
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
        newToolBar1.firstButton.setTitle("粘贴查询", forState: UIControlState.Normal)
        newToolBar1.secondButton.setTitle("新建", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar1)
    }
    
    func createBtnOnToolBarClick() {
        let qrcodeViewController = QRScanViewController(completion: {
            QRUrlString in
            if QRUrlString != nil {
                if QRUrlString! == "recordBtnClick" {
                    let tagStoryboard = UIStoryboard(name:"Record", bundle: nil)
                    let  tagRecordViewController = tagStoryboard.instantiateViewControllerWithIdentifier("TagRecordViewController") as! TagRecordViewController
                    self.presentViewController(tagRecordViewController, animated: true, completion: nil)
                }
                else {
                    var qrcode = QRcode()
                    qrcode.QRUrlString = QRUrlString!
                    let TagStoryBoard = UIStoryboard(name:"Tag", bundle: nil)
                    let tagInstallViewController = TagStoryBoard.instantiateViewControllerWithIdentifier("TagInstallViewController") as! TagInstallViewController
                    let tagRecord = Tag()
                    tagRecord.registNumber = qrcode.QR6String
                    tagInstallViewController.tagRecord = tagRecord
                    self.presentViewController(tagInstallViewController, animated: true, completion: nil)
                }
            }
            else {
                let alviewcontroller = ALCameraViewController(croppingEnabled: true, completion: {
                    image in
                    let TagStoryBoard = UIStoryboard(name:"Tag", bundle: nil)
                    let tagInstallViewController = TagStoryBoard.instantiateViewControllerWithIdentifier("TagInstallViewController") as! TagInstallViewController
                    tagInstallViewController.image3 = image
                    self.presentViewController(tagInstallViewController, animated: true, completion: nil)
                })
                self.presentViewController(alviewcontroller, animated: true, completion: nil)
            }
        })
        self.presentViewController(qrcodeViewController,animated: true, completion: nil)
    }
    func pasteBtnOnToolBarClick(sender: UIButton) {
        var array = NSBundle.mainBundle().loadNibNamed("AdressAndBuildingNameSearchView", owner: self, options: nil) as! [AdressAndBuildingNameSearchView]
        let alertContentView = array[0]
        alertContentView.frame = CGRectMake(0, 0, Constants.alertViewWidth, 150)
        alertView = SwiftAlertView(contentView: alertContentView, delegate: self, cancelButtonTitle: "取消",otherButtonTitles: "确认")
        alertView!.buttonAtIndex(0)?.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        alertView!.show()
        HYKeyboardAvoiding.setAvoidingView(alertView)
        self.searchType = .pasteSearch
    }
    func searchForTitle(title title:String){
        var array = NSBundle.mainBundle().loadNibNamed("TagTaskSearchView", owner: self, options: nil) as! [TagTaskSearchView]
        let alertContentView = array[0]
        alertContentView.frame = CGRectMake(0, 0, Constants.alertViewWidth, 228)
        alertContentView.titleLabel.text = title
        alertView = SwiftAlertView(contentView: alertContentView, delegate: self, cancelButtonTitle: "取消",otherButtonTitles: "确认")
        alertView!.buttonAtIndex(0)?.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        HYKeyboardAvoiding.setAvoidingView(alertView)
        alertView!.show()
    }
    func remoteSearch(urlString:String,parameters:Dictionary<String,String>){
        if HYNetwork.isConnectToNetwork(self) {
            HYProgress.showWithStatus("正在查询，请稍等！")
            Alamofire.request(.GET, urlString, parameters: parameters)
                .responseJSON{ response in
                    HYProgress.dismiss()
                    if response.result.isSuccess {
                        if HYJSON(response.result.value!)["stotal"].int == 0 {
                            self.tagDatas = Mapper<Tag>().mapArray(HYJSON(response.result.value!)["listArray"].arrayObject)!
                            if self.tagDatas.count > 0 {
                                HYToast.showString("获取成功！")
                                HYDefaults[.tagInfo] = [parameters["address"]!,parameters["buildingName"]!,parameters["building"]!,parameters["unit"]!]
                                for tag in self.tagDatas {
                                    if tag.isExit {
                                        tag.updateDb()
                                    }
                                    else {
                                        tag.insertToDb()
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
    func getPastedTagInfo(urlString:String,parameters:Dictionary<String,String>) {
        if HYNetwork.isConnectToNetwork(self) {
            HYProgress.showWithStatus("正在查询，请稍等！")
            Alamofire.request(.GET, urlString, parameters: parameters)
                .responseArray { (response: Response<[PastedTag], NSError>) in
                    HYProgress.dismiss()
                    if response.result.isSuccess {
                        let tagStoryBoard = UIStoryboard(name:"Tag", bundle: nil)
                        let pastedTagViewController = tagStoryBoard.instantiateViewControllerWithIdentifier("PastedTagViewControlelr") as! PastedTagViewControlelr
                        pastedTagViewController.pastedTags = PastedTag.merge(response.result.value!)
                        pastedTagViewController.searchAddress = parameters["address"]!
                        pastedTagViewController.searchBuildingName = parameters["buildingName"]!
                        self.presentViewController(pastedTagViewController, animated: true, completion: nil)
                    }
                    else{
                        HYToast.showString("获取失败")
                    }
            }
        }
        
    }

    func getPasteNumber(){
        guard loginUser?.ywcompayId != nil else {
            HYToast.showString("您所在公司不支持!")
            self.totalTasksLabel.text = "总的任务: 0"
            return
        }
        Alamofire.request(.GET, URLStrings.queryTaskTotalMobile, parameters: ["ywcompayId":loginUser!.ywcompayId!])
            .responseJSON{ (response: Response<AnyObject, NSError>) in
                HYProgress.dismiss()
                if response.result.isSuccess {
                    let tagTaskNum = HYJSON(response.result.value!)["taskTotal"].int!
                    HYDefaults[.allTagTaskNum] = tagTaskNum
                    self.totalTasksLabel.text = "总的任务: \(tagTaskNum)"
                }
        }

    }
    
}


