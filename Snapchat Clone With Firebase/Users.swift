//
//  Users.swift
//  Snapchat Clone With Firebase
//
//  Created by Nathan Johnson on 1/31/17.
//  Copyright © 2017 Nathan Johnson. All rights reserved.
//

import Foundation

struct User {
    
    private var _username = String();
    private var _email = String();
    private var _id = String();
    
    init(id: String, email: String) {
        _id = id;
        _email = email;
  

    }
    
    var id: String {
        return _id;
    }
    
    var email: String {
        
        get {
            return _email;
        }
    }
}
