//
//  AggroBadge.swift
//  Aggro
//
//  Created by Yetkin Timocin on 20/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import Foundation

struct AggroBadge {
    
    var badgeID: String? = nil
    var name: String? = nil
    var description: String? = nil
    var image: String? = nil
    var users: Int? = nil
    var posts: Int? = nil
    
    init() {
        
    }
    
    init(badgeID: String, name: String, description: String, image: String, users: Int, posts: Int) {
        
        self.badgeID = badgeID
        self.name = name
        self.description = description
        self.image = image
        self.users = users
        self.posts = posts
        
    }
    
    init(dictionary: [String : AnyObject]) {
        
        if let badgeID = dictionary["badgeID"] as? String {
            self.badgeID = badgeID
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let description = dictionary["description"] as? String {
            self.description = description
        }
        
        if let image = dictionary["image"] as? String {
            self.image = image
        }
        
        if let users = dictionary["users"] as? Int {
            self.users = users
        }
        
        if let posts = dictionary["posts"] as? Int {
            self.posts = posts
        }
        
    }
    
    static func getAggroBadges(results: [[String : AnyObject]]) -> [AggroBadge] {
        
        var badges = [AggroBadge]()
        
        for result in results {
            badges.append(AggroBadge(dictionary: result))
        }
        
        return badges
    }
}
