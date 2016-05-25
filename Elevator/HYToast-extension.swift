//
//  HYToast.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/6.
//  Copyright © 2016年 haoyun. All rights reserved.
//


extension HYToast {
    class func showString(text: String) {
        HYToastView.setDefaultValue(
            UIColor.grayColor(),
            forAttributeName: JLToastViewBackgroundColorAttributeName,
            userInterfaceIdiom: .Phone
        )
        HYToast.makeText(text).show()
    }
    
}

