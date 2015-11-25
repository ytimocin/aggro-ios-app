//
//  BadgeSelectionTableViewController.swift
//  Aggro
//
//  Created by Yetkin Timocin on 23/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import UIKit

class ShareBadgeSelectionViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    var alertController: UIAlertController!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var selectedBadge: String? = ""
    var lastSelectedIndexPath: NSIndexPath? = nil
    var badges2Show: [String] = [String]()
    
    @IBOutlet weak var badgeTableView: UITableView!
    @IBOutlet weak var cancelOrSelectShareBadge: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTable", name: "badgeDataUpdated", object: nil)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        tapRecognizer?.numberOfTapsRequired = 1
        
        // Set our source and add the tableview to the view
        badgeTableView.delegate = self
        badgeTableView.dataSource = self
        self.view.addSubview(badgeTableView)
        
        if AggroApiBadges.sharedInstance().badges.count == 0 {
            loadAggroBadges()
        } else {
            updateTable()
        }
        
        if AggroApiClient.sharedInstance().selectedShareBadge != "" {
            selectedBadge = AggroApiClient.sharedInstance().selectedShareBadge
        }
        
    }
    
    @IBAction func cancelOrSelectShareBadge(sender: UIButton) {
        if selectedBadge != "" {
            AggroApiClient.sharedInstance().selectedShareBadge = selectedBadge!
        }
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func updateTable() {
        self.badgeTableView.reloadData()
    }
    
    // MARK: - Table View and Data Source Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.badges2Show = AggroApiClient.sharedInstance().aggroUser.badges!
        self.badges2Show.append("0")
        return badges2Show.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = badgeTableView.dequeueReusableCellWithIdentifier("badgeCell") as UITableViewCell!
        let badgeID: String = badges2Show[indexPath.row]
        var badgeForCell: AggroBadge = AggroBadge()
        var cellText: String
        if badgeID == "0" {
            badgeForCell.name = "other"
            badgeForCell.image = "three-dots"
            cellText = badgeForCell.name!
        } else {
            badgeForCell = self.getBadge(badgeID)
            cellText = badgeForCell.name! + " (\(badgeForCell.users!) users - \(badgeForCell.posts!) posts)"
        }
        
        if badgeID == selectedBadge {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        cell.textLabel?.text = cellText
        let cellImage: UIImage = UIImage(named: "\(badgeForCell.image!)")!
        cell.imageView!.image = cellImage
        
        if indexPath.row != lastSelectedIndexPath {
            if let lastSelectedIndexPath = lastSelectedIndexPath {
                let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
                oldCell?.accessoryType = UITableViewCellAccessoryType.None
            }
            
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            lastSelectedIndexPath = indexPath
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row != lastSelectedIndexPath {
            if let lastSelectedIndexPath = lastSelectedIndexPath {
                let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
                badgeTableView.deselectRowAtIndexPath(lastSelectedIndexPath, animated: true)
                oldCell?.accessoryType = UITableViewCellAccessoryType.None
            }
            
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            lastSelectedIndexPath = indexPath
        }
        
        selectedBadge = badges2Show[indexPath.row]
        
        if selectedBadge != "" {
            cancelOrSelectShareBadge.setImage(UIImage(named: "checkmark-green"), forState: UIControlState.Normal)
        } else {
            cancelOrSelectShareBadge.setImage(UIImage(named: "cancel-red"), forState: UIControlState.Normal)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        badgeTableView.deselectRowAtIndexPath(indexPath, animated: true)
        cell?.accessoryType = UITableViewCellAccessoryType.None
        
        selectedBadge = ""
        
        if selectedBadge != "" {
            cancelOrSelectShareBadge.setImage(UIImage(named: "checkmark-green"), forState: UIControlState.Normal)
        } else {
            cancelOrSelectShareBadge.setImage(UIImage(named: "cancel-red"), forState: UIControlState.Normal)
        }
    }
    
    func getBadge(badgeID: String) -> AggroBadge {
        var aggroBadge: AggroBadge = AggroBadge()
        
        for badge in AggroApiBadges.sharedInstance().badges {
            if badgeID == badge.badgeID {
                aggroBadge = badge
                break
            }
        }
        return aggroBadge
    }
    
    func loadAggroBadges() {
        
        AggroApiBadges.sharedInstance().badges.removeAll()
        
        let serialQueue = dispatch_queue_create("com.aggro.api", DISPATCH_QUEUE_SERIAL)
        
        let skips = [0, 100]
        for skip in skips {
            dispatch_sync( serialQueue ) {
                
                AggroApiClient.sharedInstance().getAggroBadges(skip) { badges, error in
                    if let badges = badges {
                        AggroApiBadges.sharedInstance().badges.appendContentsOf(badges)
                        
                        if badges.count > 0 {
                            dispatch_async(dispatch_get_main_queue()) {
                                NSNotificationCenter.defaultCenter().postNotificationName("badgeDataUpdated", object: nil)
                            }
                        }
                        
                    } else {
                        
                        let title: String =  "yeko"
                        let alertController = UIAlertController(title: title, message: error!.localizedDescription,
                            preferredStyle: .Alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        }
                        alertController.addAction(okAction)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                        
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
    }
    
    //#MARK: - Textfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(/*textField == linkTextField && */textField.text == "") {
            textField.text = ""
        }
    }
    
    //#MARK:- Keyboard Fixes & Notifications
    
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap() {
        view.endEditing(true)
    }
    
}
