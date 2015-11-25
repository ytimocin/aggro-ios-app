//
//  AggroApiSignUpResponse.swift
//  Aggro
//
//  Created by Yetkin Timocin on 18/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import Foundation

struct AggroApiRegisterResponse {
    
    var registerResponseCode: Int? = nil
    var registerResponseDesc: String? = nil
    var registeredUser: AggroUser? = nil
    
    init(code: Int, desc: String, user: AggroUser) {
        self.registerResponseCode = code
        self.registerResponseDesc = desc
        self.registeredUser = user
    }
    
    init(dictionary: [String : AnyObject]) {
        
        if let registerResponseCode = dictionary["registerResponseCode"] as? Int {
            self.registerResponseCode = registerResponseCode
        }
        
        if let registerResponseDesc = dictionary["registerResponseDesc"] as? String {
            self.registerResponseDesc = registerResponseDesc
        }
        
        if let registeredUser = dictionary["registeredUser"] as? [String : AnyObject] {
            self.registeredUser = AggroUser(dictionary: registeredUser)
        }
        
    }
    
}