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
    let imageNames: [String] //one slide include mutiple photots 
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    //activly changeable by user, model shoudl react to changes by user 
    fileprivate var imageIndex = 0 {
        didSet { //in a way didSet is the observer, observe change of imageIndex, should trigger changes in UI
            let imageName = imageNames[imageIndex]
            let image = UIImage(named: imageName) //uiimage has init optional
            imageIndexObserver?(imageIndex, image) //calls this everytime imageIndex sets a new value
        }
    }
    
    
    init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageNames = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    //Reactuve programming
    var imageIndexObserver: ((Int, UIImage?) -> ())?
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageNames.count - 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(0,imageIndex - 1)
    }
}




