//
//  QueryRecordCellEditView.swift
//  Elevator
//
//  Created by 郝赟 on 15/12/29.
//  Copyright © 2015年 haoyun. All rights reserved.
//

import UIKit

class QueryRecordCellEditView: UIView {
    @IBOutlet weak var qrContentLabel: UILabel!
    @IBOutlet weak var qrTitleTextField: UITextField!
    var queryRecord:QueryRecord?{
        willSet {
            qrContentLabel.text = (newValue?.twoCodeId[0...5])! + " http://cddt.zytx-robot.com/twoCodemobileweb/info.jsp?Id=ZYT00E1" + (newValue?.twoCodeId)!
        }
    }
}

