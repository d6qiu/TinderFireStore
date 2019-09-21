//
//  UserDetailsController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/18/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
class UserDetailsController: UIViewController, UIScrollViewDelegate {

    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
            infoLabel.textAlignment = cardViewModel.textAlignment
            swipingPhotosController.cardViewModel = cardViewModel
//            guard let firstImageUrl = cardViewModel.imageUrls.first, let url = URL(string: firstImageUrl) else {return}
//            imageView.sd_setImage(with: url) //if imported in another file, dont need import in this file
        }
    }
    
    let swipingPhotosController = SwipingPhotosController(isCardViewMode: false) //cant use default constructors if have custom 
    
    lazy var scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true //bounces when scroll down, but then safe area will eat the top portion
        sv.contentInsetAdjustmentBehavior = .never //safe area wont modify the contents in scroll view
        sv.delegate = self
        return sv
    }()
    
    
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "name \nstudent \nbio"
        label.numberOfLines = 0
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTapDismiss), for: .touchUpInside)
        return button
    }()
    
    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
    lazy var superLikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDislike))
    lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleDislike))

    @objc fileprivate func handleDislike() {
        
    }
    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.clipsToBounds = true
        return button
    }
    
    fileprivate func setupLayout() {
        view.addSubview(scrollView)
        view.backgroundColor = .white
        view.layer.opacity = 1
        scrollView.fillSuperview()
        
        let swipingView = swipingPhotosController.view!
        scrollView.addSubview(swipingView)
        //cannot constraint the width and height of swipingview otherwise cannot do zoom in animation, since the animation changes its width and height
//        swipingView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: view.frame.width, height: view.frame.width))
        //hard to use autolayout in scrool view animation than frame
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: swipingView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 24), size: .init(width: 50, height: 50))
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
    }
    
    fileprivate let extraSwipingViewHeight: CGFloat = 80
    
    //after viewdidload and everytime view change bound
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingViewHeight) //since i didnt use anchor imageview, its frame is changed by other ui elements when layout subviews from its orginal frame, that why need to change it back here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupVisualBlurEffectView()
        setupBottomControls()
    }
    
    fileprivate func setupBottomControls() {
        let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.spacing = -32 //gets items closer 
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let imageView = swipingPhotosController.view!
        let changeY = -scrollView.contentOffset.y //calculations goes like this 0 - current y, thats why if you scroll down, its negative, thats why need to put a  mius sign infront
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        imageView.frame = CGRect(x: min(0,-changeY), y: min(0,-changeY), width: width, height: width + extraSwipingViewHeight)
        
    }
    
    @objc fileprivate func handleTapDismiss() {
        self.dismiss(animated: true)
    }
    

    

}
