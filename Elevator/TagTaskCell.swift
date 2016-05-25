//
//  TagTaskCell.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/31.
//  Copyright © 2015年 haoyun. All rights reserved.
//
import UIKit
class TagTaskCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var registerInfoLabel: UILabel!
    var tagRecord:Tag? {
        willSet  {
            guard timeLabel != nil && newValue != nil else {
                fatalError("在nib加载之前调用组件为nil！")
            }
            timeLabel.text = newValue!.arrangeTime
            addressLabel.text = "\(newValue!.address) \(newValue!.buildingName) \(newValue!.building) \(newValue!.unit)"
            registerInfoLabel.text = "\(newValue!.registCode) \(newValue!.useNumber)"
        }
    }

}
