//
//  LoginViewController.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/24.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import KVNProgress
class LoginViewController : UIViewController{
    
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var isReceiveAlarmSwitch: UISwitch!
    @IBOutlet weak var backgroudImageView: UIImageView!
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMarginConstraint: NSLayoutConstraint!
    var oldOriginY:CGFloat =  0.0
    var isShowed = false
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
       HYKeyboardAvoiding.setAvoidingView(containerView)
       oldOriginY = containerView.frame.origin.y
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
       
    }
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChange", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide", name: UIKeyboardDidHideNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidChange", name: UITextInputCurrentInputModeDidChangeNotification , object: nil)
    }
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextInputCurrentInputModeDidChangeNotification, object: nil)
    }
    override func viewDidAppear(animated: Bool) {
        isLogin = false
        loadUserInfo()
        
    }
    @IBAction func loginInBtnClick(sender: UIButton){
        if isInfoCorrect() {
            if HYNetwork.isConnectToNetwork(self) {

                HYProgress.showWithStatus("正在验证用户名和密码，稍等！")
                HYDefaults[.username] = self.usernameTxt.text
                HYDefaults[.password] = self.passwordTxt.text
                Alamofire.request(.GET, URLStrings.tcnbdlogin, parameters: ["account": self.usernameTxt.text!,"password":self.passwordTxt.text!])
                    .responseString(encoding: NSUTF8StringEncoding){ response in
                        if response.result.value != nil {
                            loginUser = Mapper<User>().map(response.result.value!)
                            HYProgress.dismiss()
                            if loginUser != nil && loginUser!.checkLogin(self) {
                                isLogin = true
                                loginUser!.account = self.usernameTxt.text!
                                if loginUser!.binding! == 1 {
                                    HYProgress.showWithStatus("正在绑定手机，稍等！")
                                    Alamofire.request(.GET, URLStrings.tcBindAddMobile, parameters: ["account": self.usernameTxt.text!,"password":self.passwordTxt.text!,"iMSI":Constants.iMSI,"iMEI":Constants.iMEI])
                                         .responseJSON { response in
                                            HYProgress.dismiss()
                                            if (response.result.value! as! Int) == 0 {
                                                HYToast.showString("绑定失败！")
                                            }
                                    }
                                }
                            }
                        }
                        else {
                            HYProgress.showErrorWithStatus("网络连接错误，请检查网络后重试！")
                        }
                        if isLogin {
                            HYToast.showString("登录成功！")
                        }
                        else {
                            HYToast.showString("登录失败！")
                        }
                        let mainStoryBoard = UIStoryboard(name:"MainList", bundle: nil)
                        let mainViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("MainViewController") as UIViewController
                        self.presentViewController(mainViewController, animated: true, completion: nil)

                }
            }
        }
        else{
            HYProgress.showErrorWithStatus("用户名或密码不能为空，请重新填写")
        }
    }
    @IBAction func severSet(sender: AnyObject) {
        
    }
    @IBAction func backBtnClick(sender: AnyObject) {
    }
    /**
    *  协议方法
    */
    
    /**
    *  自定义函数
    */
    func loadUserInfo(){
        self.usernameTxt.text =  HYDefaults[.username]
        self.passwordTxt.text =  HYDefaults[.password]
    }
    func isInfoCorrect()-> Bool {
        return (usernameTxt.text != "") && (passwordTxt.text != "")
    }
    func orientationChange(){
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            self.backgroudImageView.image = UIImage(named: "login_go_landscappe.png")
        }
        else {
            self.backgroudImageView.image = UIImage(named: "login_go.png")
        }
    }
    func keyboardDidShow(){
        self.backgroudImageView.image = UIImage(named: "login_blank.png")
    }
    func keyboardDidHide(){
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            self.backgroudImageView.image = UIImage(named: "login_go_landscappe.png")
        }
        else {
            self.backgroudImageView.image = UIImage(named: "login_go.png")
        }
    }
    func dismissKeyboard(){
        self.usernameTxt.resignFirstResponder()
        self.passwordTxt.resignFirstResponder()
    }


//    func keyboardDidShow(notification:NSNotification){
////        let info:NSDictionary = notification.userInfo!
////        let value = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)
////        let keyboardHeight = value!.CGRectValue.size.height
////        let bgHeight =
//        topMarginConstraint.constant = 0
//        bottomMarginConstraint.constant = 0
//            let newOriginY = containerView.frame.origin.y
//            topMarginConstraint.constant += (newOriginY - oldOriginY)
//            bottomMarginConstraint.constant += (newOriginY - oldOriginY)
//            //oldOriginY = newOriginY
//    }
//    func keyboardDidHide(){
//
//            //let newOriginY = containerView.frame.origin.y
//            topMarginConstraint.constant = 0
//            bottomMarginConstraint.constant = 0
//            //oldOriginY = newOriginY
//    }
//    func keyboardDidChange(){
//        
//    }
    /**
    *  其他：如扩展等
    */
}
