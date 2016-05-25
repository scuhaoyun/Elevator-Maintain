//
//  HelpViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/24.
//  Copyright © 2016年 haoyun. All rights reserved.
//

class HelpViewController:UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    @IBAction func backBtnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
       detailLabel.numberOfLines = 0
       updateConstrains()
    }
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateConstrains", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        
    }
    func updateConstrains(){
        let labelStr:NSString = detailLabel.text!
        let labelsize = labelStr.textSizeWithFont(UIFont.systemFontOfSize(17), constrainedToSize: CGSize(width:UIScreen.mainScreen().bounds.size.width, height: CGFloat(MAXFLOAT)))
        containerViewHeight.constant = labelsize.height
    }
}
extension NSString {
    func textSizeWithFont(font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        if CGSizeEqualToSize(size, CGSizeZero) {
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
            textSize = self.sizeWithAttributes(attributes as? [String : AnyObject])
        } else {
            let option = NSStringDrawingOptions.UsesLineFragmentOrigin
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
            let stringRect = self.boundingRectWithSize(size, options: option, attributes: attributes as? [String : AnyObject], context: nil)
            textSize = stringRect.size
        }
        return textSize
    }
}