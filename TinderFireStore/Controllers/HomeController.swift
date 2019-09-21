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

class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate{
    
    

    let topStackView = TopNavigationStackView()
    let cardsDeckView : UIView = {
       let view = UIView()
        view.layer.opacity = 1
        view.backgroundColor = UIColor.white
        return view
    }()
    let bottomControls = HomeBottomControlsStackView()
    

    var cardViewModels = [CardViewModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonTargets()
        setupLayout() // view.bottomAnchor is the real bottom edge
        //layout guide is a dummy view object with variables like edge constraints or height
        fetchCurrentUser() //includes fetchuserfromdatabase
        
    }
    
    fileprivate var user: User?
    fileprivate let hud = JGProgressHUD(style: .dark)
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginController = LoginController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            present(navController, animated: true)
        }
        
    }
    //refresh homecontroller after logging in, called in logincontroller
    func didFinishLoggingIn() {
        fetchCurrentUser() //includes fetchuserfromdatabase
    }
    
    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        cardsDeckView.subviews.forEach { (view) in
            view.removeFromSuperview() //need this otherwise cardsviews keep stacking on old ones if didnt swipe old ones off since homecontroller dont get distroyed
        }
        //theres get documents and get document
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print(err)
                return
            }
            self.hud.dismiss()
            self.user = user
            self.fetchUsersFromFirestore()
        }

    }
    
    fileprivate func setupButtonTargets() {
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)

        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
    }
    
    @objc fileprivate func handleRefresh() {
        fetchUsersFromFirestore()
    }
    
    var lastFetchedUser: User?
    fileprivate func fetchUsersFromFirestore() {
        //guard let minAge = ...
        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge //fix bug where a new registering user screen is occupied by a loading hud because early return due to nil minAge using guard statement
        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Finding Matches"
        hud.show(in: view)
        //cant not filter(whereField) and then order on different fields at the same time
        //let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 1)
        //if argument is nil, invalid query will crash
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { (snapshot, err) in
            hud.dismiss()
            if let err = err {
                print(err)
                return
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                if user.uid != Auth.auth().currentUser?.uid {
                    self.setupCardFromUser(user: user)
                }
                //self.cardViewModels.append(user.toCardViewModel())
//                self.lastFetchedUser = user
            })
            //self.setupFirestoreUserCards() //this method will make each refresh load from cardviewmodels, will load the same old users even though they are swiped.
        }
    }
    
    fileprivate func setupCardFromUser(user: User) {
        let cardView = CardView(frame: .zero)
        
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView) //fix anchor flash, the aanchor that stack subviews on top os subviews, now subsview anchor stack below each other, order of cards are reversed in each pagination
        cardView.fillSuperview()
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }
    
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
    }
    
    func didSaveSettings() {
        fetchCurrentUser() //has fetchusersfromfirebase in it, need to update user model first, so the new age range gets refiltered
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

