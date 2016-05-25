//
//  HYProgress.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/6.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import KVNProgress
extension KVNProgress {
       class func showHUDWithCancle(text:String,completionClosure:(() -> Void)?){
        let configuration = KVNProgressConfiguration.defaultConfiguration()
        configuration.showStop = true
        configuration.stopColor = UIColor.redColor()
        configuration.stopRelativeHeight = 0.3
        configuration.tapBlock =  {
            progressView  in
            KVNProgress.dismiss()
        }
        KVNProgress.setConfiguration(configuration)
        KVNProgress.showWithStatus(text)
    
    }
}
