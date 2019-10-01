//
//  MatchesMessageController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/29/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
struct Match {
    let name, profileImageUrl: String
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}

class MatchCell: ListCell<Match> {
    
//    let profileImageView = UIImageView(image: imageli, contentMode: .scaleAspectFill)
    let profileImageView = UIImageView(image: #imageLiteral(resourceName: "kelly3") , contentMode: .scaleAspectFill)
    let usernameLabel = UILabel(text: "username", font: .systemFont(ofSize: 14, weight: .semibold), textColor: #colorLiteral(red: 0.2823249698, green: 0.2823707461, blue: 0.2823149562, alpha: 1) , textAlignment: .center, numberOfLines: 2)
    
    //dynamic property
    override var item: Match! {
        didSet {
            usernameLabel.text = item.name
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.clipsToBounds = true
        profileImageView.constrainWidth(80)
        profileImageView.constrainHeight(80)
        profileImageView.layer.cornerRadius = 80/2
        stack(profileImageView, usernameLabel, alignment: .center) //has fillsuperview
    }
    
}

//ListController(typeofcell, item in cell), flowlayout to set size of cells
class MatchesMessagesController: ListController<MatchCell, Match>, UICollectionViewDelegateFlowLayout{
    
    let customNavBar = MatchesNavBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //item is of type Match, items is the cache
        fetchMatches()
        
        collectionView.backgroundColor = .white
        collectionView.layer.opacity = 1
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 150))
        
        collectionView.contentInset.top = 150 //content of view is 150 down from edge in this cas safewarealayoutguide
    }
    
    fileprivate func fetchMatches() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("matchs_messages").document(currentUserId).collection("matches").getDocuments { (querySnapshot, err) in
            if let err = err {
                print(err)
                return
            }
            var matches = [Match]()
            querySnapshot?.documents.forEach({ (documentSnapshot) in
                let dict = documentSnapshot.data()
                matches.append(.init(dictionary: dict))
            })
            
            self.items = matches
            self.collectionView.reloadData()
        }
    }
    //avoid overlap with shadow
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 120, height: 140)
    }
        
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}
