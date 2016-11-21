//
//  PostCell.swift
//  Devslopes Showcase
//
//  Created by Max Peiros on 6/8/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
        
    }
    
    override func draw(_ rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }

    func configureCell(_ post: Post, img: UIImage?) {
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            if img != nil {
                self.showcaseImg.image = img
                self.showcaseImg.isHidden = false
            } else {
                
                request = Alamofire.request(post.imageUrl!).validate(contentType: ["image/*"]).responseData(completionHandler: { response in
                    
                    if let data = response.result.value {
                        if let img = UIImage(data: data) {
                            self.showcaseImg.image = img
                            self.showcaseImg.isHidden = false
                            FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl! as AnyObject)
                        }
                    }
                })
            }
            
        } else {
            self.showcaseImg.isHidden = true
        }
        
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                // This means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-empty")
                print(doesNotExist)
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
            
        })
        
    }
    
    func likeTapped(_ sender: UITapGestureRecognizer) {
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
                print(doesNotExist)
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
            
        })

    }
    
}
