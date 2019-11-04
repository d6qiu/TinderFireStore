//
//  TopNavigationStackView.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 7/22/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

class HomeNavigationStackView: UIStackView {

    let settingsButton = UIButton(type: .system)
    let messageButton = UIButton(type: .system)
    let fireImageView = UIImageView(image: #imageLiteral(resourceName: "app_icon"))
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 80).isActive = true

        //change fire image in asset in 3x to shrink down image, 3x has higher ppi
        fireImageView.contentMode = .scaleAspectFit
        settingsButton.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)
        
        
        [settingsButton, UIView(), fireImageView, UIView(), messageButton].forEach { (view) in
            addArrangedSubview(view) //add subviews to stackview
        }
        
        distribution = .equalCentering // equal centering will override default layout margin to 0, so need below two lines
        isLayoutMarginsRelativeArrangement = true //this enables the next line
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16) 
//        let simpleView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//        addSubview(simpleView)
//        fireImageView.anchorSize(to: simpleView)
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    

}
