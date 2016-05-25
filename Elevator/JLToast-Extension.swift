//
//  HYToast.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/6.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import JLToast
extension JLToast {
    class func showString(text: String) {
        JLToastView.setDefaultValue(
            UIColor.grayColor(),
            forAttributeName: JLToastViewBackgroundColorAttributeName,
            userInterfaceIdiom: .Phone
        )
        JLToast.makeText(text).show()
    }
}

