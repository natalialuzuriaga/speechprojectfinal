//
//  CircleButton.swift
//  Speech-Recognition-Demo
//
//  Created by Natalia Luzuriaga
//  Copyright © 2017 Team. All rights reserved.

//

import UIKit

@IBDesignable
class CircleButton: UIButton {
    
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

