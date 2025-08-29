//
//  CustomButton.swift
//  Sqimey
//
//  Created by apple on 27/06/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable

class CustomButton: UIButton {
    
    @IBInspectable public var imageColor: UIColor = .clear {
        didSet {
            
            if imageColor != .clear {
                
                if  let image = self.image(for: UIControl.State()) {
                    let tmImage  = image.withRenderingMode(.alwaysTemplate)
                    self.setImage(tmImage, for: UIControl.State())
                    self.tintColor = imageColor
                    
                }else if let image = self.backgroundImage(for: UIControl.State()) {
                    let tmImage  = image.withRenderingMode(.alwaysTemplate)
                    self.setBackgroundImage(tmImage, for: UIControl.State())
                    self.tintColor = imageColor
                }
            }
            
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
    @IBInspectable public var shadowRadius : CGFloat = 3
    {
        didSet
        {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable public var borderColor: UIColor =  UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            //mkLayer.setMaskLayerCornerRadius(cornerRadius)
        }
    }
    @IBInspectable public var borderWidth: CGFloat =  0 {
        didSet {
            layer.borderWidth = borderWidth
            //mkLayer.setMaskLayerCornerRadius(cornerRadius)
        }
    }
    @IBInspectable public var masksToBounds : Bool = false
    {
        didSet
        {
            layer.masksToBounds = masksToBounds
        }
    }
    
    @IBInspectable public var clipsToBound : Bool = false
    {
        didSet
        {
            self.clipsToBounds = clipsToBound
        }
    }

    // MARK - initilization
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    // MARK - setup methods
    private func setupLayer() {
        
        adjustsImageWhenHighlighted = false
        
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if isShadow == true
        {
            let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            layer.masksToBounds = masksToBounds
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = shadowOpacity
            layer.shadowPath = shadowPath.cgPath
        }
        
        if isGradient == true
        {
            gradientLayer.frame = self.bounds
            gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
            if isHorizontalGradient{
                //                       gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                //                       gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.4)
                gradientLayer.endPoint = CGPoint(x: 0, y: 2.0)
            }
            self.layer.insertSublayer(gradientLayer, at: 0)
            //            self.layer.addSublayer(gradientLayer)
        } else {
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    @IBInspectable public var isGradient : Bool = false{
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var isHorizontalGradient : Bool = true{
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var firstColor : UIColor = UIColor.orange{
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var secondColor : UIColor  = UIColor.yellow{
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var thirdColor : UIColor = UIColor.orange{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    lazy  var gradientLayer: CAGradientLayer = {
        return CAGradientLayer()
    }()
    
    func set(gradientColors firstColor:UIColor , secondColor:UIColor){
        self.firstColor = firstColor
        self.secondColor = secondColor
        self.setNeedsLayout()
    }
}
class ButtonWithImage: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left:5 , bottom: 5, right: (bounds.width - 35))
            titleEdgeInsets = UIEdgeInsets(top: 0, left: (imageView?.frame.width)!, bottom: 0, right: 0)
        }
    }
}
