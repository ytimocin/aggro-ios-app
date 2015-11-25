//
//  AggroApiConvenience.swift
//  Aggro
//
//  Created by Yetkin Timocin on 18/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Convenient Resource Methods

extension AggroApiClient {
    
    func login(email:String, password: String, completionHandler: (result: AggroApiLoginResponse?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = Dictionary<String, String>()
        let mutableMethod : String = Methods.AggroLogin
        
        let jsonBody = "{\"email\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 2. Make the request */
        taskForPOSTMethodJSONString(mutableMethod, parameters: parameters, jsonBody: jsonBody!) { data, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(result: nil, error: error)
                
            } else {
                
                let json = JSON(data: data)
                
                if  json != nil {
                    
                    let loginResponseCode = json["loginResponseCode"].intValue
                    let loginResponseDesc = json["loginResponseDesc"].stringValue
                    let loggedInUser = self.getAggroUserFromJSON(json["loggedInUser"])
                    
                    AggroApiClient.sharedInstance().aggroUser = loggedInUser
                    
                    let aggroApiLoginResponse = AggroApiLoginResponse(code: loginResponseCode, desc: loginResponseDesc, user: loggedInUser)
                    
                    self.loadAggroBadges()
                    
                    completionHandler(result: aggroApiLoginResponse, error: nil)
                    
                } else {
                    
                    completionHandler(result: nil, error: NSError(domain: "udacityLogin parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse udacityLogin"]))
                }
            }
        }
    }
    
    func register(username: String, email:String, password: String, completionHandler: (result: AggroApiRegisterResponse?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = Dictionary<String, String>()
        let mutableMethod : String = Methods.AggroRegister
        
        let jsonBody = "{\"username\": \"\(username)\", \"email\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 2. Make the request */
        taskForPOSTMethodJSONString(mutableMethod, parameters: parameters, jsonBody: jsonBody!) { data, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(result: nil, error: error)
                
            } else {
                
                let json = JSON(data: data)
                
                if  json != nil {
                    
                    let registerResponseCode = json["registerResponseCode"].intValue
                    let registerResponseDesc = json["registerResponseDesc"].stringValue
                    let registeredUser = self.getAggroUserFromJSON(json["registeredUser"])
                    
                    AggroApiClient.sharedInstance().aggroUser = registeredUser
                    
                    let aggroApiRegisterResponse = AggroApiRegisterResponse(code: registerResponseCode, desc: registerResponseDesc, user: registeredUser)
                    
                    self.loadAggroBadges()
                    
                    completionHandler(result: aggroApiRegisterResponse, error: nil)
                    
                } else {
                    
                    completionHandler(result: nil, error: NSError(domain: "udacityLogin parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse udacityLogin"]))
                }
            }
        }
    }
    
    func getAggroBadges(skip: Int = 0, completionHandler: (result: [AggroBadge]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = Dictionary<String, String>()
        let mutableMethod : String = Methods.AggroAllBadges
        
        /* 2. Make the request */
        taskForGETMethod(mutableMethod, parameters: parameters) { data, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                
                completionHandler(result: nil, error: error)
                
            } else {
                
                let json = JSON(data: data)
                
                if  json != nil {
                    
                    AggroApiBadges.sharedInstance().badges.removeAll()
                    
                    var aggroBadges = [AggroBadge]()
                    
                    for (key,subJson):(String, JSON) in json {
                        
                        let badgeID = subJson["badgeID"].stringValue
                        let badgeName = subJson["name"].stringValue
                        let badgeDescription = subJson["description"].stringValue
                        let badgeImage = subJson["image"].stringValue
                        let badgeUsers = json[key]["users"].intValue
                        let badgePosts = json[key]["posts"].intValue
                        
                        let aggroBadge = AggroBadge(badgeID: badgeID, name: badgeName, description: badgeDescription, image: badgeImage, users: badgeUsers, posts: badgePosts)
                        
                        aggroBadges.append(aggroBadge)
                        
                    }
                    
                    completionHandler(result: aggroBadges, error: nil)
                    
                } else {
                    
                    completionHandler(result: nil, error: NSError(domain: "udacityLogin parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse udacityLogin"]))
                }
            }
        }
    }
    
    func addBadges(selectedBadges: [String], completionHandler: (result: Int?, error: NSError?) -> Void) {
        var resultList: [Int] = []
        for badgeID in selectedBadges {
            let result = self.addBadgeToUser(badgeID)
            resultList.append(result)
        }
        
        var resultTotal: Int = 0
        for result in resultList {
            resultTotal = resultTotal + result
        }
        
        if resultTotal / resultList.count == 1 {
            completionHandler(result: 0, error: nil)
        } else {
            completionHandler(result: -1, error: nil)
        }
    }
    
    func addBadgeToUser(badgeID: String) -> Int {
        
        var result: Int? = 1
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = Dictionary<String, String>()
        let aggroID = AggroApiClient.sharedInstance().aggroUser.aggroID!
        let mutableMethod : String = "user/\(aggroID)/addBadge/\(badgeID)"
        
        let jsonBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 2. Make the request */
        taskForPOSTMethodJSONString(mutableMethod, parameters: parameters, jsonBody: jsonBody!) { data, error in
            /* 3. Send the desired value(s) to completion handler */
            if error != nil {
                result = -1
            } else {
                let json = JSON(data: data)
                if  json != nil {
                    AggroApiClient.sharedInstance().aggroUser.badges!.append(badgeID)
                    result = json["addBadgeResponseCode"].intValue
                } else {
                    result = -1
                }
            }
        }
        return result!
    }
    
    func getAggroUserFromJSON(json: JSON) -> AggroUser {
        var user: AggroUser = AggroUser()
        user.aggroID = json["aggroID"].stringValue
        user.username = json["username"].stringValue
        user.email = json["email"].stringValue
        user.password = json["password"].stringValue
        
        var badgesArray: [String] = []
        for (_,subJson):(String, JSON) in json["badges"] {
            badgesArray.append(subJson.stringValue)
        }
        user.badges = badgesArray
        return user
    }
    
    func getBadge(badgeID: String) -> AggroBadge {
        var aggroBadge: AggroBadge = AggroBadge()
        for badge in AggroApiBadges.sharedInstance().badges {
            if badgeID == badge.badgeID {
                aggroBadge = badge
                break
            }
        }
        return aggroBadge
    }
    
    func loadAggroBadges() {
        
        AggroApiBadges.sharedInstance().badges.removeAll()
        
        let serialQueue = dispatch_queue_create("com.aggro.api", DISPATCH_QUEUE_SERIAL)
        
        let skips = [0, 100]
        for skip in skips {
            dispatch_sync( serialQueue ) {
                
                AggroApiClient.sharedInstance().getAggroBadges(skip) { badges, error in
                    if let badges = badges {
                        AggroApiBadges.sharedInstance().badges.appendContentsOf(badges)
                        
                        if badges.count > 0 {
                            dispatch_async(dispatch_get_main_queue()) {
                                NSNotificationCenter.defaultCenter().postNotificationName("badgeDataUpdated", object: nil)
                            }
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            NSNotificationCenter.defaultCenter().postNotificationName("badgeDataError", object: nil)
                        }
                        
                    }
                }
            }
        }
    }
    
}
