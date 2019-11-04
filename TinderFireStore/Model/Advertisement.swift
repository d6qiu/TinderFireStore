//
//  Advertiser.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 8/22/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

struct Advertisement: ProducesCardViewModel {
    let title: String
    let brandName: String
    let posterPhotoName: String
    
    func convertModelToPosterViewModel() -> PosterViewModel {
        let attributedString = NSMutableAttributedString(string: title
            , attributes: [.font:  UIFont.systemFont(ofSize: 34, weight: .heavy)])
        attributedString.append(NSAttributedString(string: "\n" + brandName, attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold)]))
        return PosterViewModel(uid: "", imageNames: [posterPhotoName], attributedString: attributedString, textAlignment: .center)
    }
}
