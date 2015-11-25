//
//  RegisterViewController.swift
//  Aggro
//
//  Created by Yetkin Timocin on 20/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var activityIndicator: UIActivityIndicatorView!
    var alertController: UIAlertController!
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let placeHolderTextColor: UIColor = UIColor.whiteColor()
        
        usernameField.attributedPlaceholder = NSAttributedString(string: "Username",
            attributes: [NSForegroundColorAttributeName:placeHolderTextColor])
        usernameField.delegate = self
        
        emailField.attributedPlaceholder = NSAttributedString(string: "Email",
            attributes: [NSForegroundColorAttributeName:placeHolderTextColor])
        emailField.delegate = self
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password",
            attributes: [NSForegroundColorAttributeName:placeHolderTextColor])
        passwordField.delegate = self
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
    }
    
    @IBAction func registerUpButtonTouchUp(sender: UIButton) {
        
        self.view.endEditing(true)
        
        if usernameField.text!.isEmpty {
            
            self.showErrorView("Username Empty!")
            
        } else if emailField.text!.isEmpty {
            
            self.showErrorView("Email Empty!")
            
        } else if passwordField.text!.isEmpty {
            
            self.showErrorView("Password Empty!")
            
        } else {
            
            performRegister(usernameField.text!, email: emailField.text!, password: passwordField.text!)
            
        }
        
    }
    
    func performRegister(username: String, email: String, password: String) {
        
        AggroApiClient.sharedInstance().register(username, email: email, password: password) { (aggroApiRegisterResponse, error) in
            
            if aggroApiRegisterResponse?.registerResponseCode == 0 {
                
                self.completeRegister()
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.showErrorView((aggroApiRegisterResponse?.registerResponseDesc)!)
                })
            }
        }
    }
    
    func completeRegister() {
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("BadgeSelectionViewController")
            
            self.presentViewController(controller, animated: true, completion: nil)
            
        })
    }
    
    @IBAction func cancelSignUpButtonTouchUp(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
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
