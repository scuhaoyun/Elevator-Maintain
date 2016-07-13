//
//  SetupViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/7/11.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
class SetupViewController:UIViewController,HYBottomToolBarButtonClickDelegate {
    @IBOutlet weak var applicationAddressTxt: UITextField!
    @IBOutlet weak var applicationPortTxt: UITextField!
    @IBOutlet weak var severAddressTxt: UITextField!
    @IBOutlet weak var serverPortTxt: UITextField!
    @IBOutlet weak var deviceAddressTxt: UITextField!
    @IBOutlet weak var devicePortTxt: UITextField!
    @IBOutlet weak var mediaAddressTxt: UITextField!
    @IBOutlet weak var mediaPortTxt: UITextField!
    @IBOutlet weak var noticeAddressTxt: UITextField!
    @IBOutlet weak var noticePortTxt: UITextField!
    @IBOutlet weak var blackBtn: UIButton!
    @IBOutlet weak var autoUploadBtn: UIButton!
    @IBOutlet weak var receiveBtn: UIButton!
    @IBOutlet weak var bottomToolBar: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        loadSetupInfo()
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    /**
     *  协议方法
     */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
            case "返回":break
            case "提交":saveData()
                /**
                *  返回的主菜单
                */
            default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
        }
    }
    @IBAction func blackBtnClick(sender: UIButton) {
        setCheckBoxState(sender, isClick: true, initalValue: nil)
    }
    @IBAction func autoUploadBtnClick(sender: UIButton) {
        setCheckBoxState(sender, isClick: true, initalValue: nil)
    }
    @IBAction func receiveBtnClick(sender: UIButton) {
        setCheckBoxState(sender, isClick: true, initalValue: nil)
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
        newToolBar1.secondButton.setTitle("提交", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar1)
    }
    func loadSetupInfo(){
         self.applicationAddressTxt.text = HYDefaults[.applicationAddress] ?? "cddt.zytx-robot.com"
         self.applicationPortTxt.text = HYDefaults[.applicationPort] ?? "80"
         self.severAddressTxt.text = HYDefaults[.severAddress] ?? "cddt.zytx-robot.com"
         self.serverPortTxt.text = HYDefaults[.serverPort] ?? "5222"
         self.deviceAddressTxt.text = HYDefaults[.deviceAddress] ?? "119.6.254.76"
         self.devicePortTxt.text = HYDefaults[.devicePort] ?? "8081"
         self.mediaAddressTxt.text = HYDefaults[.mediaAddress] ?? "119.6.254.76"
         self.mediaPortTxt.text = HYDefaults[.mediaPort] ?? "8886"
         self.noticeAddressTxt.text = HYDefaults[.noticeAddress] ?? "119.6.254.76"
         self.noticePortTxt.text = HYDefaults[.noticePort] ?? "34000"
        setCheckBoxState(self.blackBtn, isClick: false, initalValue: HYDefaults[.blackBtn])
        setCheckBoxState(self.autoUploadBtn, isClick: false, initalValue: HYDefaults[.autoUploadBtn])
        setCheckBoxState(self.receiveBtn, isClick:false, initalValue: HYDefaults[.receiveBtn])
    }
    
    func saveData(){
        HYDefaults[.applicationAddress] = self.applicationAddressTxt.text!
        HYDefaults[.applicationPort] = self.applicationPortTxt.text!
        HYDefaults[.severAddress] = self.severAddressTxt.text!
        HYDefaults[.serverPort] = self.serverPortTxt.text!
        HYDefaults[.deviceAddress] = self.deviceAddressTxt.text!
        HYDefaults[.devicePort] = self.devicePortTxt.text!
        HYDefaults[.mediaAddress] = self.mediaAddressTxt.text!
        HYDefaults[.mediaPort] = self.mediaPortTxt.text!
        HYDefaults[.noticeAddress] = self.noticeAddressTxt.text!
        HYDefaults[.noticePort] = self.noticePortTxt.text!
        HYDefaults[.blackBtn] = self.blackBtn.tag == 0 ? false : true
        HYDefaults[.autoUploadBtn] = self.autoUploadBtn.tag == 0 ? false : true
        HYDefaults[.receiveBtn] = self.receiveBtn.tag == 0 ? false : true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func setCheckBoxState(button:UIButton,isClick:Bool, initalValue:Bool?) {
        //如果是点击checkbox改变状态
        if isClick {
            if button.tag == 0 {
                button.tag = 1
                button.setBackgroundImage(UIImage(named: "checkbox_selected.png"), forState:UIControlState.Normal)
            }
            else{
                button.tag = 0
                button.setBackgroundImage(UIImage(named: "checkbox_unselected.png"), forState:UIControlState.Normal)
            }
        }
            //如果是初始状态加载状态
        else {
            if initalValue != nil {
                if !(initalValue!) {
                    button.tag = 0
                    button.setBackgroundImage(UIImage(named: "checkbox_unselected.png"), forState:UIControlState.Normal)
                }
                else{
                    button.tag = 1
                    button.setBackgroundImage(UIImage(named: "checkbox_selected.png"), forState:UIControlState.Normal)
                }

            }
            else{
                button.tag = 0
            }
        }
        
    }
    func dismissKeyboard(){
        self.applicationAddressTxt.resignFirstResponder()
        self.applicationPortTxt.resignFirstResponder()
        self.severAddressTxt.resignFirstResponder()
        self.serverPortTxt.resignFirstResponder()
        self.deviceAddressTxt.resignFirstResponder()
        self.devicePortTxt.resignFirstResponder()
        self.mediaAddressTxt.resignFirstResponder()
        self.mediaPortTxt.resignFirstResponder()
        self.noticeAddressTxt.resignFirstResponder()
        self.noticePortTxt.resignFirstResponder()
    }

}