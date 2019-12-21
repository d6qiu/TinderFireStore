//
//  MatchesHorizontalController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 12/20/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase

class MatchesHorizontalController: ListController<MatchCircleCell, Match>, UICollectionViewDelegateFlowLayout {
    
    var rootMatchesController: MatchesPoolController?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let match = self.items[indexPath.item]
        rootMatchesController?.didSelectMatchFromHeader(match: match)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 110, height: view.frame.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal //so only can scroll horizontal in single row
        }
        
        fetchMatches()
    }
    
    fileprivate func fetchMatches() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("matches").getDocuments { (querySnapshot, err) in
            if let err = err {
                print(err)
                return
            }
            var matches = [Match]()
            querySnapshot?.documents.forEach({ (documentSnapshot) in
                let dict = documentSnapshot.data()
                matches.append(.init(dictionary: dict))
            })
            //cache data for collection view
            self.items = matches
            self.collectionView.reloadData()
        }
    }
}
