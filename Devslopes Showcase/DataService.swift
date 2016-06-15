//
//  DataService.swift
//  Devslopes Showcase
//
//  Created by Max Peiros on 6/2/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = URL_BASE
    private var _REF_POSTS = URL_BASE.child("posts")
    private var _REF_USERS = URL_BASE.child("users")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = REF_USERS.child(uid)
        return user
    }
    
    func createFirebaseUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).setValue(userData)
    }
    
}