//
//  MatchesMessageController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/29/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase


struct RecentMessage {
    let text, uid, name, profileImageUrl: String
    let timestamp: Timestamp
    
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
    
}


class RecentMessageCell: ListCell<RecentMessage> {
    let userProfileImageView = UIImageView(image: #imageLiteral(resourceName: "kelly1"), contentMode: .scaleAspectFill)
    let userNameLabel = UILabel(text: "useranme", font: .boldSystemFont(ofSize: 18))
    let messageTexLabel = UILabel(text: "", font: .systemFont(ofSize: 16), textColor: .gray)
    
    
    override var item: RecentMessage! {
        didSet {
            userNameLabel.text = item.name
            messageTexLabel.text = item.text
            userProfileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
        }
    }
    
    
    override func setupViews() {
        super.setupViews()
        userProfileImageView.layer.cornerRadius = 47
        
        hstack(userProfileImageView.withWidth(94).withHeight(94),
               stack(userNameLabel, messageTexLabel, spacing: 2),
               spacing: 20,
               alignment: .center
        ).padLeft(20).padRight(20)
        
        addSeparatorView(leadingAnchor: userNameLabel.leadingAnchor)
    }
}



//ListController(typeofcell, item/data in cell), flowlayout to set size of cells
class MatchesPoolController: ListHeaderController<RecentMessageCell, RecentMessage, MatchesPoolHeader>, UICollectionViewDelegateFlowLayout{
    
    override func setupHeader(_ header: MatchesPoolHeader) {
        //so matchespoolheader's horizontalviewcontroller has reference to matchesPoolController
        header.horizontalViewController.rootMatchesController = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //called matchespoolcontroller.didselectmatchfromheader in horizontalheadercontroller when user press circles in header
    func didSelectMatchFromHeader(match: Match) {
        let singleChatLogController = SingleChatController(match: match)
        singleChatLogController.currentUser = self.currentUser
        navigationController?.pushViewController(singleChatLogController, animated: true)
    }
    
    let matchesPoolNavBar = MatchesPoolNavBar()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 250)
    }
    
    var recentMessagesDictionary = [String: RecentMessage]()
    
    fileprivate func fetchRecentMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print(err)
                return
            }
            querySnapshot?.documentChanges.forEach({ (change) in
                //.added referts to only added documents/messages, not modified messages objects, since profileimageurl is part of message objects, modify that wont reflect any changes
                if change.type == .added || change.type == .modified{
                    let dictionary = change.document.data()
                    let recentMessage = RecentMessage(dictionary: dictionary)
                    self.recentMessagesDictionary[recentMessage.uid] = recentMessage
                    
                }
            })
            self.resetItems()
        }
        
    }
    
    //match takes in other person's info, same as recentmessage
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recentMessage = self.items[indexPath.item]
        let dictionary = ["name": recentMessage.name, "profileImageUrl": recentMessage.profileImageUrl, "uid": recentMessage.uid]
        let match = Match(dictionary: dictionary)
        let controller = SingleChatController(match: match)
        controller.currentUser = self.currentUser
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //purpose: sort them by timestamp
    fileprivate func resetItems() {
        let values = Array(recentMessagesDictionary.values)
        items = values.sorted(by: { (rm1, rm2) -> Bool in
            return rm1.timestamp.compare(rm2.timestamp) == .orderedDescending
        })
        collectionView.reloadData()
    }
    
    var currentUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecentMessages()
        
        
        //item is of type Match, items is the cache
        
       setupInterface()
    }
    
    fileprivate func setupInterface() {
        collectionView.backgroundColor = .white
        collectionView.layer.opacity = 1

        matchesPoolNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)

        view.addSubview(matchesPoolNavBar)
        matchesPoolNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))

        collectionView.contentInset.top = 150 //content of view is 150 down from edge in this cas safewarealayoutguide
        
        //fix bug where scroller is not at the right height which is under the nav bar
        collectionView.scrollIndicatorInsets.top = 150
        
        //fix bug where view goes over and cover up status bar when scroll up
        let statusBarCover = UIView(backgroundColor: .white, opacity: 1)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    //avoid overlap with shadow
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 16, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 130)
    }
            
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}
