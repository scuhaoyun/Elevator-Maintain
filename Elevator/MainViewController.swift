//
//  MainViewController.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/27.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import UIKit
import Alamofire
class MainViewController : UIViewController,HYBottomToolBarButtonClickDelegate {
    @IBOutlet weak var bottomToolBar: UIView!
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadToolBar()
        if isLogin {
            HYToast.showString("登录成功！")
        }
        else {
            HYToast.showString("登录失败！")
        }
    }
       @IBAction func queryBtnClick(sender: UIButton) {
        let qrcodeViewController = QRScanViewController(completion: {
            QRUrlString in
            if QRUrlString != nil {
                if QRUrlString! == "recordBtnClick" {
                    let recordStoryboard = UIStoryboard(name:"Record", bundle: nil)
                    let  queryRecordViewController = recordStoryboard.instantiateViewControllerWithIdentifier("QueryRecordViewController") as! QueryRecordViewController
                    self.presentViewController(queryRecordViewController, animated: true, completion: nil)
                }
                else {
                    var qrcode = QRcode()
                    qrcode.QRUrlString = QRUrlString!
                    let queryStoryBoard = UIStoryboard(name:"Query", bundle: nil)
                    let queryViewController = queryStoryBoard.instantiateViewControllerWithIdentifier("QueryInfoViewController") as! QueryInfoViewController
                    queryViewController.twoCodeId = qrcode.QR24String
                    queryViewController.qrcodeTitle = qrcode.QR6String
                    self.presentViewController(queryViewController, animated: true, completion: nil)
                    QueryRecord(title:qrcode.QR6String , twoCodeId: qrcode.QR24String).updateDb()
                }
            }
            else {
                let qureyStoryBoard = UIStoryboard(name:"Query", bundle: nil)
                let queryInstallViewController = qureyStoryBoard.instantiateViewControllerWithIdentifier("QueryManualViewController") as! QueryManualViewController
                self.presentViewController(queryInstallViewController, animated: true, completion: nil)
            }
        })
        self.showViewController(qrcodeViewController, sender: nil)
    }
    @IBAction func maintainBtnClick(sender: UIButton) {
        let qrcodeViewController = QRScanViewController(imageCompletion: {
            QRUrlString,scanedImage in
            if QRUrlString != nil {
                if QRUrlString! == "recordBtnClick" {
                    let  maintainStoryboard = UIStoryboard(name:"Record", bundle: nil)
                    let  maintainRecordViewController = maintainStoryboard.instantiateViewControllerWithIdentifier("MaintainRecordViewController") as! MaintainRecordViewController
                    self.presentViewController(maintainRecordViewController, animated: true, completion: nil)
                }
                else {
                    var qrcode = QRcode()
                    qrcode.QRUrlString = QRUrlString!
                    let maintainRecord = MaintainRecord()
                    if scanedImage != nil {
                        let imageName = HYImage.shareInstance.imageToSave(scanedImage!)
                        if imageName != nil {
                             maintainRecord.imgName = imageName!
                        }
                    }
                    let maintainStoryBoard = UIStoryboard(name:"Maintain", bundle: nil)
                    let startMaintainViewController = maintainStoryBoard.instantiateViewControllerWithIdentifier("StartMaintainViewController") as! StartMaintainViewController
                    startMaintainViewController.maintainRecord = maintainRecord
                    startMaintainViewController.qrcode = qrcode
                    self.presentViewController(startMaintainViewController, animated: true, completion: nil)
                }
            }
            else {
                let maintainStoryBoard = UIStoryboard(name:"Maintain", bundle: nil)
                let maintainInstallViewController = maintainStoryBoard.instantiateViewControllerWithIdentifier("StartMaintainViewController") as! StartMaintainViewController
                self.presentViewController(maintainInstallViewController, animated: true, completion: nil)
            }
        })
        self.showViewController(qrcodeViewController, sender: nil)
    }
    //任务
    @IBAction func taskBtnClick(sender: AnyObject) {
        HYProgress.showSuccessWithStatus("当前您的公司没有任务下发给您！")
    }
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
          case "返回" : break
          case "帮助" :
            let mainStoryBoard = UIStoryboard(name:"MainList", bundle: nil)
            let helpViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("HelpViewController") as! HelpViewController
            self.presentViewController(helpViewController, animated: true, completion: nil)
            /**
            *  跳转到帮助页面
            */
            break
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
        bottomToolBar.addSubview(newToolBar)
    }
    /**
    *  其他：如扩展等
    */
}


