//
//  CheckTaskCell.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/3.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit
class CheckTaskCell: UITableViewCell {
    
    @IBOutlet weak var registNumberLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var registCodeLabel: UILabel!
    var checkRecord:CheckRecord? {
        willSet  {
            guard registCodeLabel != nil && newValue != nil else {
                fatalError("在nib加载之前调用组件为nil！")
            }
            registNumberLabel.text = newValue!.registNumber
            addressLabel.text = "\(newValue!.address) \(newValue!.buildingName) \(newValue!.building) \(newValue!.unit)"
            registCodeLabel.text = "\(newValue!.registCode) \(newValue!.useNumber)"
        }
    }
    
}
