//
//  ProfileVC.swift
//  Devslopes Showcase
//
//  Created by Max Peiros on 11/21/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit
import Alamofire

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var usernameTextField: MaterialTextField!
    
    var imagePicker: UIImagePickerController!
    
    var profilePicChanged = false
    
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
        profilePicChanged = true
    }
    
    @IBAction func updateProfilePressed(_ sender: Any) {
        if usernameTextField.text != "" {
            let username = usernameTextField.text!
            let userData = ["username": username]
            DataService.ds.REF_USER_CURRENT.updateChildValues(userData)
        }
        
        if let img = profilePicImageView.image, profilePicChanged == true {
            let url = "https://post.imageshack.us/upload_api.php"
            let imgData = UIImageJPEGRepresentation(img, 0.2)!
            let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".data(using: String.Encoding.utf8)!
            let keyJSON = "json".data(using: String.Encoding.utf8)!
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                multipartFormData.append(imgData, withName: "fileupload", fileName: "image", mimeType: "image/jpeg")
                multipartFormData.append(keyData, withName: "key")
                multipartFormData.append(keyJSON, withName: "format")
                
            },
                 to: url,
                 encodingCompletion: { (encodingResult) in
                    
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if let info = response.result.value as? Dictionary<String, AnyObject> {
                                
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    if let profilePicLink = links["image_link"] as? String {
                                        print("Profile Pic Link: \(profilePicLink)")
                                        let profilePicData = ["profilePicUrl": profilePicLink]
                                        DataService.ds.REF_USER_CURRENT.updateChildValues(profilePicData)
                                    }
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            )
        }
        
        self.navigationController!.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
