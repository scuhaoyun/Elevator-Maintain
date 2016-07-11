//
//  QueryEvalutationInfoViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/9.
//  Copyright © 2016年 haoyun. All rights reserved.
//


import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
class QueryEvalutationInfoViewController: UIViewController,HYBottomToolBarButtonClickDelegate {
    @IBOutlet weak var satisfyBtn: UIButton!
    @IBOutlet weak var commonBtn: UIButton!
    @IBOutlet weak var unSatisfyBtn: UIButton!
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var historyMessageTextview: UITextView!
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var historyRemarkBtn: UIButton!
    var twoCodeId:String?
    var remarkLevel:String = "0" {
        willSet {
            switch remarkLevel {
                case "0": self.satisfyBtn.setBackgroundImage(UIImage(named: "radio-unselect.png"), forState: .Normal)
                case "1": self.commonBtn.setBackgroundImage(UIImage(named: "radio-unselect.png"), forState: .Normal)
                case "2": self.unSatisfyBtn.setBackgroundImage(UIImage(named: "radio-unselect.png"), forState: .Normal)
                default:break
            }
        }
    }
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
    }
    @IBAction func submitBtnClick(sender: UIButton) {
        if HYNetwork.isConnectToNetwork(self) {
            HYProgress.showWithStatus("正在提交，请稍等！")
            Alamofire.request(.GET, URLStrings.remarkAddMobile, parameters: ["twoCodeId":twoCodeId!,"remarkLevel":remarkLevel,"remarkInfo":self.messageTxt.text!])
                 .responseJSON { response in
                    HYProgress.dismiss()
                    if response.result.isSuccess {
                        if response.result.value! as! Int == 0 {
                            HYProgress.showErrorWithStatus("评价失败！")
                        }
                        else {
                            self.submitBtn.enabled = false
                            HYProgress.showSuccessWithStatus("评价成功！")
                            
                        }
                    }
                    else{
                        HYProgress.showErrorWithStatus("网络错误，请稍后再试！")
                    }
            }
        }

    }

    @IBAction func historyBtnClick(sender: UIButton) {
        if HYNetwork.isConnectToNetwork(self) {
            HYProgress.showWithStatus("正在获取，请稍等！")
            Alamofire.request(.GET, URLStrings.remarkListMobile, parameters: ["twoCodeId":twoCodeId!])
                .responseArray { (response: Response<[RemarkInfo], NSError>) in
                    HYProgress.dismiss()
                    if response.result.isSuccess {
                        HYToast.showString("获取成功")
                        let remarkInfos = response.result.value!
                        var remarkTextString = ""
                        for remarkinfo in remarkInfos {
                            remarkTextString += remarkinfo.remarkLeverString() + "    "
                            remarkTextString += remarkinfo.remarkDate! + "    "
                            remarkTextString += remarkinfo.remarkInfo! + "\n"
                        }
                        self.historyMessageTextview.text = remarkTextString
                    }
                    else{
                        HYToast.showString("获取失败")
                    }
            }
        }

    }
    @IBAction func satisfyBtnClick(sender: UIButton) {
        remarkLevel = "0"
        sender.setBackgroundImage(UIImage(named: "radio-select.png"), forState: .Normal)
    }
    @IBAction func commonBtnClick(sender: UIButton) {
        remarkLevel = "1"
        sender.setBackgroundImage(UIImage(named: "radio-select.png"), forState: .Normal)
    }
    @IBAction func unSatisfyBtnClick(sender: UIButton) {
        remarkLevel = "2"
        sender.setBackgroundImage(UIImage(named: "radio-select.png"), forState: .Normal)
    }
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
        case "返回": break
        /**
        *  返回的主菜单
        */
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
    
    /**
    *  其他：如扩展等
    */
    
}
