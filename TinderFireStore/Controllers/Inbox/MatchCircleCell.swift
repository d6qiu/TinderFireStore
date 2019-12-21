//
//  MatchCircleCell.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 12/20/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
class MatchCircleCell: ListCell<Match> {
    
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
