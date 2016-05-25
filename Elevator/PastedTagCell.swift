//
//  PastedTagCell.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/10.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit
class PastedTagCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var totalNumLabel: UILabel!
    var pastedTag:PastedTag? {
        willSet  {
            addressLabel.text = "楼盘:\(newValue!.buildingName)"
            totalNumLabel.text = "\(newValue!.pasteTotal)"
        }
    }
    
}
