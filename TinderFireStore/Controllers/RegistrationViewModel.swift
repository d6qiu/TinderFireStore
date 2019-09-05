//
//  RegistrationViewModel.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/3/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
class RegistrationViewModel {
    
    var binadableIsRegistering = Bindable<Bool>()
    
    var bindableIsFormValid = Bindable<Bool>()
    //    var isFormValidObserver: ((Bool) -> ())?
    
    //then only need to set the value and reactor
    var bindableImage = Bindable<UIImage>()
    
//    var image: UIImage? {
//        didSet {
//            imageObserver?(image)
//        }
//    }
//    //observe variable change in viewmodel and reflect in view, variable is image, so thats the input parameter; either have definiton or be optional, else need initializer
//    var imageObserver: ((UIImage?) -> ())?
    
    
    var fullName: String? {
        didSet { //changes in state triggers action, setup button in view or controller class, should trigger action in UI
            checkFormValidity()
        }
    }
    var email: String? {
        didSet {
            checkFormValidity()
        }
    }
    var password: String? {
        didSet {
            checkFormValidity()
        }
    }
    //checks own property, self calls a functor that makes another class do stuff
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
    
    
    func performRegistration(completion: (Error?) -> ()) {
        
    }
    

}
