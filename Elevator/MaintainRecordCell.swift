//
//  ElevatorRecordCell.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/30.
//  Copyright © 2015年 haoyun. All rights reserved.
//
import UIKit
class MaintainRecordCell: UITableViewCell{
    @IBOutlet weak var checkboxBtn: UIButton!
    @IBOutlet weak var qrcodeTitleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    var maintainRecord:MaintainRecord? {
        willSet {
            guard newValue != nil else {
                return
            }
            self.qrcodeTitleLabel.text = newValue!.twoCodeId[0...5]
            self.startTimeLabel.text = newValue!.startTime
            self.endTimeLabel.text = newValue!.endTime
            if newValue!.state != "未完成" {
               if !newValue!.isUpload {
                    self.editBtn.enabled = true
                    self.editBtn.setBackgroundImage(UIImage(named: "bottom_button_normal.png"), forState: .Normal)
                    self.editBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    self.editBtn.setTitle("上传", forState: .Normal)
                }
                else {
                    if newValue!.state == "审核中"  {
                        self.editBtn.enabled = true
                        self.editBtn.setBackgroundImage(UIImage(named: "bottom_button_normal.png"), forState: .Normal)
                        self.editBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                        self.editBtn.setTitle("审核中", forState: .Normal)
                    }
                    else{
                        self.editBtn.setTitle(newValue!.state, forState: .Normal)
                        self.editBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                        self.editBtn.enabled = false
                    }
                }
            }
            
        }
    }
    weak var delegate:RecordCellDelegate?
    var checkboxIsSelected: Bool = false {
        didSet{
            if self.checkboxIsSelected {
                checkboxBtn.setBackgroundImage(UIImage(named: "checkbox_selected.png"), forState:UIControlState.Normal)
            }
            else{
                checkboxBtn.setBackgroundImage(UIImage(named: "checkbox_unselected.png"), forState:UIControlState.Normal)
            }
        }
    }
    @IBAction func editBtnClick(sender: UIButton) {
        delegate?.RecordCellBtnClick(self, clickBtn: sender)
    }
    
    @IBAction func checkboxClick(sender: UIButton) {
        checkboxIsSelected = !checkboxIsSelected
        delegate?.RecordCellBtnClick(self, clickBtn: sender)
    }
    
}