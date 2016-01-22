//
//  OverlayView.swift
//  EasyFilm
//
//  Created by Oliver Hill on 1/18/16.
//  Copyright © 2016 Oliver Hill. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    
    var textLabel = UILabel()
    var isHorizontal = false{
        didSet{
            if isHorizontal{
                textLabel.text = "Filming..."
                //textLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
               // let origin = CGPoint(x: self.frame.size.width/2 + textLabel.frame.size.width/2, y: 0)
               // let size = CGSize(width: textLabel.frame.height, height: textLabel.frame.width)
                //textLabel.frame = CGRect(origin: origin, size: size)
            }
            else{
                textLabel.text = "Rotate to Film"
            }
        }
    }
    
    
    func setup(){
        textLabel.text = "Rotate to Film"
        let centerPoint = CGPoint(x: self.frame.width/2-LabelProperties.labelWidthF/2,
            y: self.frame.height/2 - LabelProperties.labelHeightF/2)
        textLabel.frame = CGRect(origin: centerPoint, size:
            CGSize(width: LabelProperties.labelWidth, height: LabelProperties.labelHeight))
        textLabel.font = UIFont(name: LabelProperties.font, size: LabelProperties.fontSize)
        textLabel.textColor = UIColor.redColor()
        self.addSubview(textLabel)
    }
    
    func didChangeTopPortrait(){
        
    }
    
    func didChangeToLandscapeRight(){
        
    }
    func didChangeToLandscapeLeft(){
        
    }

    struct LabelProperties{
        static let labelWidthF: CGFloat = 150
        static let labelWidth = 150
        static let labelHeightF: CGFloat = 50
        static let labelHeight = 50
        static let fontSize: CGFloat = 24
        static let font = "Gill Sans"
    }

}
