//
//  LoginResponse.swift
//  Aggro
//
//  Created by Yetkin Timocin on 18/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import Foundation

struct AggroApiLoginResponse {
    
    var loginResponseCode: Int? = nil
    var loginResponseDesc: String? = nil
    var loggedInUser: AggroUser? = nil
    
    init(code: Int, desc: String, user: AggroUser) {
        self.loginResponseCode = code
        self.loginResponseDesc = desc
        self.loggedInUser = user
    }
    
    init(dictionary: [String : AnyObject]) {
        
        if let loginResponseCode = dictionary["loginResponseCode"] as? Int {
            self.loginResponseCode = loginResponseCode
        }
        
        if let loginResponseDesc = dictionary["loginResponseDesc"] as? String {
            self.loginResponseDesc = loginResponseDesc
        }
        
        if let loggedInUser = dictionary["loggedInUser"] as? [String : AnyObject] {
            self.loggedInUser = AggroUser(dictionary: loggedInUser)
        }
        
    }
    
}
