//
//  BadgeSelectionTableViewController.swift
//  Aggro
//
//  Created by Yetkin Timocin on 23/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import UIKit

class BadgeSelectionTableViewController: UITableViewController {
    
    @IBOutlet weak var skipOrAddBadgesButton: UIButton!
    @IBOutlet weak var badgeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTable", name: "badgeDataUpdated", object: nil)
        
        // Set our source and add the tableview to the view
        badgeTableView.delegate = self
        badgeTableView.dataSource = self
        self.view.addSubview(badgeTableView)
        
        if (AggroApiBadges.sharedInstance().badges.count == 0) {
            loadData()
        } else {
            updateTable()
        }
        
    }
    
    @IBAction func skipOrAddBadges(sender: UIButton) {
        if selectedBadges.count > 0 {
            AggroApiClient.sharedInstance().addBadges(selectedBadges) { (result, error) in
                if result == 0 {
                    self.goTo("AggroHomeViewController")
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showErrorView("Error Adding Badges")
                    })
                }
            }
        } else {
            self.goTo("AggroHomeViewController")
        }
    }
    
    func goTo(controllerName: String) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("\(controllerName)")
            
            self.presentViewController(controller, animated: true, completion: nil)
            
        })
    }
    
    func showErrorView(message: String) {
        
        let alertController = UIAlertController(title: message, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        }
        alertController.addAction(okAction)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Table View and Data Source Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AggroApiBadges.sharedInstance().badges.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = badgeTableView.dequeueReusableCellWithIdentifier("badgeCell") as UITableViewCell!
        let badge = AggroApiBadges.sharedInstance().badges[indexPath.row]
        
        cell.textLabel?.text = badge.name! + " (\(badge.users!) users - \(badge.posts!) posts)"
        
        let image : UIImage = UIImage(named: "\(badge.image!)")!
        cell.imageView!.image = image
        
        if cell.selected {
            selectedBadges.append(badge.badgeID!)
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let badge = AggroApiBadges.sharedInstance().badges[indexPath.row]
        
        if cell!.selected == true {
            if !selectedBadges.contains(badge.badgeID!) {
                selectedBadges.append(badge.badgeID!)
            }
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell!.accessoryType = UITableViewCellAccessoryType.None
        }
        
        if selectedBadges.count > 1 {
            skipOrAddBadgesButton.setTitle("add badges", forState: .Normal)
        } else if selectedBadges.count > 0 {
            skipOrAddBadgesButton.setTitle("add badge", forState: .Normal)
        } else {
            skipOrAddBadgesButton.setTitle("skip", forState: .Normal)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let badge = AggroApiBadges.sharedInstance().badges[indexPath.row]
        
        if cell!.selected == true {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            if selectedBadges.contains(badge.badgeID!) {
                selectedBadges.removeAtIndex(selectedBadges.indexOf(badge.badgeID!)!)
            }
            cell!.accessoryType = UITableViewCellAccessoryType.None
        }
        
        if selectedBadges.count > 1 {
            skipOrAddBadgesButton.setTitle("add badges", forState: .Normal)
        } else if selectedBadges.count > 0 {
            skipOrAddBadgesButton.setTitle("add badge", forState: .Normal)
        } else {
            skipOrAddBadgesButton.setTitle("skip for now", forState: .Normal)
        }
    }
    
    func loadData() {
        
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
    
    func updateTable() {
        self.badgeTableView.reloadData()
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
