//
//  ViewController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 7/18/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

class HomeController: UIViewController {

    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let buttonsStackView = HomeBottomControlsStackView()
    

    
    let cardViewModels: [CardViewModel] = {
        let producesCardViewModel = [
            User(name: "Kelly", age: 23, profession: "Music Dj", imageNames: ["kelly1", "kelly2", "kelly3"]),
            Advertiser(title: "Slide Out Menu", brandName: "Lets Build That App", posterPhotoName: "slide_out_menu_poster"),
            User(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1", "jane2", "jane3"]),

        ] as [ProducesCardViewModel]
        
        let viewModels = producesCardViewModel.map({return $0.toCardViewModel()})
        return viewModels
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        

        setupLayout() // view.bottomAnchor is the real bottom edge
        //layout guide is a dummy view object with variables like edge constraints or height
        
        
        setupDummyCards()
        
 
        
    }
    
    @objc func handleSettings() {
        let registrationController = RegistrationController()
        present(registrationController, animated: true)
    }
    
    
    fileprivate func setupDummyCards() {
        //(0..<10).forEach
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            
            cardView.cardViewModel = cardVM
            
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
        
    }

    //MARK:- Fileprivate
    
    fileprivate func setupLayout() {
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonsStackView])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true //makes layout base on margins， otherwise base on bounds
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardsDeckView) //bring cardsdeckview to the front of z axis
    }
    

}

