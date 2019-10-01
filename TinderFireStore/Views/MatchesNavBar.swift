//
//  MatchesNavBar.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/30/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
class MatchesNavBar: UIView {
    
    let backButton = UIButton(image: #imageLiteral(resourceName: "app_icon"), tintColor: .gray)
    override init(frame: CGRect) {
        super.init(frame: frame)
        //need to set background color else default is clear then shadow wont show up
        backgroundColor = .white
        layer.opacity = 1
        
        let iconImageView = UIImageView(image: #imageLiteral(resourceName: "top_messages_icon").withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        iconImageView.tintColor = #colorLiteral(red: 1, green: 0.3191436827, blue: 0.3717493117, alpha: 1)
                
        let messagesLabel = UILabel(text: "Messages", font: UIFont.boldSystemFont(ofSize: 20), textColor: #colorLiteral(red: 0.9803921569, green: 0.2754820287, blue: 0.3579338193, alpha: 1), textAlignment: .center, numberOfLines: 0)
        let feedLabel = UILabel(text: "Feed", font: .boldSystemFont(ofSize: 20), textColor: UIColor.gray, textAlignment: .center, numberOfLines: 0)
        //height 10 to y direction
        setupShadow(opacity: 0.5, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        stack(iconImageView.withHeight(44),
                     hstack(messagesLabel, feedLabel,
                     distribution: .fillEqually)).padTop(10)
        
       
        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 12, bottom: 0, right: 0), size: .init(width: 34, height: 34))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
