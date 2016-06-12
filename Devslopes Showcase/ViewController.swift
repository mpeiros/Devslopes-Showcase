//
//  ViewController.swift
//  Devslopes Showcase
//
//  Created by Max Peiros on 6/1/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with Facebook. \(accessToken)")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in! \(user)")
                        
                        let userData = ["provider": credential.provider]
                        DataService.ds.createFirebaseUser(user!.uid, userData: userData)
                        
                        NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                    
                })
                
            }
        }
    }
    
    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                
                if error != nil {
                    
                    print(error)
                    
                    if error!.code == STATUS_ACCOUNT_NONEXIST {
                        
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                            
                            print(error)
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account.", msg: "Problem creating account. Try something else.")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                                
                                let userData = ["provider": "email"]
                                DataService.ds.createFirebaseUser(user!.uid, userData: userData)
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                            
                        })
                        
                    } else {
                        self.showErrorAlert("Could not log in.", msg: "Please check your username or password.")
                    }
                    
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
                
            })
            
        } else {
            showErrorAlert("Email and password required.", msg: "You must enter an email and a password.")
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}

