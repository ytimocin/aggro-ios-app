//
//  WelcomeViewController.swift
//  Aggro
//
//  Created by Yetkin Timocin on 16/09/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* to support smaller resolution devices */
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let placeHolderTextColor: UIColor = UIColor.whiteColor()
        
        userEmail.attributedPlaceholder = NSAttributedString(string: "Email",
            attributes: [NSForegroundColorAttributeName:placeHolderTextColor])
        userEmail.delegate = self
        
        userPassword.attributedPlaceholder = NSAttributedString(string: "Password",
            attributes: [NSForegroundColorAttributeName:placeHolderTextColor])
        userPassword.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        tapRecognizer?.numberOfTapsRequired = 1
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardDismissRecognizer()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardDismissRecognizer()
        self.unsubscribeToKeyboardNotifications()
    }
    
    @IBAction func userLoginButtonTouchUp(sender: UIButton) {
        
        self.view.endEditing(true)
        
        if userEmail.text!.isEmpty {
            
            self.showErrorView("Email Empty!")
            
        } else if userPassword.text!.isEmpty {
            
            self.showErrorView("Password Empty!")
            
        } else {
            
            performLogin(userEmail.text!, password: userPassword.text!)
            
        }
        
    }
    
    @IBAction func forgotPasswordButtonTouchUp(sender: UIButton) {
        
    }
    
    @IBAction func signUpButtonTouchUp(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("RegisterViewController")
            
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
    
    func performLogin(email: String, password: String) {
        
        AggroApiClient.sharedInstance().login(email, password: password) { (aggroApiLoginResponse, error) in
            
            if aggroApiLoginResponse?.loginResponseCode == 0 {
                
                self.completeLogin()
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showErrorView((aggroApiLoginResponse?.loginResponseDesc)!)
                })
            }
        }
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AggroHomeViewController")
                as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
            
        })
    }
    
    @IBAction func forgotCredentials(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ForgotPasswordViewController")
            
            self.presentViewController(controller, animated: true, completion: nil)
            
        })
    }
    
    
    //#MARK:- Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //#MARK:- Keyboard Fixes & Notifications
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap() {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y = -lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide() {
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y = 0
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
}
