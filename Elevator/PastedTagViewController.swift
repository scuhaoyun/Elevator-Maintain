//
//  PastedTagViewController.swift
//  Elevator
//
//  Created by 郝赟 on 16/3/10.
//  Copyright © 2016年 haoyun. All rights reserved.
//

import UIKit

class PastedTagViewControlelr : UIViewController,UITableViewDelegate,UITableViewDataSource,HYBottomToolBarButtonClickDelegate{
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var tagTableView: UITableView!
    @IBOutlet weak var bottomToolBar: UIView!
    var pastedTags:[PastedTag] = []
    var searchAddress = ""
    var searchBuildingName = ""
    override func viewDidLoad() {
        tagTableView.delegate = self
        tagTableView.dataSource = self
        loadToolBar()
        setExtraCellLineHidden()
    }
    override func viewWillAppear(animated: Bool) {
        self.addressLabel.text = self.searchAddress
        self.buildingNameLabel.text = self.searchBuildingName
        //tagTableView.reloadData()
    }
    /**
     *tableView所需实现的协议方法
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastedTags.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "PastedTagCell"
        var cell  = tagTableView.dequeueReusableCellWithIdentifier(identifier)
        if cell == nil {
            var array = NSBundle.mainBundle().loadNibNamed("PastedTagCell", owner: self, options: nil)
            let newCell = array[0] as! PastedTagCell
            newCell.pastedTag = pastedTags[indexPath.row]
            cell = newCell
        }
        
        return cell!
    }
    /**
     *  自定义函数
     */
    func loadToolBar(){
        var array = NSBundle.mainBundle().loadNibNamed("HYBottomToolBar", owner: self, options: nil) as! [HYBottomToolBar]
        let newToolBar = array[0]
        newToolBar.delegate = self
        newToolBar.frame.size = bottomToolBar.frame.size
        newToolBar.frame.origin = CGPoint(x: 0, y: 0)
        newToolBar.firstButton.setTitle("返回", forState: UIControlState.Normal)
        newToolBar.secondButton.hidden = true
        bottomToolBar.addSubview(newToolBar)
    }
    func toolBarButtonClicked(sender: UIButton) {
    }
    func setExtraCellLineHidden(){
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        tagTableView.tableFooterView = view
    }
}
