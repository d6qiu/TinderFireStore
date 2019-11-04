//
//  MessagesNavBar.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 10/1/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//
import UIKit
class SingleChatNavBar: UIView {
    
    let userProfileImageView = CircularImageView(width: 44)
    let nameLabel = UILabel(text: "", font: .systemFont(ofSize: 16))
    let backButton = UIButton(image: #imageLiteral(resourceName: "back") , tintColor: #colorLiteral(red: 1, green: 0.2392855883, blue: 0.2758899629, alpha: 1))// command shift l to search media
    let flagButton = UIButton(image: #imageLiteral(resourceName: "flag"), tintColor: #colorLiteral(red: 1, green: 0.2392855883, blue: 0.2758899629, alpha: 1))

    fileprivate let match: Match
    
    init(match: Match) {
        self.match = match
        nameLabel.text = match.name
        userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl), completed: nil)
        super.init(frame: .zero) //since anchor in higher hierarchy class will reset frame.
        backgroundColor = .white
        layer.opacity = 1
        
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        //use CircularImageView instead of these lines
        
//        userProfileImageView.constrainWidth(44)
//        userProfileImageView.constrainHeight(44)
//        userProfileImageView.clipsToBounds = true
//        userProfileImageView.layer.cornerRadius = 44/2
        let middleStack = hstack(
            stack(userProfileImageView,
                  nameLabel,
                  spacing: 8,
                  alignment: .center),
            alignment: .center
        )
        hstack(backButton, middleStack, flagButton).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
