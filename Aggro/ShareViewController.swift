//
//  ShareViewController.swift
//  Aggro
//
//  Created by Yetkin Timocin on 23/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController, UITextFieldDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    var alertController: UIAlertController!
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var badgeSelection: UIButton!
    @IBOutlet weak var userText2BeShared: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mediaSelectionButton: UIButton!
    @IBOutlet weak var tripSelectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        tapRecognizer?.numberOfTapsRequired = 1
        
        //button?.layer.borderColor = UIColor.darkGrayColor().CGColor
        //button?.layer.borderWidth = 2.0
        // constraint leri bozuyor!!!
        //userAvatar.layer.borderColor = UIColor.blackColor().CGColor
        //userAvatar.layer.borderWidth = 1.0
        
        //badgeSelection.layer.borderColor = UIColor.blackColor().CGColor
        //badgeSelection.layer.borderWidth = 1.0
        
        checkBadgeSelectionButton()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
        self.checkBadgeSelectionButton()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
    }
    
    @IBAction func badgeSelection(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ShareBadgeSelectionViewController")
            
            self.presentViewController(controller, animated: true, completion: nil)
            
        })
    }
    
    func checkBadgeSelectionButton() {
        let selectedShareBadge = AggroApiClient.sharedInstance().selectedShareBadge
        if selectedShareBadge != "" {
            if selectedShareBadge == "0" {
                badgeSelection.setImage(UIImage(named: "three-dots"), forState: UIControlState.Normal)
            } else {
                let badge: AggroBadge = self.getBadge(selectedShareBadge)
                badgeSelection.setImage(UIImage(named: "\(badge.image!)"), forState: UIControlState.Normal)
            }
        } else if selectedShareBadge == "" {
            badgeSelection.setImage(UIImage(named: "exclamation-mark"), forState: UIControlState.Normal)
        } else if AggroApiClient.sharedInstance().aggroUser.badges?.count == 1 {
            let aggroUserBadgeID: String = AggroApiClient.sharedInstance().aggroUser.badges!.first!
            let badge: AggroBadge = self.getBadge(aggroUserBadgeID)
            badgeSelection.setImage(UIImage(named: "\(badge.image!)"), forState: UIControlState.Normal)
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
    
    @IBAction func cancelView(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
