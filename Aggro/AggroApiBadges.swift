//
//  AggroApiBadges.swift
//  Aggro
//
//  Created by Yetkin Timocin on 20/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import Foundation

class AggroApiBadges {
    
    var badges: [AggroBadge] = [AggroBadge]()
    
    class func sharedInstance() -> AggroApiBadges {
        struct Singleton {
            static var sharedInstance = AggroApiBadges()
        }
        
        return Singleton.sharedInstance
    }
    
}
