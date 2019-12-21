//
//  Message.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 12/18/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import Firebase
struct Message {
    let text, fromId, toId: String
    let timestamp: Timestamp
    let isUserText: Bool
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.isUserText = Auth.auth().currentUser?.uid == fromId
    }
    
}
