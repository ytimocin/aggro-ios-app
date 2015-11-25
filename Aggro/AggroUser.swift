//
//  AggroUser.swift
//  Aggro
//
//  Created by Yetkin Timocin on 18/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import Foundation

struct AggroUser {
    
    var aggroID: String? = nil
    var username: String? = nil
    var email: String? = nil
    var password: String? = nil
    var badges: [String]? = nil
    
    init() {
        
    }
    
    init(dictionary: [String : AnyObject]) {
        
        if let aggroID = dictionary["aggroID"] as? String {
            self.aggroID = aggroID
        }
        
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        
        if let email = dictionary["email"] as? String {
            self.email = email
        }
        
        if let password = dictionary["password"] as? String {
            self.password = password
        }
        
        if let badges = dictionary["badges"] as? [String] {
            self.badges = badges
        }
        
    }
    
    static func getAggroUser(results: [[String : AnyObject]]) -> [AggroUser] {
        
        var users = [AggroUser]()
        
        for result in results {
            users.append(AggroUser(dictionary: result))
        }
        
        return users
    }
}
