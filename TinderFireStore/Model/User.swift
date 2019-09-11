//
//  User.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 8/20/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit


struct User: ProducesCardViewModel {
    var name: String?
    var age: Int?
    var profession: String?
    var imageUrl: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var uid: String?
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["fullName"] as? String ?? ""
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
    }
    
    func toCardViewModel() -> CardViewModel {
        
        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        
        let ageString = age != nil ? "\(age!)" : "N\\A"
        attributedText.append(NSAttributedString(string: "   \(ageString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        
        let professionString = profession != nil ? profession! : " "
        attributedText.append(NSAttributedString(string: "\n\(profession ?? "")", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        var imageUrls = [String]()
        if let url = imageUrl {imageUrls.append(url)}
        if let url = imageUrl2 {imageUrls.append(url)}
        if let url = imageUrl3 {imageUrls.append(url)}

        return CardViewModel(imageNames: imageUrls, attributedString: attributedText, textAlignment: .left)
    }
}




