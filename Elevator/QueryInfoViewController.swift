//
//  QueryInfoViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/5.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
class QueryInfoViewController : UIViewController,HYBottomToolBarButtonClickDelegate {
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var twoCodeIdTxt: UILabel!
    var twoCodeId:String?
    var qrcodeTitle:String?
    var elevatorInfo:ElevatorInfo?
    /**
    *  View生命周期函数
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        loadToolBar()
        
    }
    override func viewWillAppear(animated: Bool) {
        self.twoCodeIdTxt.text = self.qrcodeTitle
    }
    @IBAction func elevatorInfoBtnClick(sender: UIButton) {
        loadElevatorInfo(URLStrings.queryEleInfoMobile1, segueStr: "elevatorInfo")
    }
    @IBAction func maintainInfoBtnClick(sender: UIButton) {
        loadElevatorInfo(URLStrings.queryEleInfoMobile, segueStr: "maintainInfo")
    }
    @IBAction func EvaluationBtnClick(sender: UIButton) {
        let queryStoryboard = UIStoryboard(name:"Query", bundle: nil)
        let  queryEvalutationInfoViewController = queryStoryboard.instantiateViewControllerWithIdentifier("QueryEvalutationInfoViewController") as! QueryEvalutationInfoViewController
        queryEvalutationInfoViewController.twoCodeId = self.twoCodeId
        self.presentViewController(queryEvalutationInfoViewController, animated: true, completion: nil)
    }
    /**
    *  协议方法
    */
    func toolBarButtonClicked(sender: UIButton) {
        switch sender.currentTitle! {
            /**
            *  跳转到记录页面
            */
        case "记录" :
            let recordStoryboard = UIStoryboard(name:"Record", bundle: nil)
            let  queryRecordViewController = recordStoryboard.instantiateViewControllerWithIdentifier("QueryRecordViewController") as! QueryRecordViewController
            queryRecordViewController
            self.presentViewController(queryRecordViewController, animated: true, completion: nil)
           
            break
        case "返回":break
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
        newToolBar.secondButton.setTitle("记录", forState: UIControlState.Normal)
        bottomToolBar.addSubview(newToolBar)
    }
    func loadElevatorInfo(urlStr:String,segueStr:String){
            if HYNetwork.isConnectToNetwork(self) {
                HYProgress.showWithStatus("正在查询，请稍等！")
                Alamofire.request(.GET, urlStr, parameters: ["twoCodeId":twoCodeId!])
                    .responseString(encoding: NSUTF8StringEncoding){ response in
                        HYProgress.dismiss()
                        if response.result.isSuccess {
                            self.elevatorInfo = Mapper<ElevatorInfo>().map(response.result.value!)
                            if segueStr == "elevatorInfo" {
                                self.segueToElevatorInfoVC()
                            }
                            else{
                                self.segueToMaintainInfoVC()
                            }
                        }
                        else{
                            HYProgress.showErrorWithStatus("网络错误，请稍后再试！")
                        }
                }
            }
    }
    func segueToElevatorInfoVC(){
        let queryStoryboard = UIStoryboard(name:"Query", bundle: nil)
        let elevatorInfoViewController = queryStoryboard.instantiateViewControllerWithIdentifier("QueryElevatorInfoViewController") as! QueryElevatorInfoViewController
        elevatorInfoViewController.qrcodeTitle = self.qrcodeTitle
        elevatorInfoViewController.elevatorInfo = elevatorInfo
        self.presentViewController(elevatorInfoViewController, animated: true, completion: nil)
    }
    func segueToMaintainInfoVC(){
        let queryStoryboard = UIStoryboard(name:"Query", bundle: nil)
        let maintainInfoViewController = queryStoryboard.instantiateViewControllerWithIdentifier("QueryMaintainInfoViewController") as! QueryMaintainInfoViewController
        maintainInfoViewController.qrcodeTitle = self.qrcodeTitle
        maintainInfoViewController.elevatorInfo = elevatorInfo
        self.presentViewController(maintainInfoViewController, animated: true, completion: nil)
    }


    
    /**
    *  其他：如扩展等
    */
}
