//
//  Match.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 12/20/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import Foundation
struct Match {
    let name, profileImageUrl: String, uid: String
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        
    }
}
