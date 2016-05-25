//
//  StartMaintainViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/12.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit
import Alamofire
typealias MaintainCompletion = (MaintainRecord?) -> Void
class StartMaintainViewController : UIViewController,HYBottomToolBarButtonClickDelegate,AJDropDownPickerDelegte {
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var twoCodeIdTxt: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var elevatorTypeBtn: UIButton!
    @IBOutlet weak var maintaiTypeBtn: UIButton!
    @IBOutlet weak var startMaintainBtn: UIButton!
    @IBOutlet weak var endMaintainBtn: UIButton!
    @IBOutlet weak var twoCodeIdQueryView: UIView!
    @IBOutlet weak var maintainView: UIView!
    @IBOutlet weak var radio1Btn: UIButton!
    @IBOutlet weak var radio2Btn: UIButton!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var beizhuView: UIView!
    @IBOutlet weak var beizhuTxt: HYTextView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var searchViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pickerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var beizhuViewHeight: NSLayoutConstraint!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    var isEndUpdate = false
    var maintainRecord:MaintainRecord?
    var qrcode:QRcode? {
        willSet {
            if newValue != nil {
                if maintainRecord == nil {
                    maintainRecord = MaintainRecord()
                }
                if newValue!.isScan {
                    maintainRecord!.twoCodeId = newValue!.QR24String
                }
                else {
                    maintainRecord!.twoCodeId = "\(newValue!.QR6String)0\(ywType)"
                }

                guard loginUser != nil else {
                    return
                }
                if newValue!.isScan {
                    maintainRecord?.threedscanning = loginUser!.threedscanning!
                    maintainRecord?.ywstatusFlag = "1"
                }
                else {
                    maintainRecord?.threedscanning = "3"
                }
            }
        }
    }
    var maintaiTypePicker:AJDropDownPicker?
    var elevatorTypePicker:AJDropDownPicker?
    var ywType = "0" {
        willSet {
            switch newValue {
                case "0":
                     self.radio2Btn.setBackgroundImage(UIImage(named: "radio-unselect.png"), forState: .Normal)
                    self.radio1Btn.setBackgroundImage(UIImage(named: "radio-select.png"), forState: .Normal)
                case "1":
                    self.radio1Btn.setBackgroundImage(UIImage(named: "radio-unselect.png"), forState: .Normal)
                    self.radio2Btn.setBackgroundImage(UIImage(named: "radio-select.png"), forState: .Normal)
                default: break
            }
           self.maintainRecord?.twoCodeId.replace(7, withString: newValue)
        }
    }
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        updateConstraints()
        maintaiTypePicker?.delegate = self
        elevatorTypePicker?.delegate = self
       
    }
   
    @IBAction func sureBtnClick(sender: UIButton) {
        if isInfoCorrect() {
            if HYNetwork.isConnectToNetwork(self) {
                HYProgress.showWithStatus("正在查询，请稍等！")
                   Alamofire.request(.GET,"http://cddt.zytx-robot.com/twoCodemobileweb/sjba/tcIsValidMobile.do", parameters: ["registNumber": self.twoCodeIdTxt.text!])
                       .responseJSON { response in
                        HYProgress.dismiss()
                        if (response.result.value! as! Int) == 1 {
                            self.startMaintainBtn.enabled = true
                            var newqrcode = QRcode()
                            newqrcode.QR6String = self.twoCodeIdTxt.text!
                            self.qrcode = newqrcode
                        }
                        else {
                            HYProgress.showErrorWithStatus("不存在该编号！")
                        }
                    }
            }
        }

    }
    @IBAction func radioBtn1Click(sender: AnyObject) {
        ywType = "0"
    }
    @IBAction func radioBtn2Click(sender: AnyObject) {
        ywType = "1"
        
    }
    @IBAction func startBtnClick(sender: UIButton) {
        let maitainStoryBoard = UIStoryboard(name:"Maintain", bundle: nil)
        let maintainDetailInfoController = maitainStoryBoard.instantiateViewControllerWithIdentifier("MaintainDetailInfoController") as! MaintainDetailInfoController
        updateMaintainRecord()
        if self.maintainRecord!.startTime == "" {
            self.maintainRecord!.startTime = Constants.curruntTimeString
        }
        if self.maintainRecord!.sPosition == "" {
            self.maintainRecord!.sPosition = self.maintainRecord!.twoCodeId[7]
        }
        if self.maintainRecord!.isExit {
            let alertController = UIAlertController(title: "温馨提示", message: "已存在编号为\(self.maintainRecord!.twoCodeId[0...5])的记录，您确定覆盖该条记录吗？", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
                (action: UIAlertAction!) -> Void in
                self.maintainRecord!.updateDb()
            })
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            self.maintainRecord!.insertToDb()
        }

        maintainDetailInfoController.maintainRecord = self.maintainRecord
        maintainDetailInfoController.onCompletion = {
            newMaintainRecord in
            //回调返回数据
            self.dismissViewControllerAnimated(true, completion: nil)
            self.maintainRecord = newMaintainRecord
            self.maintainRecord?.updateDb()
            self.endMaintainUpdateView()
            self.endMaintainBtn.enabled = true
        }
        self.showViewController(maintainDetailInfoController, sender: self)
        HYToast.showString("正在运维...")
    }
    @IBAction func endMaintainBtnClick(sender: UIButton) {
        guard qrcode != nil else {
            return
        }
        if qrcode!.isScan {
            let qrcodeViewController = QRScanViewController(completion: {
                QRUrlString in
                if QRUrlString != nil {
                    var newqrcode = QRcode()
                    newqrcode.QRUrlString = QRUrlString!
                    self.qrcode = newqrcode
                    self.maintainRecord!.endTime = Constants.curruntTimeString
                    self.maintainRecord!.ePosition = self.maintainRecord!.twoCodeId[7]
                    self.endMaintainBtn.enabled = false
                }
            })
            self.showViewController(qrcodeViewController, sender: nil)
        }
        else {
            self.maintainRecord!.endTime = Constants.curruntTimeString
            self.maintainRecord!.ePosition = self.maintainRecord!.twoCodeId[7]
            self.endMaintainBtn.enabled = false
        }
        updateMaintainRecord()
        self.maintainRecord?.updateDb()
    }
    @IBAction func maintainTypeBtnClick(sender: UIButton) {
        maintaiTypePicker = AJDropDownPicker(delegate: self, dataSourceArray: ["半月保","季度保","半年保","年保"])
        maintaiTypePicker!.showFromView(sender as UIView)

    }
    @IBAction func elevatorTypeBtnClick(sender: UIButton) {
        elevatorTypePicker = AJDropDownPicker(delegate: self, dataSourceArray: ["客梯/货梯","扶梯"])
        elevatorTypePicker!.showFromView(sender as UIView)
    }
    @IBAction func submitBtnClick(sender: AnyObject) {
        guard maintainRecord != nil else {
            return
        }
        updateMaintainRecord()
        self.maintainRecord!.remark = self.beizhuTxt.text
        self.maintainRecord!.state = "已完成"
        self.maintainRecord?.updateDb()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func dropDownPicker(dropDownPicker: AJDropDownPicker!, didPickObject pickedObject: AnyObject!) {
        if dropDownPicker.isEqual(maintaiTypePicker){
            self.maintaiTypeBtn.setTitle(pickedObject as! NSString as String, forState: UIControlState.Normal)
            self.maintainRecord?.setMaintainTypeCodeForTitle(pickedObject as! NSString as String)
        }
        else {
            self.elevatorTypeBtn.setTitle(pickedObject as! NSString as String, forState: UIControlState.Normal)
            self.maintainRecord?.setElevatorTypeForTitle(pickedObject as! NSString as String)
        }
    }
   
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "返回":break
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
    //检查查询的六位编号是否符合要求
    func isInfoCorrect()-> Bool {
        if twoCodeIdTxt.text?.characters.count != 6 {
            HYProgress.showErrorWithStatus("请输入正确的编号！")
            return false
        }
        return true
    }
    func updateConstraints(){
        var hiddenHeight:CGFloat = 0
        if qrcode != nil {
            if qrcode!.isScan {
                hiddenHeight += self.twoCodeIdQueryView.frame.size.height
                self.searchViewHeight.constant = 0
                twoCodeIdQueryView.hidden = true
                
            }
        }
        else {
            startMaintainBtn.enabled = false
        }
        hiddenHeight += self.beizhuView.frame.size.height
        self.beizhuViewHeight.constant = 0
        beizhuView.hidden = true
        endMaintainBtn.enabled = false
        containerHeight.constant -= hiddenHeight
    }
    func endMaintainUpdateView(){
        var hiddenHeight:CGFloat = 0
        startMaintainBtn.enabled = false
        endMaintainBtn.enabled = true
        hiddenHeight += pickerView.frame.size.height
        pickerViewHeight.constant = 0
        hiddenHeight -= 140
        beizhuViewHeight.constant = 140
        beizhuView.hidden = false
        twoCodeIdTxt.enabled = false
        searchBtn.enabled = false
        pickerView.hidden = true
        containerHeight.constant -= hiddenHeight
        beizhuView.setNeedsLayout()
        beizhuView.layoutIfNeeded()
        
    }
    func updateMaintainRecord(){
        self.maintainRecord?.setMaintainTypeCodeForTitle(maintaiTypeBtn.currentTitle!)
        self.maintainRecord?.setElevatorTypeForTitle(elevatorTypeBtn.currentTitle!)
        self.maintainRecord?.twoCodeId.replace(7, withString: ywType)
    }
      /**
    *  其他：如扩展等
    */
}

