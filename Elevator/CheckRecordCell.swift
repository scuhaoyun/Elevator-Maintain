//
//  CheckRecordCell.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/2.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit

protocol CheckRecordCellDelegate:class {
    func CheckRecordCellBtnClick(cell:UITableViewCell,clickBtn:UIButton)
}
class CheckRecordCell: UITableViewCell{
    @IBOutlet weak var checkboxBtn: UIButton!
    @IBOutlet weak var qrcodeTitleLabel: UILabel!
    @IBOutlet weak var isNormalLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    var checkRecord:CheckRecord? {
        willSet  {
            qrcodeTitleLabel.text = newValue?.registNumber
            timeLabel.text = newValue?.date
            if newValue != nil {
                if newValue!.isUpload {
                    self.editBtn.setTitle("已上传", forState: UIControlState.Normal)
                    self.editBtn.setBackgroundImage(UIImage(named: "bottom_button_disable.png"), forState: UIControlState.Normal)
                    self.editBtn.enabled = false
                }
                else{
                    self.editBtn.setTitle("上传", forState: UIControlState.Normal)
                }
                if !newValue!.isNormal() {
                    self.isNormalLabel.text = "异常"
                    self.isNormalLabel.textColor = UIColor.redColor()
                }
            }
        }
    }
    weak var delegate:CheckRecordCellDelegate?
    var checkboxIsSelected: Bool = false {
        willSet{
            if newValue {
                checkboxBtn.setBackgroundImage(UIImage(named: "checkbox_selected.png"), forState:UIControlState.Normal)
            }
            else{
                checkboxBtn.setBackgroundImage(UIImage(named: "checkbox_unselected.png"), forState:UIControlState.Normal)
            }
        }
    }
    @IBAction func editBtnClick(sender: UIButton) {
        delegate?.CheckRecordCellBtnClick(self, clickBtn: sender)
    }
    
    @IBAction func checkboxClick(sender: UIButton) {
        checkboxIsSelected = !checkboxIsSelected
        delegate?.CheckRecordCellBtnClick(self, clickBtn: sender)
    }
    func alertView(alertView: SwiftAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
    }
}