//
//  AutoCompleteTextField.swift
//  AutocompleteTextfieldSwift
//
//  Created by Mylene Bayan on 6/13/15.
//  Copyright (c) 2015 MaiLin. All rights reserved.
//

import Foundation
import UIKit
public class AutoCompleteTextField:UITextField, UITableViewDataSource, UITableViewDelegate{
    /// Manages the instance of tableview
    private var autoCompleteTableView:UITableView?
    /// Holds the collection of attributed strings
    private var attributedAutoCompleteStrings:[NSAttributedString]?
    /// Handles user selection action on autocomplete table view
    public var onSelect:(String, NSIndexPath)->() = {_,_ in}
    /// Handles textfield's textchanged
    public var onTextChange:(String)->() = {_ in}
    
    /// Font for the text suggestions
    public var autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12)
    /// Color of the text suggestions
    public var autoCompleteTextColor = UIColor.blackColor()    /// Used to set the height of cell for each suggestions
    public var autoCompleteCellHeight:CGFloat = 35
    /// The maximum visible suggestion
    public var maximumAutoCompleteCount = 3
    /// Used to set your own preferred separator inset
    public var autoCompleteSeparatorInset = UIEdgeInsetsZero
    /// Shows autocomplete text with formatting
    public var enableAttributedText = true
    /// User Defined Attributes
    public var autoCompleteAttributes:[String:AnyObject] = [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size: 12)!]
    // Hides autocomplete tableview after selecting a suggestion
    public var hidesWhenSelected = true
    //MARK:字符串存入数据库索引
    public var indexStr = ""
    //MARK:数据库索引查询出的所有字符串数组
    public var allStrings:[String]?
    /// Hides autocomplete tableview when the textfield is empty
    public var hidesWhenEmpty:Bool = true {
        didSet{
            autoCompleteTableView?.hidden = hidesWhenEmpty
        }
    }
    /// The table view height
    public var autoCompleteTableHeight:CGFloat?{
        didSet{
            redrawTable()
        }
    }
    public var autoCompleteViewWidth:CGFloat?{
        didSet{
            redrawTable()
        }
    }
    /// The strings to be shown on as suggestions, setting the value of this automatically reload the tableview
    public var autoCompleteStrings:[String]?{
        didSet{ reload() }
    }
    
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupAutocompleteTable(superview!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        setupAutocompleteTable(superview!)
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        commonInit()
        setupAutocompleteTable(newSuperview!)
    }
    
    public override func resignFirstResponder() -> Bool {
        self.autoCompleteTableView?.hidden = true
        autoSave()
        return super.resignFirstResponder()
    }
    
    //MARK: - UITableViewDataSource
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteStrings != nil ? (autoCompleteStrings!.count > maximumAutoCompleteCount ? maximumAutoCompleteCount : autoCompleteStrings!.count) : 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "autocompleteCellIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        if enableAttributedText{
            cell?.textLabel?.attributedText = attributedAutoCompleteStrings![indexPath.row]
        }
        else{
            cell?.textLabel?.font = autoCompleteTextFont
            //cell?.textLabel?.textColor = autoCompleteTextColor
            cell?.textLabel?.textColor = UIColor.whiteColor()
            cell?.textLabel?.text = autoCompleteStrings![indexPath.row]
        }
        cell?.backgroundColor = UIColor.grayColor()
        return cell!
    }
    
    //MARK: - UITableViewDelegate
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let selectedText = cell!.textLabel!.text!
        self.text = selectedText;
        
        onSelect(selectedText, indexPath)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            tableView.hidden = self.hidesWhenSelected
        })
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector("setSeparatorInset:"){
            cell.separatorInset = autoCompleteSeparatorInset}
        if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:"){
            cell.preservesSuperviewLayoutMargins = false}
        if cell.respondsToSelector("setLayoutMargins:"){
            cell.layoutMargins = autoCompleteSeparatorInset}
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return autoCompleteCellHeight
    }
    
    //MARK: - Private Interface
    private func reload(){
        if enableAttributedText{
            let attrs = [NSForegroundColorAttributeName:autoCompleteTextColor, NSFontAttributeName:UIFont.systemFontOfSize(12.0)]
            if attributedAutoCompleteStrings == nil{
                attributedAutoCompleteStrings = [NSAttributedString]()
            }
            else{
                if attributedAutoCompleteStrings?.count > 0 {
                    attributedAutoCompleteStrings?.removeAll(keepCapacity: false)
                }
            }
            
            if autoCompleteStrings != nil{
                for i in 0..<autoCompleteStrings!.count{
                    let str = autoCompleteStrings![i] as NSString
                    let range = str.rangeOfString(text!, options: .CaseInsensitiveSearch)
                    let attString = NSMutableAttributedString(string: autoCompleteStrings![i], attributes: attrs)
                    attString.addAttributes(autoCompleteAttributes, range: range)
                    attributedAutoCompleteStrings?.append(attString)
                }
            }
        }
        autoCompleteTableView?.reloadData()
    }
    
    private func commonInit(){
        hidesWhenEmpty = true
        autoCompleteAttributes = [NSForegroundColorAttributeName:UIColor.blackColor()]
        autoCompleteAttributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12)
        self.clearButtonMode = .Always
        self.addTarget(self, action: "textFieldDidChange", forControlEvents: .EditingChanged)
    }
    
    private func setupAutocompleteTable(view:UIView){
        //let screenSize = UIScreen.mainScreen().bounds.size
        //let tableView = UITableView(frame: CGRectMake(self.frame.origin.x, self.frame.origin.y + CGRectGetHeight(self.frame) - 4 , screenSize.width - (self.frame.origin.x * 2), 30.0))
        let tableView = UITableView(frame: CGRectMake(self.frame.origin.x, self.frame.origin.y + CGRectGetHeight(self.frame) - 1 , self.frame.size.width, 35.0))
        //let tableView = UITableView(frame: CGRectMake(self.frame.origin.x, self.frame.origin.y + CGRectGetHeight(self.frame), autoCompleteViewWidth, 30.0))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = autoCompleteCellHeight
        tableView.hidden = hidesWhenEmpty ?? true
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 4
        tableView.backgroundColor = UIColor.grayColor()
        view.addSubview(tableView)
        view.bringSubviewToFront(tableView)
        autoCompleteTableView = tableView
        autoCompleteTableHeight = 105
        
        
    }
    
    private func redrawTable(){
        if autoCompleteTableView != nil{
            var newFrame = autoCompleteTableView!.frame
            newFrame.size.height = autoCompleteTableHeight!
            newFrame.size.width = self.frame.size.width
            autoCompleteTableView!.frame = newFrame
//            if autoCompleteViewWidth != nil {
//            //newFrame.size.width = autoCompleteViewWidth!
//            autoCompleteTableView!.frame = newFrame
//            }
        }
    }
    
    //MARK: - Internal
    func textFieldDidChange(){
        onTextChange(text!)
        sortStringsByLocal()
        if text!.isEmpty{ autoCompleteStrings = nil }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.autoCompleteTableHeight = self.autoCompleteStrings != nil ? self.autoCompleteCellHeight * CGFloat(self.autoCompleteStrings!.count) : 0
            self.autoCompleteTableView?.hidden =  self.hidesWhenEmpty ? self.text!.isEmpty : false
        })
    }
    //MARK:自动将输入的字符串保存
    func autoSave(){
        let dbHandle = HYDbAutoTextField()
         dbHandle.insert(self.text!, indexString: self.indexStr)
    }
    func getAutoStringsFromDb() {
        let dbHandle = HYDbAutoTextField()
        self.allStrings = dbHandle.getStringsForIndexStr(self.indexStr, andText: self.text!)
    }
    func sortStringsByLocal() {
        if allStrings == nil {
            getAutoStringsFromDb()
        }
        self.autoCompleteStrings = cutStrings(HYHandler.sortStrings(self.allStrings!, text: self.text!))
    }
    func cutStrings(Strings:[String])->[String]{
        var newStrings:[String] = []
        if Strings.count > self.maximumAutoCompleteCount {
            for var i = 0 ; i < self.maximumAutoCompleteCount ; i++ {
                newStrings.append(Strings[i])
            }
            return newStrings
        }
        else {
            return Strings
        }
    }
    //public func setAutoViewWidth()
}