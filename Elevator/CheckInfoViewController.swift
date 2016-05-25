//
//  CheckInfoViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/27.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit
import Alamofire
class CheckInfoViewController: UIViewController,HYBottomToolBarButtonClickDelegate {
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var registNumeberTxt: UITextField!
    @IBOutlet weak var registNumberLabel: UILabel!
    @IBOutlet weak var registNumeberCheckBoxBtn: UIButton!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var areaCheckBoxBtn: UIButton!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var adressCheckBoxBtn: UIButton!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var buildingNameCheckBoxBtn: UIButton!
    @IBOutlet weak var useNumberLabel: UILabel!
    @IBOutlet weak var registCodeLabel: UILabel!
    @IBOutlet weak var buildingLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var shenHeBeiZhuTxt: HYTextView!
    @IBOutlet weak var deviceId2Txt: UITextField!
    @IBOutlet weak var tagPhotoBtn: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var registNumberView: UIView!
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var registNumberViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    var checkRecord:CheckRecord?
//    var registNumber:String?
    var isTakePhoto = false
    @IBAction func searchElevatorInfo(sender: UIButton) {
        if isInfoCorrect() {
            searchCheckRecord(self.registNumeberTxt.text!)
        }
        
    }
    @IBAction func QRScan(sender: AnyObject) {
        let qrcodeViewController = QRScanViewController(completion: {
            QRUrlString in
            if QRUrlString != nil {
                if QRUrlString! == "recordBtnClick" {
                    let checkStoryboard = UIStoryboard(name:"Record", bundle: nil)
                    let  checkRecordViewController = checkStoryboard.instantiateViewControllerWithIdentifier("CheckRecordViewController") as! CheckRecordViewController
                    self.presentViewController(checkRecordViewController, animated: true, completion: nil)
                }
                else {
                    var qrcode = QRcode()
                    qrcode.QRUrlString = QRUrlString!
                    self.deviceId2Txt.text = qrcode.QR6String
                }
            }
            else {
                
            }
        })
        self.showViewController(qrcodeViewController, sender: nil)

    }
    @IBAction func takePhoto(sender: UIButton) {
        let qrviewcontroller = ALCameraViewController(croppingEnabled: false, completion: {
            image in
            if image != nil {
                //如果设置了图片，将button的tag设为111
                sender.setBackgroundImage(image, forState: .Normal)
                self.isTakePhoto = true
            }
        })
        self.presentViewController(qrviewcontroller, animated: true, completion: nil)
    }
    @IBAction func registNumberCheckBoxClick(sender: UIButton) {
        if checkRecord != nil {
            setCheckBoxState(sender, state: checkRecord!.shenHeState[0], isChange: true, index: 0)
        }
    }
    @IBAction func areaCheckBoxClick(sender: UIButton) {
        if checkRecord != nil {
            setCheckBoxState(sender, state: checkRecord!.shenHeState[7], isChange: true, index: 7)
        }
    }
    @IBAction func addressNumberCheckBoxClick(sender: UIButton) {
        if checkRecord != nil {
            setCheckBoxState(sender, state: checkRecord!.shenHeState[2], isChange: true, index: 2)
        }
    }
    @IBAction func buildingNameCheckBoxClick(sender: UIButton) {
        if checkRecord != nil {
            setCheckBoxState(sender, state: checkRecord!.shenHeState[3], isChange: true, index: 3)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        updateConstraints()
        loadCheckRecordData()
    }
    override func viewDidAppear(animated: Bool) {
        if checkRecord != nil {
            if checkRecord!.building == "" {
                searchCheckRecord(checkRecord!.registNumber)
            }
        }

    }
    /**
     *  协议方法
     */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "返回" :
            break
        case "确定":saveCheckRecord()
            break
        default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
        }
    }
    
       /**
     *  自定义函数
     */
    func loadToolBar(){
        
        var array1 = NSBundle.mainBundle().loadNibNamed("HYBottomToolBar", owner: self, options: nil) as! [HYBottomToolBar]
        let newToolBar1 = array1[0]
        newToolBar1.delegate = self
        newToolBar1.frame.size = bottomToolBar.frame.size
        newToolBar1.frame.origin = CGPoint(x: 0, y: 0)
        newToolBar1.firstButton.setTitle("返回", forState: UIControlState.Normal)
        newToolBar1.secondButton.setTitle("确定", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar1)
    }
    func loadCheckRecordData(){
        self.registNumeberTxt.text = checkRecord?.registNumber
        self.registNumberLabel.text = checkRecord?.registNumber
        self.areaLabel.text = checkRecord?.area
        self.adressLabel.text = checkRecord?.address
        self.buildingNameLabel.text = checkRecord?.buildingName
        self.useNumberLabel.text = checkRecord?.useNumber
        self.registCodeLabel.text = checkRecord?.registCode
        self.buildingLabel.text = checkRecord?.building
        self.unitLabel.text = checkRecord?.unit
        self.shenHeBeiZhuTxt.text = checkRecord?.shenHeBeiZhu
        self.deviceId2Txt.text = checkRecord?.deviceId2
        if checkRecord != nil {
            let img = HYImage.shareInstance.getImageForName((checkRecord?.shenheImgName)!)
            if img != nil {
                self.tagPhotoBtn.setBackgroundImage(img, forState: .Normal)
            }
            setCheckBoxState(registNumeberCheckBoxBtn, state: checkRecord!.shenHeState[0], isChange: false, index: nil)
            setCheckBoxState(areaCheckBoxBtn, state: checkRecord!.shenHeState[7], isChange: false, index: nil)
            setCheckBoxState(adressCheckBoxBtn, state: checkRecord!.shenHeState[2], isChange: false, index: nil)
            setCheckBoxState(buildingNameCheckBoxBtn, state: checkRecord!.shenHeState[3], isChange: false, index: nil)
        }
    }
    //检查查询的六位编号是否符合要求
    func isInfoCorrect()-> Bool {
        if registNumeberTxt.text?.characters.count != 6 {
            HYToast.showString("请输入正确的电梯编号编号！")
            return false
        }
//        if self.checkRecord != nil {
//            if self.checkRecord?.registNumber == self.registNumeberTxt.text {
//                HYToast.showString("已获取到编号信息！")
//                return false
//            }
//        }
        return true
    }
    func saveCheckRecord(){
        if checkRecord == nil {
            HYProgress.showErrorWithStatus("无有效核查信息，请确认后重试！")
        }
        else if !self.isTakePhoto {
            HYProgress.showErrorWithStatus("未拍摄核查照片，请拍摄后保存！")
        }
        else {
            self.checkRecord?.shenHeBeiZhu = self.shenHeBeiZhuTxt.text!
            self.checkRecord?.deviceId2 = self.deviceId2Txt.text!
            self.checkRecord?.date = Constants.curruntTimeString
            self.checkRecord?.type = "记录"
            
            self.dismissViewControllerAnimated(true, completion: {
                if self.isTakePhoto {
                    HYImage.shareInstance.deleteFileForName(self.checkRecord!.shenheImgName)
                    self.checkRecord?.shenheImgName = HYImage.shareInstance.imageToSave(self.tagPhotoBtn.backgroundImageForState(.Normal)!)!
                }
                if self.checkRecord!.isExit {
                    let alertController = UIAlertController(title: "温馨提示", message: "已存在编号为\(self.checkRecord!.registNumber)的记录，您确定覆盖该条记录吗？", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
                        (action: UIAlertAction!) -> Void in
                        self.checkRecord!.updateDb()
                    })
                    let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else {
                   self.checkRecord!.insertToDb()
                }
            })
        }
    }
    func setCheckBoxState(button:UIButton,state:String,isChange:Bool,index:Int?) {
        //如果是点击checkbox改变状态
        if isChange && index != nil {
            if state == "0" {
                checkRecord?.shenHeState.replace(index!, withString: "1")
                button.setBackgroundImage(UIImage(named: "checkbox_selected.png"), forState:UIControlState.Normal)
            }
            else{
                checkRecord?.shenHeState.replace(index!, withString: "0")
                button.setBackgroundImage(UIImage(named: "checkbox_unselected.png"), forState:UIControlState.Normal)
            }
        }
        //如果是初始状态加载状态
        else {
            if state == "0" {
                button.setBackgroundImage(UIImage(named: "checkbox_unselected.png"), forState:UIControlState.Normal)
            }
            else{
                button.setBackgroundImage(UIImage(named: "checkbox_selected.png"), forState:UIControlState.Normal)
            }

        }
        
    }
    func updateConstraints(){
        if checkRecord != nil {
            let frame = searchView.frame
            self.searchViewHeight.constant = 0
            self.containerViewHeight.constant -= frame.size.height
            self.searchView.hidden = true
        }

        else{
            let frame = registNumberView.frame
            self.registNumberViewHeight.constant = 0
            self.containerViewHeight.constant -= frame.size.height
            self.registNumberView.hidden = true
        }

    }
    
    func searchCheckRecord(registNumber:String) {
       
            if HYNetwork.isConnectToNetwork(self) {
                HYProgress.showWithStatus("正在查询，请稍等!")
                Alamofire.request(.GET, "http://cddt.zytx-robot.com/twoCodemobileweb/sjba/queryddEleShenHeInfoTcMobile.do", parameters: ["registNumber": registNumber])
                    .responseArray { (response: Response<[CheckRecord], NSError>) in
                        HYProgress.dismiss()
                        if response.result.isSuccess && response.result.value!.count > 0{
                            HYToast.showString("获取成功!")
                            self.checkRecord = response.result.value![0]
                            self.loadCheckRecordData()
                        }
                        else{
                            HYToast.showString("获取失败!")
                        }
                }
            }

    }
    
}
