//
//  UIView-extension.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/10.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
extension UIView {
    public func getCurrentViewController()-> UIViewController? {
        for var next = self.superview; (next != nil); next = next?.superview {
            let nextResponder = next?.nextResponder()
            if nextResponder is  UIViewController {
                 return nextResponder as? UIViewController
            }
        }
        return nil
    }
}