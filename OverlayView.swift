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
        self.addSubview(textLabel)
    }
    
    func didChangeToPortrait(){
        textLabel.text = "Rotate to Film"
        timer.invalidate()
        textLabel.transform = CGAffineTransformMakeRotation(CGFloat(0))
    }
    
    func didChangeToLandscapeRight(){
        textLabel.text = "00:00:00"
        counter = 0
        textLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: ("updateCounter"), userInfo: nil, repeats: true)
    }
    func didChangeToLandscapeLeft(){
        textLabel.text = "00:00:00"
        counter = 0
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: ("updateCounter"), userInfo: nil, repeats: true)
        textLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
    }
    
    func updateCounter(){
            
         if counter! < 10{
            counter!++
            textLabel.text = "00:00:0" + String(counter!)
        }
        else if counter! < 60{
            counter!++
            textLabel.text = "00:00:0" + String(counter!)
        }
         else if counter! < 600{
            
        }
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
