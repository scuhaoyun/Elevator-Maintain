//
//  QueryManualViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/13.
//  Copyright © 2016年 haoyun. All rights reserved.
//
import UIKit
import Alamofire
class QueryManualViewController : UIViewController,HYBottomToolBarButtonClickDelegate{
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var twoCodeIdTxt: UITextField!
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
    }
    @IBAction func sureBtnClick(sender: UIButton) {
        if isInfoCorrect() {
            if HYNetwork.isConnectToNetwork(self) {
                HYProgress.showWithStatus("正在查询，请稍等！")
                Alamofire.request(.GET, "http://cddt.zytx-robot.com/twoCodemobileweb/sjba/tcIsValidMobile.do", parameters: ["registNumber": self.twoCodeIdTxt.text!])
                    .responseJSON { response in
                        HYProgress.dismiss()
                        if response.result.isSuccess {
                            if (response.result.value! as! Int) == 1 {
                                let queryStoryBoard = UIStoryboard(name:"Query", bundle: nil)
                                let queryViewController = queryStoryBoard.instantiateViewControllerWithIdentifier("QueryInfoViewController") as! QueryInfoViewController
                                let twoCodeId = self.twoCodeIdTxt.text! + "000000000000000000"
                                queryViewController.twoCodeId = twoCodeId
                                queryViewController.qrcodeTitle = self.twoCodeIdTxt.text!
                                self.showViewController(queryViewController, sender: self)
                                QueryRecord(title: self.twoCodeIdTxt.text!, twoCodeId: twoCodeId).updateDb()
                            }
                            else {
                                HYProgress.showErrorWithStatus("不存在该编号！")
                            }
                        }
                        HYProgress.showErrorWithStatus("网络错误！")
                }
            }
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
    /**
    *  其他：如扩展等
    */
}
