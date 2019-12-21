//
//  MatchesPoolHeader..swift
//  TinderFireStore
//
//  Created by wenlong qiu on 12/20/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

class MatchesPoolHeader: UICollectionReusableView {
    
    let newMatchesLabel = UILabel(text: "New Matches", font: .boldSystemFont(ofSize: 18), textColor: UIColor.rgb(red: 254, green: 26, blue: 0))
    let horizontalViewController = MatchesHorizontalController()
    let messagesLabel = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 18), textColor: UIColor.rgb(red: 254, green: 26, blue: 0))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        horizontalViewController.view.backgroundColor = .white
        horizontalViewController.view.alpha = 1
        
        
        stack(stack(newMatchesLabel).padLeft(20), //so only horizontalviewcontroller will not be padded
              horizontalViewController.view,
              stack(messagesLabel).padLeft(20),
              spacing: 20).withMargins(.init(top: 20, left: 0, bottom: 8, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
