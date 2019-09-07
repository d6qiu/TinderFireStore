//
//  HomeBottomControlsStackView.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 7/19/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {

    //properties cant use non static functions because self does not exist yet, order: initialize properties, self exists, init()
    static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }
    
    let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
    let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
    let superlikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
    let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
    let boostButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 100).isActive = true
//        let subviews = [#imageLiteral(resourceName: "refresh_circle"),#imageLiteral(resourceName: "dismiss_circle"),#imageLiteral(resourceName: "super_like_circle"),#imageLiteral(resourceName: "like_circle"),#imageLiteral(resourceName: "boost_circle")].map { (image) -> UIView in
//            let button = UIButton(type: .system)
//            button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
//            return button
//        }
//
//        subviews.forEach { (view) in
//            addArrangedSubview(view)
//        }
        
        [refreshButton,dislikeButton, superlikeButton, likeButton, boostButton].forEach { (button) in
            self.addArrangedSubview(button)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
