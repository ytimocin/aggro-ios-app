//
//  AggroError.swift
//  Aggro
//
//  Created by Yetkin Timocin on 18/10/15.
//  Copyright © 2015 BaseTech. All rights reserved.
//

import Foundation

enum AggroError: Int {
    
    case Client  = 0
    case Network = 1
    case Server  = 2
    
    static func localizedDescription(errorType: AggroError) -> String {
        
        switch errorType {
        case .Client:
            return "Client Error"
        case .Network:
            return "Network Error"
        case .Server:
            return "Server Error"
        }
        
    }
}
