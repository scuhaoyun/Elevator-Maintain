//
//  LGScanViewController.swift
//  LGScanViewController
//
//  Created by jamy on 15/9/22.
//  Copyright © 2015年 jamy. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftQRCode
public typealias QRScanViewCCompletion = (String?) -> Void
public typealias QRScanForImageCCompletion = (String?,UIImage?) -> Void
class QRScanViewController: LBXScanViewController {
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let screenSize = UIScreen.mainScreen().bounds.size
    var timer1:NSTimer!
    var timer2:NSTimer!
    let closeButton = UIButton()
    let recordButton = UIButton()
    let flashButton = UIButton()
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    var onCompletion:QRScanViewCCompletion?
    var onImageCompletion:QRScanForImageCCompletion?
    init(completion: QRScanViewCCompletion) {
        super.init(nibName: nil, bundle: nil)
        onCompletion = completion
    }
    init(imageCompletion: QRScanForImageCCompletion) {
        super.init(nibName: nil, bundle: nil)
        onImageCompletion = imageCompletion
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //需要识别后的图像
        if onImageCompletion != nil {
            isNeedCodeImage = true
        }
        
        //框向上移动10个像素
        scanStyle?.centerUpOffset += 10
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_green")
        self.scanStyle = style
    }
    
    func tipsForFlash(){
        HYToast.showString("请开闪光灯！")
    }
    func segue() {
        self.dismissViewControllerAnimated(true, completion: nil)
        if self.onImageCompletion != nil {
            onImageCompletion?(nil,nil)
        }
        else {
            self.onCompletion?(nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timer1 = NSTimer(timeInterval: 6.0, target: self, selector: "tipsForFlash", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer1, forMode: NSDefaultRunLoopMode)
        timer2 = NSTimer(timeInterval: 10.0, target: self, selector: "segue", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer2, forMode: NSDefaultRunLoopMode)
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer1.invalidate()
        timer1 = nil
        timer2.invalidate()
        timer2 = nil
        super.viewWillDisappear(animated)
        //self.scanner.stopScan()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addButtons()
    }
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if self.onImageCompletion != nil {
            onImageCompletion?(arrayResult[0].strScanned,arrayResult[0].imgScanned)
        }
        else {
            onCompletion?(arrayResult[0].strScanned)
        }
    }

      // MARK: 添加下方的操作按钮
     func addButtons() {
        recordButton.addTarget(self, action: "showRecord", forControlEvents: .TouchUpInside)
        closeButton.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
        flashButton.addTarget(self, action: "toggleFlash", forControlEvents: .TouchUpInside)
        layoutButtons()
        //添加提示信息
        let scanSize = (min(screenWidth, screenHeight) * 7) / 10
        var scanRect = CGRectMake(0, 0, scanSize, scanSize)
        scanRect.origin.x += (screenWidth / 2) - (scanRect.size.width / 2)
        scanRect.origin.y += ((screenHeight - 85) / 2) - (scanRect.size.height / 2)
        
        let tipsLable = UILabel()
        tipsLable.text = "取景框内保持二维码"
        tipsLable.textColor = UIColor.redColor()
        tipsLable.textAlignment = .Center
        tipsLable.numberOfLines = 0
        tipsLable.font = UIFont(descriptor: UIFontDescriptor(), size: 20)
        tipsLable.frame.size = CGSize(width: scanRect.size.width, height: 50)
        if screenHeight < 480 && UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            tipsLable.frame.size = CGSize(width: scanRect.size.width, height: 30)
            verticalPadding = 5
        }
        
        tipsLable.frame.origin = CGPointMake(scanRect.origin.x, scanRect.origin.y + scanRect.size.height + 10 )
        view.addSubview(tipsLable)

    }
    func layoutButtons() {
        closeButton.setImage(UIImage(named: "closeButton", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Normal)
        recordButton.setImage(UIImage(named: "libraryButton", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Normal)
        flashButton.setImage(UIImage(named: "flashOffIcon", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Normal)
        
        closeButton.sizeToFit()
        flashButton.sizeToFit()
        recordButton.sizeToFit()
        
        view.addSubview(closeButton)
        view.addSubview(recordButton)
        view.addSubview(flashButton)
        setButtonsFrame()
    }
    private func setButtonsFrame() {
        let size = view.frame.size
        
        let cameraSize = flashButton.frame.size
        let cameraX = size.width/2 - cameraSize.width/2
        let cameraY = size.height - (cameraSize.height + verticalPadding)
        flashButton.frame.origin = CGPointMake(cameraX, cameraY)
        
        let closeSize = closeButton.frame.size
        let closeX = horizontalPadding
        let closeY = cameraY + (cameraSize.height - closeSize.height)/2
        
        closeButton.frame.origin = CGPointMake(closeX, closeY)
        closeButton.alpha = 1
        
        let recordSize = recordButton.frame.size
        let recordX = size.width - (recordSize.width + horizontalPadding)
        let recordY = closeY
        
        recordButton.frame.origin = CGPointMake(recordX, recordY)
        recordButton.alpha = 1
        
     }
    
     internal func close() {
        self.dismissViewControllerAnimated(true, completion:nil )
    }
   
    internal func showRecord() {
        self.dismissViewControllerAnimated(true, completion:nil )
        if self.onImageCompletion != nil {
            onImageCompletion?("recordBtnClick",nil)
        }
        else {
            onCompletion?("recordBtnClick")
        }
    }

    internal func toggleFlash() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                    toggleFlashButton(false)
                } else {
                    try device.setTorchModeOnWithLevel(AVCaptureMaxAvailableTorchLevel)
                    toggleFlashButton(true)
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    internal func toggleFlashButton(on: Bool) {
        var imageName = "flashOffIcon"
        if on {
            imageName = "flashOnIcon"
        }
        flashButton.setImage(UIImage(named: imageName, inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Normal)
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}



