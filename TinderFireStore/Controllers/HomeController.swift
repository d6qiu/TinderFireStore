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
    
    let topStackView = HomeNavigationStackView()
    let cardsDeckView : UIView = {
       let view = UIView()
        view.layer.opacity = 1
        view.backgroundColor = UIColor.white
        return view
    }()
    let bottomControls = HomeBottomStackView()
    

    var cardViewModels = [PosterViewModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
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
            let registrationController = RegistrationController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
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
            self.hud.dismiss() //dismiss hud
            if let err = err {
                print(err)
                return
            }
            self.user = user
            self.fetchSwipes() //fetchusersfromfirestore is in it
            //self.fetchUsersFromFirestore()
        }

    }
    
    var swipes = [String : Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            //when snapshot is nil because current user havent swiped at all, fetchusers regardless of current user swipes
            guard let data = snapshot?.data() as? [String: Int] else {
                self.fetchUsersFromFirestore()
                return
            }
            self.swipes = data
            self.fetchUsersFromFirestore()
        }
    }
    
    fileprivate func setupButtonTargets() {
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
    }
    
    
    @objc fileprivate func handleMessages() {
        let matchesMessagesController = MatchesPoolController()
        navigationController?.pushViewController(matchesMessagesController, animated: true)
    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirestore() {
        //guard let minAge = ...
        let minAge = user?.minSeekingAge ?? BiosController.defaultMinSeekingAge //fix bug where a new registering user screen is occupied by a loading hud because early return due to nil minAge using guard statement
        let maxAge = user?.maxSeekingAge ?? BiosController.defaultMaxSeekingAge
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Finding Matches"
        hud.show(in: view)
        //cant not filter(whereField) and then order on different fields at the same time
        //let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 1)
        //if argument is nil, invalid query will crash
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge).limit(to: 10)
        topCardView = nil // need to reset this everytime deck reset from save
        query.getDocuments { (snapshot, err) in
            hud.dismiss()
            if let err = err {
                print(err)
                return
            }
            
            var previousCardView: posterView?
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                self.users[user.uid ?? ""] = user
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let hasNotSwipedBefore = self.swipes[user.uid!] == nil // user.uid is one of the fetched users, not auth.currentuser, u know user uid cant be nil when uid is set upon registration
                if isNotCurrentUser && hasNotSwipedBefore {
                    let cardView = self.setupCardFromUser(user: user)
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    if self.topCardView == nil { //set the first card as topcardview, since cards are added to below each other
                        self.topCardView = cardView
                    }
                }
            })
            //self.setupFirestoreUserCards() //this method will make each refresh load from cardviewmodels, will load the same old users even though they are swiped.
        }
    }
    //cache all users because checkifMatchesexist dont have carduser objects, need them save
    var users = [String:User]()
    
    var topCardView: posterView?
    
    @objc fileprivate func handleRefresh() {
        if topCardView == nil { //only allow refresh when user swipes all the cards already
            //fetchUsersFromFirestore()
            //cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
            fetchSwipes()
        }
    }
    
    @objc func handleLike() {
        saveSwipeToFireStore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    @objc  func handleDislike() {
        saveSwipeToFireStore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
    fileprivate func saveSwipeToFireStore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let cardUID = topCardView?.posterViewModel.uid else {return}
        let documentData = [cardUID: didLike]
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    if didLike == 1 { //delay present matchView
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                //must set once before update // this is the first swipe for current user
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }

                }
            }
        }
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            guard let data = snapshot?.data() else {return}
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let hasMatched = data[uid] as? Int == 1 //hasMatched will be nil if this user hasnt swiped for current user yet
            if hasMatched {
                guard let cardUser = self.users[cardUID] else {return}
                self.presentMatchView(cardUID: cardUID)
                let data = ["name": cardUser.name ?? "", "profileImageUrl": cardUser.imageUrl ?? "", "uid": cardUID, "timestamp": Timestamp(date: Date())] as [String : Any]
                Firestore.firestore().collection("matches_messages").document(uid).collection("matches").document(cardUID).setData(data) { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    
                }
                
                guard let currentUser = self.user else {return}
                let reverseMatchData = ["name": currentUser.name ?? "", "profileImageUrl": currentUser.imageUrl ?? "", "uid": uid, "timestamp" : Timestamp(date: Date())] as [String: Any]
                Firestore.firestore().collection("matches_messages").document(cardUID).collection("matches").document(uid).setData(reverseMatchData) { (err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    
                }
                
            }
        }
    }
    
    fileprivate func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x") //specific keypaths on archive
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut) //begin quick and then slow
        translationAnimation.isRemovedOnCompletion = false //animation wont cancel ultil completion

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z") //think of x y z axis
        rotationAnimation.toValue = angle * CGFloat.pi / 180 //15 degrees
        rotationAnimation.duration = duration
                
        let cardView = topCardView // create a varable in stack so wont change reference in completionblock (user could fast like mutiple)
        topCardView = topCardView?.nextCardView
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }

        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")

        CATransaction.commit()
                
        //        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
        //            self.topCardView?.frame = CGRect(x: 600, y: 0, width: self.topCardView!.frame.width, height: self.topCardView!.frame.height)
        //            let angle = 15 * CGFloat.pi / 180
        //            self.topCardView?.transform = CGAffineTransform(rotationAngle: angle)
        //
        //        }) { (_) in
        //            self.topCardView?.removeFromSuperview()
        //            self.topCardView = self.topCardView?.nextCardView
        //        }
    }
    
    func didRemoveCard(cardView: posterView) {
        self.topCardView = self.topCardView?.nextCardView
    }
    
    func didSwipe(translationDirection: CGFloat) {
        if translationDirection == 1{
            handleLike()
        } else {
            handleDislike()
        }
    }
    
    fileprivate func setupCardFromUser(user: User) -> posterView {
        let cardView = posterView(frame: .zero)
        
        cardView.delegate = self
        cardView.posterViewModel = user.convertModelToPosterViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView) //fix anchor flash, the aanchor that stack subviews on top os subviews, now subsview anchor stack below each other, order of cards are reversed in each pagination
        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: PosterViewModel) {
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }
    
    
    @objc func handleSettings() {
        let settingsController = BiosController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        navController.modalPresentationStyle = .fullScreen //because ios 13 update need to set fullscreen otherwise wont trigger viewdidappear
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

