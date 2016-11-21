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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: KEY_CURRENT_USER_UID) != nil {
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        emailField.text = ""
        passwordField.text = ""
    }
    
    @IBAction func fbBtnPressed(_ sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if error != nil {
                print("Facebook login failed. Error \(error)")
            } else {
                let accessToken = FBSDKAccessToken.current().tokenString
                print("Successfully logged in with Facebook. \(accessToken)")
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in! \(user)")
                        
                        DataService.ds.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if !snapshot.hasChild(user!.uid) {
                                let userData = ["provider": credential.provider]
                                DataService.ds.createFirebaseUser(user!.uid, userData: userData)
                            }
                        })
                        
                        UserDefaults.standard.setValue(user?.uid, forKey: KEY_CURRENT_USER_UID)
                        self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func attemptLogin(_ sender: UIButton!) {
        
        if let email = emailField.text, email != "", let pwd = passwordField.text, pwd != "" {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                
                if error != nil {
                    
                    print(error!)
                    
                    if error!._code == STATUS_ACCOUNT_NONEXIST {
                        
                        FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                            
                            if error != nil {
                                print(error!)
                                self.showErrorAlert("Could not create account.", msg: "Problem creating account. Try something else.")
                            } else {
                                UserDefaults.standard.setValue(user?.uid, forKey: KEY_CURRENT_USER_UID)
                                
                                let userData = ["provider": "email"]
                                DataService.ds.createFirebaseUser(user!.uid, userData: userData)
                                
                                self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                            }
                            
                        })
                        
                    } else {
                        self.showErrorAlert("Could not log in.", msg: "Please check your username or password.")
                    }
                    
                } else {
                    UserDefaults.standard.setValue(user?.uid, forKey: KEY_CURRENT_USER_UID)
                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            showErrorAlert("Email and password required.", msg: "You must enter an email and a password.")
        }
    }
    
    func showErrorAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

