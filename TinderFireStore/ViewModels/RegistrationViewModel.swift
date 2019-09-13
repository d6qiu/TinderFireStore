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
    
    
    func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let pass = password else {return}
        
        binadableIsRegistering.value = true //reactor already settted up in another class, calls reactor in bindable
        
        Auth.auth().createUser(withEmail: email, password: pass) { (result, err) in
            if let err = err {
                completion(err) //complete error handling behavior 
                return
            }
            print("registered user:", result?.user.uid ?? "")
            
            self.saveImageToFirebase(completion: completion)
            
        }
    }
    
   
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil, completion: { (_, err) in
            if let err = err {
                completion(err)
                return
            }
            print("uploaded image to storage")
            _ = ref.downloadURL(completion: { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                self.binadableIsRegistering.value = false
                
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            })
        })
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String,completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = ["fullName": fullName ?? "", "uid": uid, "imageUrl": imageUrl]
        Firestore.firestore().collection("users").document(uid).setData(docData, completion: completion)
    }

}
