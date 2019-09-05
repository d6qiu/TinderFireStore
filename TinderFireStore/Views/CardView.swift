//
//  CardView.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 8/11/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

class CardView: UIView {

    
    var cardViewModel: CardViewModel! {
        didSet {
            let imageName = cardViewModel.imageNames.first ?? "" //imageNames[0] not defined optional, if count == 0 will crash
            imageView.image = UIImage(named: imageName)
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageNames.count).forEach { (_) in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            
            setupImageIndexObserver()
            
        }
    }
    
    
    fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c")) //setting fileprivate is for easy locate bugs, bugs of this property must be within this file
    fileprivate let informationLabel = UILabel()
    
    //Configurations
    fileprivate let threshold: CGFloat = 80

    fileprivate let gradientLayer = CAGradientLayer()

    fileprivate let barsStackView = UIStackView()
    
    fileprivate var imageIndex = 0
    
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        
        //handlePan automatically capture panGesture as gesture parameter, recognizer captures gesture, observer captures notification
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    //goal is to react when a property in another class changes, defines the reaction here
    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self](idx, image) in //avoid memorhy cycle
            self?.imageView.image = image
            self?.barsStackView.arrangedSubviews.forEach({ (v) in
                v.backgroundColor = self?.barDeselectedColor
            })
            self?.barsStackView.arrangedSubviews[idx].backgroundColor = .white
        }
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil) //closest responder is self
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
        
    }
    
    fileprivate func setupLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true //if false exceeding frames from bounds are not clipped
        
        
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.fillSuperview()
        
        setupBarsStackView()
        
        setupGradientLayer() //self.frame is zero at this point, wont be zero when init is done
        
        
        addSubview(informationLabel) //add subview upon the previous subview, z position + 1
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.textColor = .white
        informationLabel.numberOfLines = 0
    }
    
    fileprivate func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
        
    }
    
    fileprivate func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5,1.1] //gradient from top to bottom 0 being top 1 being bottom
        
        layer.addSublayer(gradientLayer)
    
    }
    //executed when view draws itself, this stage, cardview or self.frame is not zero anymore
    override func layoutSubviews() {
        gradientLayer.frame = self.frame //self.frame is not zero only after self.init(), cardview is not controller's view so cant use view.bounds 
    }
    
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations() //remove all unfinished animations when new animation begin
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            ()
        }
    }
    //view  rotates and translate according to user panning
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)

        let degrees: CGFloat = translation.x / 20 //minimize rotatation per translation
        let angle = degrees * .pi / 180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
        
    }
    
    //when user stops pannign return to original position
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        //nil will get you this view
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            
            if shouldDismissCard {
                self.frame = CGRect(x: 600 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
            // below lines will make card go up and go left at the same time, above will go up and then go left
//                let offScreenTransform = self.transform.translatedBy(x: 600, y: 0)
//                self.transform = offScreenTransform
            } else {
                self.transform = .identity
                
            }
        }) { (_) in
            self.transform = .identity //this line suppose to return cards back when swiped but since removeFromSuperView anyuway so this line is useless
            if shouldDismissCard {
                self.removeFromSuperview()
//                self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.width, height: self.superview!.frame.height)
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
