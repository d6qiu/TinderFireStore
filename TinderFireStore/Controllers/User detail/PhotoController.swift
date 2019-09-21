//
//  PhotoController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/20/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

class PhotoController: UIViewController {
    
    let imageView = UIImageView()
    
    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url)
        }
        imageView.layer.opacity = 1
        super.init(nibName: nil, bundle: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true //avoid pics overlapping each other
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
