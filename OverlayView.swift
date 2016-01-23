//
//  OverlayView.swift
//  EasyFilm
//
//  Created by Oliver Hill on 1/18/16.
//  Copyright © 2016 Oliver Hill. All rights reserved.
//

import UIKit
import AVFoundation

class OverlayView: UIView {
    
    //MARK: Global Variables
    var textLabel = UILabel()
    private var counter : Int?
    private var timer = NSTimer()
    private var blackbar = UIView()
    private var flash = UIButton()
    private var flashOn = false
    
    
    func setup(){

        //configure flash button
        flash.setBackgroundImage(UIImage(imageLiteral: "FlashEmpty"), forState: .Normal)
        flash.frame = CGRect(origin: CGPoint(x: frame.size.width/2-Properties.buttonSizeF/2,
            y: frame.size.height/10),
            size: CGSize(width: Properties.buttonSize, height: Properties.buttonSize))
        flash.addTarget(self, action: "flashPressed", forControlEvents: .TouchUpInside)
        addSubview(flash)
        
        //configure text label
        textLabel.text = "00:00:00"
        textLabel.textAlignment = .Center
        textLabel.textColor = UIColor.whiteColor()
    }
    
    func didChangeToPortrait(){
        timer.invalidate()
        textLabel.transform = CGAffineTransformMakeRotation(CGFloat(0))
        textLabel.removeFromSuperview()
        blackbar.removeFromSuperview()
        addSubview(flash)
    }
    
    
    func beginFilmingWithPositiveRotation(isPositive: Bool){
        toggleFlash(flashOn)
        //Configure local orientation-based variables
        var rotation = M_PI_2
        var pFromTop: CGFloat = self.frame.width - Properties.labelHeightF
        var bbOrigin = CGPoint(x:self.frame.size.width-25, y:0)
        if !isPositive{
            pFromTop = 0
            rotation = -M_PI_2
            bbOrigin = CGPointZero
        }
        
        flash.removeFromSuperview()
        
        //Configure Black Bar
        blackbar = UIView(frame: CGRect(origin: bbOrigin, size:
            CGSize(width: Properties.blackBarWidthF, height: self.frame.size.height)))
        blackbar.backgroundColor = UIColor.blackColor()
        blackbar.alpha = 0.0
        self.addSubview(blackbar)
        
        //Configure Timer
        counter = 0
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: ("updateCounter"),
            userInfo: nil,
            repeats: true)
        
        //Configure Text Label
        textLabel.text = "00:00:00"
        self.textLabel.transform = CGAffineTransformMakeRotation(CGFloat(rotation))
        textLabel.frame = CGRect(origin:
            CGPoint(x: frame.size.width/2-Properties.labelHeightF-2, y: 0),
            size: CGSize(width: Properties.labelHeightF, height: self.frame.maxY))
        addSubview(textLabel)
        
        //Animate
        UIView.animateWithDuration(1.0, animations: {
            self.textLabel.font = UIFont(name: Properties.font, size: Properties.fontSize-5)
            self.blackbar.alpha = 0.5
            self.textLabel.frame = CGRect(origin: CGPoint(x:pFromTop, y: 0),
                size: self.textLabel.frame.size)})
    }
    
    
    //MARK: Timer
    //Todo Make the time work longer
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
    
    func flashPressed(){
        //Adjust picture based on flashOn, update flashOn
        if flashOn{
            flash.setBackgroundImage(UIImage(imageLiteral: "FlashEmpty"), forState: .Normal)
        }
        else{
            flash.setBackgroundImage(UIImage(imageLiteral: "FlashFull"), forState: .Normal)
        }
        flashOn = !flashOn
        toggleFlash(true)
        
        //Animate
        flash.transform = CGAffineTransformMakeScale(0, 0)
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 15,
            options: .CurveLinear,
            animations: { self.flash.transform = CGAffineTransformIdentity},
            completion: nil
        )
    }
    
    func didSaveVideoSuccesfully(){
        //Configure UIView
        let saveView = UIView()
        let sideLength: CGFloat = Properties.saveViewRatio*frame.size.width
        let origin = CGPoint(x:frame.size.width/2-sideLength/2, y:self.frame.height/2-sideLength/2)
        saveView.frame = CGRect(origin: origin, size: CGSize(width: sideLength, height: sideLength))
        let checkView = UIImageView(frame: saveView.bounds)
        //Add ImageView
        checkView.image = UIImage(imageLiteral: "Check")
        checkView.contentMode = .ScaleToFill
        saveView.addSubview(checkView)
        saveView.sendSubviewToBack(checkView)
        saveView.alpha = 0.0
        self.addSubview(saveView)
        
        //Animate
        saveView.transform = CGAffineTransformMakeScale(0,0)
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 15,
            options: .CurveLinear,
            animations: {
                saveView.alpha = 0.5
                saveView.transform = CGAffineTransformIdentity
            },
            completion: { (didComplete: Bool) in
                if(didComplete){
                    UIView.animateWithDuration(0.5, animations: {saveView.alpha = 0.0} )
                }
            }
        )
    }

    func toggleFlash(shouldFlash : Bool){
        if shouldFlash{
            let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            if (device.hasTorch) {
                do {
                    try device.lockForConfiguration()
                    if (device.torchMode == AVCaptureTorchMode.On) {
                        device.torchMode = AVCaptureTorchMode.Off
                    } else {
                        try device.setTorchModeOnWithLevel(1.0)
                    }
                    device.unlockForConfiguration()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    //MARK: Subview Properties
    struct Properties{
        static let saveViewRatio: CGFloat = 2/3
        static let buttonSize = 75
        static let buttonSizeF: CGFloat = 75
        static let labelHeightF: CGFloat = 25
        static let labelHeight = 25
        static let blackBarWidthF: CGFloat = 25
        static let fontSize: CGFloat = 24
        static let font = "Gill Sans"
    }

}
