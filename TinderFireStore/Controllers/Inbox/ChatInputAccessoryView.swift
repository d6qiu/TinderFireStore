//
//  ChatInputAccessoryView.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 12/16/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

//protocol textBeginChange: AnyObject {
//    func textDidBeginEditing()
//}

class ChatInputAccessView: UIView {
    
    let textView = UITextView()
    let sendButton = UIButton(title: "Send", titleColor: .black, font: .boldSystemFont(ofSize: 14), backgroundColor: .white, target: nil, action: nil)
    
    let placeHolderLabel = UILabel(text: "Enter message", font: .systemFont(ofSize: 16), textColor: .lightGray)

//    weak var delegate:textBeginChange!
    
    //make scalable views depends on their content, in this case text views?
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        alpha = 1
        //height -8 to make shadow go upward, radius is corner radius?
        setupShadow(opacity: 0.1, radius: 8, offset: .init(width: 0, height: -8), color: .lightGray)

        //resize by expanding height
        autoresizingMask = .flexibleHeight
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        
        //self observe textdidchangenotificaiton
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleTextBeginChange), name: UITextView.textDidBeginEditingNotification, object: nil)

        hstack(textView, sendButton.withSize(.init(width: 60, height: 60)), alignment: .center).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
        addSubview(placeHolderLabel)
        placeHolderLabel.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: sendButton.leadingAnchor, padding: .init(top: 0, left: 18, bottom: 0, right: 0))
        placeHolderLabel.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        
//        let stackview = UIStackView(arrangedSubviews: [textView, sendButton])
//        stackview.alignment = .center
//        sendButton.constrainHeight(60)
//        sendButton.constrainWidth(60)
//
//        redView.addSubview(stackview)
//        stackview.fillSuperview()
//
//        //so stackview content stays inside stackview's layout margin?
//        stackview.isLayoutMarginsRelativeArrangement = true
    }
    
    @objc fileprivate func handleTextChange() {
        placeHolderLabel.isHidden = textView.text.count != 0
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self) //remove observer to prevent retain cycle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
