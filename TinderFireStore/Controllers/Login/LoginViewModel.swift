//
//  LoginViewModel.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/13/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa
class LoginViewModel {
    var isLoggingIn = BehaviorRelay(value: false)
    var isFormValid = BehaviorRelay(value: false)
    
    
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    fileprivate func checkFormValidity() {
        let isValid = email?.isEmpty == false && password?.isEmpty == false
        isFormValid.accept(isValid)
    }
    
    func performLogin(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        isLoggingIn.accept(true)
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            completion(err)
        }
    }
}
