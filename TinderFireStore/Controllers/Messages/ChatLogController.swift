//
//  ChatLogController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 10/1/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

struct Message {
    
}

class MessageCell: ListCell<Message> {
    override var item: Message! {
        didSet {
            
        }
    }
}

class ChatLogController: ListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout{
    
    let messageNavBar = MessagesNavBar()
    
    fileprivate let navBarHeight:CGFloat = 120
    
    fileprivate let match: Match
    
    init(match: Match) {
        self.match = match
        super.init()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(messageNavBar)
        messageNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        collectionView.contentInset.top = navBarHeight
        
        messageNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    //so collectionview content below shadow
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 100)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
