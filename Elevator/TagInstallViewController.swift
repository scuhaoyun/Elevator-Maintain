//
//  TagInstallViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/4.
//  Copyright © 2016年 haoyun. All rights reserved.
//
import UIKit

class TagInstallViewController : UIViewController,HYBottomToolBarButtonClickDelegate,AJDropDownPickerDelegte {
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var areaComboBox: UIButton!
    @IBOutlet weak var useComboBox: UIButton!
    @IBOutlet weak var registNumberTxt: UITextField!
    @IBOutlet weak var useNumberTxt: UITextField!
    @IBOutlet weak var registCodeTxt: AutoCompleteTextField!
    @IBOutlet weak var addressTxt: AutoCompleteTextField!
    @IBOutlet weak var buildingNameTxt: AutoCompleteTextField!
    @IBOutlet weak var buildingTxt: AutoCompleteTextField!
    @IBOutlet weak var unitTxt: AutoCompleteTextField!
    @IBOutlet weak var mobileUploadbeizhuTxt: AutoCompleteTextField!
    @IBOutlet weak var deviceId2Txt: UITextField!
    @IBOutlet weak var img1Btn: UIButton!
    @IBOutlet weak var img2Btn: UIButton!
    @IBOutlet weak var img3Btn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var img3ContainerView: UIView!
    @IBOutlet weak var scrollerView: UIScrollView!
    @IBOutlet weak var bottomBlankView: UIView!
    @IBOutlet weak var img3Height: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
//    var qrcode:QRcode?
    var tagRecord:Tag?
    var areaPicker:AJDropDownPicker?
    var usePicker:AJDropDownPicker?
    var qrviewcontroller:ALCameraViewController?
    var image3:UIImage?
    /**
    *  View生命周期函数
    */
      override func viewDidLoad() {
        super.viewDidLoad()
        configAutoCompleteTextField()
        loadToolBar()
        loadTagData()
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    @IBAction func areaComboBoxPicker(sender: AnyObject) {
        areaPicker = AJDropDownPicker(delegate: self, dataSourceArray: ["锦江区","武侯区","成华区","金牛区","青羊区","温江区","青白江区","新都区","龙泉驿区","都江堰市","崇州市","邛崃市","彭州市","双流县","金堂县","大邑县","郫县","新津县","蒲江县"])
        areaPicker!.showFromView(sender as! UIView)
    }
    @IBAction func useComboBoxPicker(sender: AnyObject) {
        usePicker = AJDropDownPicker(delegate: self, dataSourceArray: ["在用","停用"])
        usePicker!.showFromView(sender as! UIView)
    }
    @IBAction func scanCode(sender: UIButton) {
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
                    self.deviceId2Txt.text = qrcode.QR6String
                }
            }
            else {
                
            }
        })
        self.presentViewController(qrcodeViewController, animated: true, completion: nil)
        //self.showViewController(qrcodeViewController, sender: nil)
        

    }
    @IBAction func img1BtnClick(sender: UIButton) {
        takePhoto(sender,croppringEnabled: false)
    }
    @IBAction func img2BtnClick(sender: UIButton) {
        takePhoto(sender,croppringEnabled: false)
    }
    @IBAction func img3BtnClick(sender: UIButton) {
        takePhoto(sender,croppringEnabled: true)
    }
    

    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "返回" :
            break
        case "确定":saveTagData()
            break
        default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
        }
    }
    func dropDownPicker(dropDownPicker: AJDropDownPicker!, didPickObject pickedObject: AnyObject!) {
        if dropDownPicker.isEqual(areaPicker){
            self.areaComboBox.setTitle(pickedObject as! NSString as String, forState: UIControlState.Normal)
        }
        else {
            self.useComboBox.setTitle(pickedObject as! NSString as String, forState: UIControlState.Normal)
        }
    }


    /**
    *  自定义函数
    */
    func loadToolBar(){
        var array1               = NSBundle.mainBundle().loadNibNamed("HYBottomToolBar", owner: self, options: nil) as! [HYBottomToolBar]
        let newToolBar1          = array1[0]
        newToolBar1.delegate     = self
        newToolBar1.frame.size   = bottomToolBar.frame.size
        newToolBar1.frame.origin = CGPoint(x: 0, y: 0)
        newToolBar1.firstButton.setTitle("返回", forState: UIControlState.Normal)
        newToolBar1.secondButton.setTitle("确定", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar1)
    }
    func saveTagData() {
        if isInfoCorrect() {
            //HYProgress.showWithStatus("正在保存，请稍后！")
            if tagRecord == nil {
                tagRecord = Tag()
            }
            tagRecord!.area = self.areaComboBox.currentTitle!
            tagRecord!.eleStopFlag = self.useComboBox.currentTitle! == "在用" ? "0" : "1"
            tagRecord!.registNumber = self.registNumberTxt.text!
            tagRecord!.useNumber = self.useNumberTxt.text!
            tagRecord!.registCode = self.registCodeTxt.text!
            tagRecord!.address = self.addressTxt.text!
            tagRecord!.buildingName = self.buildingNameTxt.text!
            tagRecord!.building = self.buildingTxt.text!
            tagRecord!.unit = self.unitTxt.text!
            tagRecord!.mobileUploadbeizhu = self.mobileUploadbeizhuTxt.text!
            tagRecord!.deviceId2 = self.deviceId2Txt.text!
            tagRecord!.type = "记录"
            if self.tagRecord!.isExit {
                let alertController = UIAlertController(title: "温馨提示", message: "已存在编号为\(self.tagRecord!.registNumber)的记录，您确定覆盖该条记录吗？", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "确认", style: UIAlertActionStyle.Default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.dismissViewControllerAnimated(true, completion: {
                        self.synDealImage()
                        self.tagRecord!.updateDb()
                    })
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                self.dismissViewControllerAnimated(true, completion: {
                    self.synDealImage()
                    self.tagRecord!.insertToDb()
                })
            }
        }
    }
    func synDealImage(){
        if self.img1Btn.tag == 111 {
            HYImage.shareInstance.deleteFileForName(self.tagRecord!.imgStr1Name)
            self.tagRecord!.imgStr1Name = HYImage.shareInstance.imageToSave(self.img1Btn.backgroundImageForState(.Normal)!)!
        }
        if self.img2Btn.tag == 111 {
            HYImage.shareInstance.deleteFileForName(self.tagRecord!.imgStr2Name)
            self.tagRecord!.imgStr2Name = HYImage.shareInstance.imageToSave(self.img2Btn.backgroundImageForState(.Normal)!)!
        }
        if self.img3Btn.tag == 111 || self.image3 != nil {
            HYImage.shareInstance.deleteFileForName(self.tagRecord!.imgStr3Name)
            self.tagRecord!.imgStr3Name = HYImage.shareInstance.imageToSave(self.img3Btn.backgroundImageForState(.Normal)!)!
        }
    }
    func loadTagData () {
        if tagRecord != nil {
            self.areaComboBox.setTitle(tagRecord!.area != "" ? tagRecord!.area : "武侯区", forState: .Normal)
            let isUse = tagRecord?.eleStopFlag == "0" ? "在用" : "停用"
            self.useComboBox.setTitle(isUse, forState: .Normal)
            self.registNumberTxt.text = tagRecord?.registNumber
            self.useNumberTxt.text = tagRecord?.useNumber
            self.registCodeTxt.text = tagRecord?.registCode
            self.addressTxt.text = tagRecord?.address
            self.buildingNameTxt.text = tagRecord?.buildingName
            self.buildingTxt.text = tagRecord?.building
            self.unitTxt.text = tagRecord?.unit
            self.mobileUploadbeizhuTxt.text = tagRecord?.mobileUploadbeizhu
            self.deviceId2Txt.text = tagRecord?.deviceId2
            let img1 = HYImage.shareInstance.getImageForName(tagRecord!.imgStr1Name)
            let img2 = HYImage.shareInstance.getImageForName(tagRecord!.imgStr2Name)
            image3 = HYImage.shareInstance.getImageForName(tagRecord!.imgStr3Name)
            
            if img1 != nil {
               self.img1Btn.setBackgroundImage(img1, forState: .Normal)
               self.img1Btn.tag = 111
            }
            if img2 != nil {
                self.img2Btn.setBackgroundImage(img2, forState: .Normal)
                self.img2Btn.tag = 111
            }
            if image3 != nil {
                self.img3Btn.setBackgroundImage(image3, forState: .Normal)
                self.img3Btn.tag = 111
            }
            else{
                self.registNumberTxt.enabled = false
            }
        }
        if image3 == nil {
            let frame = img3ContainerView.frame
            self.img3Height.constant = 0
            self.img3ContainerView.frame.size.height = 0
            self.img3ContainerView.hidden = true
            self.containerViewHeight.constant -= frame.size.height
            
        }
        else if image3 != nil {
            self.img3Btn.setBackgroundImage(image3, forState: .Normal)
            self.img3Btn.tag = 111
        }
       

    }
    func takePhoto(sender:UIButton,croppringEnabled:Bool){
        qrviewcontroller = ALCameraViewController(croppingEnabled: croppringEnabled, completion: {
            image in
            if image != nil {
                //如果设置了图片，将button的tag设为111
                sender.tag = 111
                sender.setBackgroundImage(image, forState: .Normal)
            }
        })
        self.presentViewController(self.qrviewcontroller!, animated: true, completion: nil)
    }
    func isInfoCorrect()->Bool{
        if self.registNumberTxt.text! != "" &&  self.addressTxt.text! != "" && self.buildingNameTxt.text! != "" && self.img1Btn.tag == 111 && self.img2Btn.tag == 111 {
            return true
        }

        else{
             HYProgress.showErrorWithStatus("电梯编号、地址、楼盘、标签远景和电梯注册码图片不能为空！")
             return false
        }
       
    }
    func configAutoCompleteTextField(){
        registCodeTxt.indexStr = "tag-install-registCode"
        addressTxt.indexStr = "tag-install-address"
        buildingNameTxt.indexStr = "tag-install-buildingName"
        buildingTxt.indexStr = "tag-install-building"
        unitTxt.indexStr = "tag-install-unit"
        mobileUploadbeizhuTxt.indexStr = "tag-install-beizhu"
    }
    func dismissKeyboard(){
        self.registNumberTxt.resignFirstResponder()
        self.useNumberTxt.resignFirstResponder()
        self.registCodeTxt.resignFirstResponder()
        self.addressTxt.resignFirstResponder()
        self.buildingNameTxt.resignFirstResponder()
        self.buildingTxt.resignFirstResponder()
        self.unitTxt.resignFirstResponder()
        self.mobileUploadbeizhuTxt.resignFirstResponder()
    }
}
