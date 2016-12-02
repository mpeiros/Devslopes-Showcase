//
//  ProfileVC.swift
//  Devslopes Showcase
//
//  Created by Max Peiros on 11/21/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameTextField: MaterialTextField!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your Profile"
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        usernameTextField.delegate = self
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismiss(animated: true, completion: nil)
        profilePicImageView.image = image
    }
    
    @IBAction func updateProfilePressed(_ sender: Any) {
        if usernameTextField.text != "" {
            let username = usernameTextField.text
            let userData = ["username": username]
            DataService.ds.REF_USER_CURRENT.updateChildValues(userData)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
