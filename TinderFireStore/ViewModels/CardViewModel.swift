//
//  CardViewModel.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 8/22/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    let uid: String
    let imageUrls: [String] //one slide include mutiple photots 
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    //only invoked when user taps card, activly changeable by user, model shoudl react to changes by user 
    fileprivate var imageIndex = 0 {
        didSet { //in a way didSet is the observer, observe change of imageIndex, should trigger changes in UI
            let imageUrl = imageUrls[imageIndex]
            //let image = UIImage(named: imageName) //uiimage has init optional
            imageIndexObserver?(imageIndex, imageUrl) //calls this everytime imageIndex sets a new value
        }
    }
    
    
    init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.uid = uid
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    //Reactuve programming
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceToNextPhoto() {
        let newIndex = min(imageIndex + 1, imageUrls.count - 1)
        if newIndex != imageIndex { //does this check so cardview wont call the same url session again if same index
            imageIndex = newIndex
        }
    }
    
    func goToPreviousPhoto() {
        let newIndex = max(0,imageIndex - 1)
        if newIndex != imageIndex {
            imageIndex = newIndex
        }
    }
}




