//
//  ImageFile.swift
//  Elevator
//
//  Created by 郝赟 on 16/1/17.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import Foundation
class HYImage:NSObject {
    var imageDic:String!
    static let shareInstance = HYImage()
    private override init(){
        super.init()
        imageDic = self.getImageDic()
    }

    func imageToSave(image:UIImage) -> String? {
        let filename = NSDate().timeIntervalSinceReferenceDate.description.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let filePath = self.imageDic + "/" + filename
        let newImage = scaledImage(image)
        if  UIImageJPEGRepresentation(newImage, 0.0001)!.writeToFile(filePath, atomically: true){
            return filename
        }
        else {
            return nil
        }
    }
    func getImageForName(filename:String) -> UIImage? {
        let filePath = self.imageDic + "/" + filename
        return UIImage(named: filePath)
    }
    func deleteFileForName(filename:String )-> Bool {
        if filename != "" {
            let filePath = self.imageDic + "/" + filename
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            }
            catch {
                return false
            }
        }
        return true
    }
    static func get64encodingStr(image:UIImage?)-> String {
        if image != nil {
           return (UIImageJPEGRepresentation(image!, 1.0)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength))!
        }
        else {
            return ""
        }
    }
    //对图片尺寸进行压缩 
    func scaledImage(image:UIImage,size:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    func scaledImage(image:UIImage)-> UIImage {
        let screenSize = UIScreen.mainScreen().bounds.size
        let imageSize = image.size
        let widthScale = imageSize.width / screenSize.width
        let heightScale = imageSize.height / screenSize.height
        var newSize = screenSize
        if widthScale > 1 && heightScale > 1 {
            if widthScale < heightScale {
                newSize.height = CGFloat(Int(imageSize.height / widthScale))
            }
            else if widthScale > heightScale {
                newSize.width = CGFloat(Int(imageSize.width / heightScale))
            }
        }
        else if widthScale >= 1 && heightScale <= 1 {
            newSize.height = CGFloat(Int(imageSize.height / widthScale))
        }
        else if widthScale <= 1 && heightScale >= 1 {
            newSize.height = CGFloat(Int(imageSize.height / widthScale))
        }
        return scaledImage(image, size: newSize)
    }
    func getImageDic() -> String {
        let fileManager = NSFileManager.defaultManager()
        let documentPath: String = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]).stringByAppendingString("/userCache")
        let exist = fileManager.fileExistsAtPath(documentPath)
        if exist == false {
            try! fileManager.createDirectoryAtPath(documentPath, withIntermediateDirectories: true, attributes: nil)
        }
        return documentPath
    }

}