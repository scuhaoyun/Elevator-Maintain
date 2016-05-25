//
//  ALCameraViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/17.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

public typealias ALCameraViewCompletion = (UIImage?) -> Void

public extension ALCameraViewController {
    public class func imagePickerViewController(croppingEnabled: Bool, completion: ALCameraViewCompletion) -> UINavigationController {
        let imagePicker = ALImagePickerViewController()
        let navigationController = UINavigationController(rootViewController: imagePicker)
        
        navigationController.navigationBar.barTintColor = UIColor.blackColor()
        navigationController.navigationBar.barStyle = UIBarStyle.Black
        
        imagePicker.onSelectionComplete = { image in
            if image != nil {
                let confirmController = ALConfirmViewController(image: image!, allowsCropping: croppingEnabled)
                confirmController.onComplete = { image in
                    if let i = image {
                        completion(i)
                    } else {
                        imagePicker.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                confirmController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                imagePicker.presentViewController(confirmController, animated: true, completion: nil)
            } else {
                completion(nil)
            }
        }
        
        imagePicker.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "libraryCancel", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: imagePicker, action: "dismiss")
        
        return navigationController
    }
    
    public class func croppingViewController(image: UIImage, croppingEnabled: Bool, completion: ALCameraViewCompletion) -> UIViewController {
        let cropper = ALConfirmViewController(image: image, allowsCropping: croppingEnabled)
        cropper.onComplete = completion
        return cropper
    }
}

public class ALCameraViewController: UIViewController {
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let cameraView = ALCameraView()
    let cameraOverlay = ALCropOverlay()
    let cameraButton = UIButton()
    
    let closeButton = UIButton()
    let libraryButton = UIButton()
    let flashButton = UIButton()
    
    var onCompletion: ALCameraViewCompletion?
    var allowCropping = false
    
    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    var cropSize = CGSizeMake(250, 70)
    public init(croppingEnabled: Bool, allowsLibraryAccess: Bool = true, completion: ALCameraViewCompletion) {
        super.init(nibName: nil, bundle: nil)
        onCompletion = completion
        allowCropping = croppingEnabled
        libraryButton.enabled = allowsLibraryAccess
        libraryButton.hidden = !allowsLibraryAccess
        commonInit()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        view.addSubview(cameraView)
        
        
        if allowCropping {
            let shadowView = makeScanCameraShadowView(layoutCropView())
            self.view.addSubview(shadowView)
        }
        
        cameraView.frame = view.bounds
        
        rotate()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkPermissions()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        cameraView.frame = view.bounds
        cameraEndState()
    }
    
    internal func rotate() {
        let rotation = currentRotation()
        let rads = CGFloat(radians(rotation))
        
        UIView.animateWithDuration(0.3) {
            self.cameraButton.transform = CGAffineTransformMakeRotation(rads)
            self.closeButton.transform = CGAffineTransformMakeRotation(rads)
            self.libraryButton.transform = CGAffineTransformMakeRotation(rads)
        }
    }
    
    private func commonInit() {
        if UIScreen.mainScreen().bounds.size.width <= 320 {
            verticalPadding = 15
            horizontalPadding = 15
        }
    }

    private func checkPermissions() {
        if AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == AVAuthorizationStatus.Authorized {
            startCamera()
        } else {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted == true {
                        self.startCamera()
                    } else {
                        self.showNoPermissionsView()
                    }
                }
            }
        }
    }
    
    private func showNoPermissionsView() {
        let permissionsView = ALPermissionsView(frame: view.bounds)
        view.addSubview(permissionsView)
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.setImage(UIImage(named: "retakeButton", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        closeButton.sizeToFit()
        
        let size = view.frame.size
        let closeSize = closeButton.frame.size
        let closeX = horizontalPadding
        let closeY = size.height - (closeSize.height + verticalPadding)
        
        closeButton.frame.origin = CGPointMake(closeX, closeY)
    }
    
    private func startCamera() {
        cameraView.startSession()
        cameraButton.addTarget(self, action: "capturePhoto", forControlEvents: .TouchUpInside)
        libraryButton.addTarget(self, action: "showLibrary", forControlEvents: .TouchUpInside)
        closeButton.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
        flashButton.addTarget(self, action: "toggleFlash", forControlEvents: .TouchUpInside)
        layoutCamera()
    }
    func makeScanCameraShadowView(innerRect: CGRect) -> UIView {
        let referenceImage = UIImageView(frame: self.view.bounds)
        
        UIGraphicsBeginImageContext(referenceImage.frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.5)
        var drawRect = CGRectMake(0, 0, screenWidth, screenHeight)
        CGContextFillRect(context, drawRect)
        drawRect = CGRectMake(innerRect.origin.x - referenceImage.frame.origin.x, innerRect.origin.y - referenceImage.frame.origin.y, innerRect.size.width, innerRect.size.height)
        CGContextClearRect(context, drawRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        referenceImage.image = image
        
        return referenceImage
    }

    private func layoutCropView()-> CGRect {
        let scanSize = (min(screenWidth, screenHeight) * 7) / 10
        var scanRect = CGRectMake(0, 0, scanSize, scanSize / 3 )
        
        scanRect.origin.x += (screenWidth / 2) - (scanRect.size.width / 2)
        scanRect.origin.y += (screenHeight / 2) - scanRect.size.height
    
        view.addSubview(cameraOverlay)
        cameraOverlay.frame = scanRect
        
        //添加提示信息
        let tipsLable = UILabel()
        tipsLable.text = "请将标牌编号\n完整套入框内"
        tipsLable.textColor = UIColor.greenColor()
        tipsLable.textAlignment = .Center
        tipsLable.numberOfLines = 0
        tipsLable.font = UIFont(descriptor: UIFontDescriptor(), size: 20)
        tipsLable.frame.size = cropSize
        tipsLable.frame.origin = CGPointMake(scanRect.origin.x, scanRect.origin.y - scanRect.size.height)
        view.addSubview(tipsLable)
        return scanRect
    }
    
    private func layoutCamera() {
        
        cameraButton.setImage(UIImage(named: "cameraButton", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Normal)
        cameraButton.setImage(UIImage(named: "cameraButtonHighlighted", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Highlighted)

        closeButton.setImage(UIImage(named: "closeButton", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Normal)
        libraryButton.setImage(UIImage(named: "libraryButton", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Normal)
        flashButton.setImage(UIImage(named: "flashOffIcon", inBundle: NSBundle(forClass: ALCameraViewController.self), compatibleWithTraitCollection: nil), forState: .Normal)
        
        cameraButton.sizeToFit()
        closeButton.sizeToFit()
        libraryButton.sizeToFit()
        flashButton.sizeToFit()
        
        view.addSubview(cameraButton)
        view.addSubview(libraryButton)
        view.addSubview(closeButton)
        view.addSubview(flashButton)
        
        cameraButton.enabled = true
        cameraEndState()
    }
    
    private func cameraEndState() {
        let size = view.frame.size
        
        let cameraSize = cameraButton.frame.size
        let cameraX = size.width/2 - cameraSize.width/2
        let cameraY = size.height - (cameraSize.height + verticalPadding)
        
        cameraButton.frame.origin = CGPointMake(cameraX, cameraY)
        cameraButton.alpha = 1
        
        let closeSize = closeButton.frame.size
        let closeX = horizontalPadding
        let closeY = cameraY + (cameraSize.height - closeSize.height)/2
        
        closeButton.frame.origin = CGPointMake(closeX, closeY)
        closeButton.alpha = 1
        
        let librarySize = libraryButton.frame.size
        let libraryX = size.width - (librarySize.width + horizontalPadding)
        let libraryY = closeY
        
        libraryButton.frame.origin = CGPointMake(libraryX, libraryY)
        libraryButton.alpha = 1
        
        let flashX = libraryX
        let flashY = verticalPadding
        
        flashButton.frame.origin = CGPointMake(flashX, flashY)
    }
    
    internal func capturePhoto() {
        cameraButton.enabled = false
        cameraView.capturePhoto { image in
            self.layoutCameraResult(image)
        }
    }
    
    internal func close() {
        self.dismissViewControllerAnimated(true, completion:nil )
        onCompletion?(nil)
        
        
    }
    
    internal func showLibrary() {
        let tagStoryboard = UIStoryboard(name:"Record", bundle: nil)
        let  tagRecordViewController = tagStoryboard.instantiateViewControllerWithIdentifier("TagRecordViewController") as! TagRecordViewController
        self.showViewController(tagRecordViewController, sender: self)
    }
    
    internal func onConfirmComplete(image: UIImage?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //MARK:修改过 加了self.
        onCompletion?(image)
        
        
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
        
    internal func layoutCameraResult(image: UIImage) {
        cameraView.stopSession()
        let cropFrame = cameraOverlay.frame
        var croppedImage: UIImage? = nil
        if self.allowCropping {
            croppedImage = image.crop(cropFrame, scale: screenHeight / image.size.height )
        }
        else {
            croppedImage = image
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        self.onCompletion?(croppedImage)
        
//        let confirmViewController = ALConfirmViewController(image: croppedImage!, allowsCropping: false)
//        confirmViewController.onComplete = { image in
//            if image == nil {
//                self.onCompletion?(nil)
//            } else {
//                self.onCompletion?(image)
//                self.dismissViewControllerAnimated(true, completion: nil)
//            }
//            
//        }
//        confirmViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
//        
//        self.presentViewController(confirmViewController, animated: true, completion: nil)
    }
    override public func shouldAutorotate() -> Bool {
        return false
    }

}
