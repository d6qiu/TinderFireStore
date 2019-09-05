//
//  CustomTextField.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/1/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

class CustomTextField : UITextField {
    
    var padding: CGFloat
    
    init(padding: CGFloat) {
        self.padding = padding //A Swift class must initialize its own (non-inherited) properties before it calls its superclass’s designated initializer.  You can then set inherited properties after calling the superclass’s designated initializer, if you wish.
        super.init(frame: .zero) //A designated initializer must call a designated initializer from its immediate superclass.
        
        layer.cornerRadius = 25
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 50) //default first size
    }
    //right text padding wehn enter text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    //left text padding when enter text
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

