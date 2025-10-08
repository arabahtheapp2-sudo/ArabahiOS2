//
//  CustomView.swift
//  Sqimey
//
//  Created by apple on 27/06/19.
//  Copyright © 2019 apple. All rights reserved.


import UIKit
@IBDesignable

class CustomView: UIView {

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable public var isShadow: Bool = false
    
    @IBInspectable public var cornerRadius: CGFloat = 2.5 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable public var shadowColor: UIColor = UIColor.black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable public var shadowOpacity: Float = 0.5 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable public var shadowOffset: CGSize = CGSize(width: 0, height: 3) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable public var shadowRadius: CGFloat = 3 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable public var masksToBounds: Bool = false {
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }

    @IBInspectable public var clipsToBound: Bool = false {
        didSet {
            self.clipsToBounds = clipsToBound
        }
    }

}
