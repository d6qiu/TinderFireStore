//
//  FirebaseExtensions.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/13/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import Firebase

extension Firestore {
    func fetchCurrentUser(completion: @escaping (User?, Error?) ->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //theres get documents and get document
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                completion(nil, err)
                return
            }
            guard let dictionary = snapshot?.data() else {
                let error = NSError(domain: "com.damonqiu26.TinderFireStore", code: 500, userInfo: [NSLocalizedDescriptionKey : "No user found in Firestore"])
                completion(nil, error)
                return
            }
            let user = User(dictionary: dictionary)
            completion(user, nil)
        }
    }
}
