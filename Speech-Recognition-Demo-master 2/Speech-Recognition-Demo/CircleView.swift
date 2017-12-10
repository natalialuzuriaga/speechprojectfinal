//
//  CircleButton.swift
//  Speech-Recognition-Demo
//
//  Created by Natalia Luzuriaga on 12/10/17.
//  Copyright © 2017 Jennifer A Sipila. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        didSet{
            setupView()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        setupView() //will be called once access main.storyboard
    }
    func setupView() {
        layer.cornerRadius = cornerRadius //obtain radius from main.storyboard
    }
}
