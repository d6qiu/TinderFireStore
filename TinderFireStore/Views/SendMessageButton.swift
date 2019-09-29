//
//  SendMessageButton.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/28/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

class SendMessageButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 1, green: 0, blue: 0.3975645304, alpha: 1)
        let rightColor = #colorLiteral(red: 1, green: 0.3150879443, blue: 0.2198732197, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
        //self.layer.addSublayer(gradientLayer) //adds sublayer on top
        
        gradientLayer.frame = rect //rect is button's own coordination, gradientlayer superview is button
        
    }
    

}
