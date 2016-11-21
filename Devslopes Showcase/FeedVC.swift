//
//  FeedVC.swift
//  Devslopes Showcase
//
//  Created by Max Peiros on 6/8/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    var posts = [Post]()
    var imageSelected = false
    static var imageCache = NSCache<AnyObject, AnyObject>()
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your Feed"

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 350
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { snapshot in
            print(snapshot.value!)
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                    
                }
                
            }
            
            self.tableView.reloadData()
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.object(forKey: url as AnyObject) as? UIImage
            }
            
            cell.configureCell(post, img: img)
            return cell
        } else {
            return PostCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(_ sender: AnyObject) {
        
        if let txt = postField.text, txt != "" {
            
            if let img = imageSelectorImage.image, imageSelected == true {
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
                                        if let imgLink = links["image_link"] as? String {
                                            print("LINK: \(imgLink)")
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                )
                
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(_ imgUrl: String?) {
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text! as AnyObject,
            "likes": 0 as AnyObject
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl! as AnyObject?
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try FIRAuth.auth()!.signOut()
            
            if FIRAuth.auth()!.currentUser == nil {
                UserDefaults.standard.setValue(nil, forKey: KEY_CURRENT_USER_UID)
                self.navigationController!.dismiss(animated: true, completion: nil)
            }
        } catch {
            print("error signing out")
        }
    }
    
}

