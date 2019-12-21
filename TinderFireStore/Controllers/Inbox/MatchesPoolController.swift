//
//  MatchesMessageController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/29/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase



class RecentMessageCell: ListCell<UIColor> {
    let userProfileImageView = UIImageView(image: #imageLiteral(resourceName: "kelly1"), contentMode: .scaleAspectFill)
    let userNameLabel = UILabel(text: "useranme", font: .boldSystemFont(ofSize: 18))
    let messageTexLabel = UILabel(text: "", font: .systemFont(ofSize: 16), textColor: .gray)
    
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
class MatchesPoolController: ListHeaderController<RecentMessageCell, UIColor, MatchesPoolHeader>, UICollectionViewDelegateFlowLayout{
    
    override func setupHeader(_ header: MatchesPoolHeader) {
        //so matchespoolheader's horizontalviewcontroller has reference to matchesPoolController
        header.horizontalViewController.rootMatchesController = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //called matchespoolcontroller.didselectmatchfromheader in horizontalheadercontroller
    func didSelectMatchFromHeader(match: Match) {
        let singleChatLogController = SingleChatController(match: match)
        navigationController?.pushViewController(singleChatLogController, animated: true)
    }
    
    let matchesPoolNavBar = MatchesPoolNavBar()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 200)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
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
