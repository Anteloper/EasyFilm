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
    private var counter : Int?
    private var timer = NSTimer()
    
    
    func setup(){
        textLabel.text = "Rotate to Film"
        let centerPoint = CGPoint(x: self.frame.width/2-LabelProperties.labelWidthF/2,
            y: self.frame.height/2 - LabelProperties.labelHeightF/2)
        textLabel.frame = CGRect(origin: centerPoint, size:
            CGSize(width: LabelProperties.labelWidth, height: LabelProperties.labelHeight))
        textLabel.font = UIFont(name: LabelProperties.font, size: LabelProperties.fontSize)
        textLabel.textColor = UIColor.redColor()
        textLabel.sizeToFit()
        self.addSubview(textLabel)
    }
    
    func didChangeToPortrait(){
        timer.invalidate()
        textLabel.transform = CGAffineTransformMakeRotation(CGFloat(0))
        textLabel.removeFromSuperview()
        setup()
    }
    
    func didChangeToLandscapeRight(){
        animateFilmingWithPositiveRotation(false)
    }
    
    func didChangeToLandscapeLeft(){
        animateFilmingWithPositiveRotation(true)
    }
    
    //Called when the to animate the on-screen label, takes in a bool which represents which way
    //the text should rotate
    func animateFilmingWithPositiveRotation(isPositive : Bool){
        var rotation = M_PI_2
        var pFromTop: CGFloat = self.frame.width - 30
        if !isPositive{
            pFromTop = 10
            rotation = -M_PI_2
        }
        
        textLabel.text = "00:00:00"
        self.textLabel.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
        counter = 0
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: ("updateCounter"), userInfo: nil, repeats: true)
        
        UIView.animateWithDuration(1.0, animations: {
            self.textLabel.font = UIFont(name: LabelProperties.font, size: LabelProperties.fontSize-5)
            self.textLabel.sizeToFit()
            self.textLabel.frame = CGRect(origin: CGPoint(x:pFromTop,
                y: self.frame.height/2-self.textLabel.frame.width/2 ), size: self.textLabel.frame.size)
            
        })
    }
    
    func updateCounter(){
            
         if counter! < 10{
            counter!++
            textLabel.text = "00:00:0" + String(counter!)
        }
        else if counter! < 60{
            counter!++
            textLabel.text = "00:00:" + String(counter!)
        }
         else if counter! < 600{
            
        }
    }

    //MARK: Label Properties
    struct LabelProperties{
        static let labelWidthF: CGFloat = 150
        static let labelWidth = 150
        static let labelHeightF: CGFloat = 50
        static let labelHeight = 50
        static let fontSize: CGFloat = 24
        static let font = "Gill Sans"
    }

}
