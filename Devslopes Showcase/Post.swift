//
//  Post.swift
//  Devslopes Showcase
//
//  Created by Max Peiros on 6/9/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    fileprivate var _postDescription: String!
    fileprivate var _imageUrl: String?
    fileprivate var _likes: Int!
    fileprivate var _username: String!
    fileprivate var _postKey: String!
    fileprivate var _postRef: FIRDatabaseReference!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imageUrl: String?, username: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
    }
    
    func adjustLikes(_ addLike: Bool) {
        
        if addLike == true {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
        
    }
    
}
