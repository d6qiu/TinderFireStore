//
//  ViewController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 7/18/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
class HomeController: UIViewController {

    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let buttonsStackView = HomeBottomControlsStackView()
    

    var cardViewModels = [CardViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        setupLayout() // view.bottomAnchor is the real bottom edge
        //layout guide is a dummy view object with variables like edge constraints or height
        
        fetchUsersFromFirestore()
        
        
 
        
    }
    
    var lastFetchedUser: User?
    fileprivate func fetchUsersFromFirestore() {
        //filter and order by cant not use on different fields in one line
        let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        query.getDocuments { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                self.cardViewModels.append(user.toCardViewModel())
                self.lastFetchedUser = user
            })
            self.setupFirestoreUserCards()
        }
    }
    
    
    @objc func handleSettings() {
        let registrationController = RegistrationController()
        present(registrationController, animated: true)
    }
    
    
    fileprivate func setupFirestoreUserCards() {
        //(0..<10).forEach
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            
            cardView.cardViewModel = cardVM
            
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
        
    }

    //MARK:- Fileprivate
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white //programmatically default background is black
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonsStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true //makes layout base on margins， otherwise base on bounds
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView) //bring cardsdeckview to the front of z axis
    }
    

}

