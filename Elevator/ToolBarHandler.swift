//
//  ToolBarHandler.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/30.
//  Copyright © 2015年 haoyun. All rights reserved.
//

//import UIKit
//class ToolBarHandler: NSObject,HYBottomToolBarButtonClickDelegate{
//    private var tableview = UITableView()
//    private var tableviewCell = UITableViewCell()
//    func addToolBarToView(view:UIView){
//        var array = NSBundle.mainBundle().loadNibNamed("HYBottomToolBar", owner: self, options: nil) as! [HYBottomToolBar]
//        let newToolBar = array[0]
//        newToolBar.delegate = self
//        newToolBar.frame.size = view.frame.size
//        newToolBar.frame.origin = CGPoint(x: 0, y: 0)
//        newToolBar.firstButton.setTitle("返回", forState: UIControlState.Normal)
//        newToolBar.secondButton.setTitle("筛选", forState: UIControlState.Normal)
//        view.addSubview(newToolBar)
//
//    }
//    /**
//    *  协议方法
//    */
//    func toolBarButtonClicked(sender: UIButton,currentToolBar:HYBottomToolBar) {
//        switch sender.currentTitle! {
//        case "返回" :backBtnOnToolBarClick()
//            break
//        case "筛选":filterBtnOnToolBarClick()
//            break
//        case "全选" :selectBtnOnToolBarClick(sender,currentToolBar:currentToolBar)
//            break
//        case "取消全选" :selectBtnOnToolBarClick(sender,currentToolBar:currentToolBar)
//            break
//        case "删除":removeBtnOnToolBarClick()
//        
//            break
//        default:  fatalError("HYBottomToolBarButtonClickDelegate method go error!")
//        }
//    }
//
//    func backBtnOnToolBarClick() {
//        
//    }
//    func filterBtnOnToolBarClick() {
//        
//    }
//    func removeBtnOnToolBarClick() {
//        
//    }
//    func selectBtnOnToolBarClick(sender: UIButton,currentToolBar:HYBottomToolBar) {
//        //获取tableview
//               var isSelect = false
//        if tableview.visibleCells.count > 0 {
//            if sender.currentTitle == "全选" {
//                sender.setTitle("取消全选", forState: UIControlState.Normal)
//                isSelect = true
//            }
//            else {
//                sender.setTitle("全选", forState: UIControlState.Normal)
//            }
//            for cell in tableview.visibleCells {
//                let queryCell = cell  as! QueryRecordCell
//                queryCell.checkboxIsSelected = isSelect
//            }
//            
//        }
//        
//    }
//    private func getTableView(sender:UIButton,currentToolBar:HYBottomToolBar){
//         var subviews = currentToolBar.superview?.superview?.subviews
//         for subview in subviews! {
//            if subview is UITableView {
//                tableview = subview as! UITableView
//            }
//         }
//        if tableview.visibleCells[0] is QueryRecordCell {
//            tableviewCell =
//        }
//
//    }
//
//}
