//
//  ViewController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 7/18/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController {

    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    

    var cardViewModels = [CardViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        setupLayout() // view.bottomAnchor is the real bottom edge
        //layout guide is a dummy view object with variables like edge constraints or height
        
        fetchUsersFromFirestore()
        setupButtonTargets()
        
    }
    
    fileprivate func setupButtonTargets() {
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    }
    
    @objc fileprivate func handleRefresh() {
        fetchUsersFromFirestore()
    }
    
    var lastFetchedUser: User?
    fileprivate func fetchUsersFromFirestore() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Finding Matches"
        hud.show(in: view)
        //filter and order by cant not use on different fields in one line
        let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 1)
        query.getDocuments { (snapshot, err) in
            hud.dismiss()
            if let err = err {
                print(err)
                return
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                //self.cardViewModels.append(user.toCardViewModel())
                self.lastFetchedUser = user
                
                self.setupCardFromUser(user: user)
            })
            //self.setupFirestoreUserCards() //this method will make each refresh load from cardviewmodels, will load the same old users even though they are swiped.
        }
    }
    
    fileprivate func setupCardFromUser(user: User) {
        let cardView = CardView(frame: .zero)
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView) //fix anchor flash, the aanchor that stack subviews on top os subviews, now subsview anchor stack below each other, order of cards are reversed in each pagination
        cardView.fillSuperview()
    }
    
    
    @objc func handleSettings() {
        let registrationController = RegistrationController()
        present(registrationController, animated: true)
    }
    
//    //only mehtod that uses cardviewmodels cache
//    fileprivate func setupFirestoreUserCards() {
//        //(0..<10).forEach
//        cardViewModels.forEach { (cardVM) in
//            let cardView = CardView(frame: .zero)
//
//            cardView.cardViewModel = cardVM
//
//            cardsDeckView.addSubview(cardView)
//            cardView.fillSuperview()
//        }
//
//    }

    //MARK:- Fileprivate
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white //programmatically default background is black
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true //makes layout base on margins， otherwise base on bounds
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView) //bring cardsdeckview to the front of z axis
    }
    

}

