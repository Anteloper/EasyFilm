//
//  OverlayView.swift
//  EasyFilm
//
//  Created by Oliver Hill on 1/18/16.
//  Copyright © 2016 Oliver Hill. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    
    //MARK: Properties
    //Flags for FilmController
    var flashOn = false
    var ongoingIntroduction = true
    var isFilming = false
    //Global Variables
    private var phoneView = UIView()
    private var portraitLockView = UIView()
    private var upArrowView = UIView()
    private var orientationLabel = UILabel()
    private var textLabel = UILabel()
    private var counter : Int?
    private var circleView = UIView()
    private var timer = NSTimer()
    private var blackbar = UIView()
    private var flash = UIButton()
    private var okayButton = UIButton()
    private var whichWelcomeScreen = 0
    private var portraitPictureView = UIImageView()
    private var focusView = UIView()
    private var saveView = UIView()
    
    
    //MARK: Setup
    func setup(isFirstLaunch fl: Bool){
        //configure flash button
        if fl{
            ongoingIntroduction = true
            firstLaunch()
        }
        else{
            ongoingIntroduction = false
            configureFlashButton()
            self.addSubview(flash)
        }
    }
    
    //MARK: Changed to portrait
    func didChangeToPortrait(){
        isFilming = false
        timer.invalidate()
        textLabel.transform = CGAffineTransformMakeRotation(CGFloat(0))
        phoneView.removeFromSuperview()
        textLabel.removeFromSuperview()
        blackbar.removeFromSuperview()
        circleView.removeFromSuperview()
        addSubview(flash)
    }
    
    //MARK: Began Filming
    func didBeginFilmingWithPositiveRotation(isPositive: Bool){
        isFilming = true
        //Configure local orientation-based variables
        var rotation = M_PI_2
        var bbOrigin = CGPoint(x:self.frame.size.width-25, y:0)
        var circleYValue: CGFloat = frame.size.height/2-55
        if !isPositive{
            rotation = -M_PI_2
            bbOrigin = CGPointZero
            circleYValue = frame.size.height/2+55
        }
        clearViewFromIntroduction()
        configureBlackBar(bbOrigin)
        configureTimer()
        configureTimerLabel(CGFloat(rotation), xPos: bbOrigin)
        configureRedCircle(circleYValue)
        
        self.addSubview(blackbar)
        self.addSubview(textLabel)
        self.bringSubviewToFront(circleView)
        
        //Animate
        UIView.animateWithDuration(1.0, animations: {
            self.blackbar.alpha = 0.5
            self.textLabel.alpha = 1.0
            self.textLabel.frame = self.blackbar.frame
            }, completion: { (isComplete) in
                if(isComplete){
                    UIView.animateWithDuration(0.5,
                        delay: 0.0,
                        options: [UIViewAnimationOptions.Repeat,
                            UIViewAnimationOptions.Autoreverse,
                            UIViewAnimationOptions.CurveEaseInOut],
                        animations: {self.circleView.alpha = 1.0},
                        completion: nil)
                }
            }
        )
    }
    
    //MARK: Flash Toggled
    func flashPressed(){
        //Adjust picture based on flashOn, update flashOn
        if flashOn{
            flash.setBackgroundImage(UIImage(imageLiteral: "FlashEmpty"), forState: .Normal)
        }
        else{
            flash.setBackgroundImage(UIImage(imageLiteral: "FlashFull"), forState: .Normal)
        }
        flashOn = !flashOn

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
    
    
    //MARK: Timer
    func updateCounter(){
        counter!++
        if counter! < 10{
            textLabel.text = "00:00:0" + String(counter!)
        }
        else if counter! < 60{
            textLabel.text = "00:00:" + String(counter!)
        }
        else if counter! < 600{
            let secondsNum = counter!%60
            var secondsString = String(counter!%60)
            if secondsNum < 10{
                secondsString = "0" + String(secondsNum)
            }
            let minutes = counter!/60
            textLabel.text = "00:0" + String(minutes) + ":" + secondsString
        }
    }
    
    //MARK: Touches Began
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !ongoingIntroduction && (event?.allTouches()!.count)! == 1{
 
            if let touch: UITouch = touches.first!{
                focusView.removeFromSuperview()
                let centerPoint = touch.locationInView(self)
                configureFocusView(centerPoint)
                self.addSubview(focusView)
                UIView.animateWithDuration(1.0,
                    delay: 0.0,
                    usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 10,
                    options: [UIViewAnimationOptions.CurveEaseInOut],
                    animations: {self.focusView.transform = CGAffineTransformMakeScale(0.5, 0.5)},
                    completion: { (didComplete) in
                        if(didComplete){
                            UIView.animateWithDuration(1.0,
                                delay: 0.0,
                                options: [],
                                animations: {self.focusView.alpha = 0.0},
                                completion: nil
                            )
                        }
                    }
                )
            }
        }
    }
    
    
    //MARK: Subview Configurations
    func configureTimerLabel(rotation: CGFloat, xPos: CGPoint){
        textLabel.text = "00:00:00"
        self.textLabel.transform = CGAffineTransformMakeRotation(rotation)
        textLabel.frame = CGRect(origin: CGPoint(x:frame.size.width/2, y:0),size:blackbar.frame.size)
        textLabel.alpha = 1.0
        textLabel.textAlignment = .Center
        textLabel.textColor = UIColor.whiteColor()
        self.textLabel.font = UIFont(name: Properties.font, size: Properties.timerFontSize)
        self.bringSubviewToFront(textLabel)
    }
    
    func configureBlackBar(bbOrigin: CGPoint){
        blackbar.removeFromSuperview()
        blackbar = UIView(frame: CGRect(origin: bbOrigin, size:
            CGSize(width: Properties.blackBarWidthF, height: self.frame.size.height)))
        blackbar.backgroundColor = UIColor.blackColor()
        blackbar.alpha = 0.5
        self.bringSubviewToFront(blackbar)
    }
    
    func configureTimer(){
        timer.invalidate()
        counter = 0
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: ("updateCounter"),
            userInfo: nil,
            repeats: true)
    }
    
    func configureFlashButton(){
        flash.setBackgroundImage(UIImage(imageLiteral: "FlashEmpty"), forState: .Normal)
        flash.frame = CGRect(origin: CGPoint(x: frame.size.width/2-Properties.flashbuttonSizeF/2,
            y: frame.size.height/10),
            size: CGSize(width: Properties.flashbuttonSize, height: Properties.flashbuttonSize))
        flash.addTarget(self, action: "flashPressed", forControlEvents: .TouchUpInside)
    }
    
    func configureRedCircle(yValue: CGFloat){
        circleView.removeFromSuperview()
        if !ongoingIntroduction{
            circleView.frame = CGRect(origin: CGPoint(x: (blackbar.frame.origin.x +
                                Properties.blackBarWidthF/2)-Properties.circleSizeF/2,
                                y: yValue), size:
                                CGSize(width: Properties.circleSizeF,
                                height: Properties.circleSizeF))
        }
            
        else{
            /*circleView.frame = CGRect(origin:CGPoint(x: phoneView.center.x - Properties.circleSizeF,
                y: phoneView.center.y - Properties.circleSizeF), size:
                CGSize(width:Properties.circleSizeF*2, height: Properties.circleSizeF*2))*/
        }
        
        circleView.alpha = 0.0
        //USED TO BE .BOUNDS TODO
        let circleImage = UIImageView(frame: circleView.bounds)
        circleImage.image = UIImage(imageLiteral: "Circle")
        circleImage.contentMode = .ScaleToFill
        circleView.addSubview(circleImage)
        self.bringSubviewToFront(circleView)
        self.addSubview(circleView)
        
        
    }
    
    func configureFocusView(centerPoint: CGPoint){
        focusView = UIView(frame: CGRect(origin: CGPoint(x:centerPoint.x-(Properties.focusBeginSizeF/2),
            y: centerPoint.y - Properties.focusBeginSizeF/2),
            size: CGSize(width: Properties.focusBeginSizeF,
            height: Properties.focusBeginSizeF)))
        let focusImageView = UIImageView(frame: focusView.bounds)
        focusImageView.image = UIImage(imageLiteral: "Focus")
        focusImageView.contentMode = .ScaleToFill
        focusView.addSubview(focusImageView)
        focusView.alpha = 0.6
        self.bringSubviewToFront(focusView)
    }
    func configureAndAnimateSaveView(){
        //Configure UIView
        let sideLength: CGFloat = Properties.saveViewRatio*frame.size.width
        let origin = CGPoint(x:frame.size.width/2-sideLength/2, y:self.frame.height/2-sideLength/2)
        saveView.frame = CGRect(origin: origin, size: CGSize(width: sideLength, height: sideLength))
        
        //Add ImageView
        let checkView = UIImageView(frame: saveView.bounds)
        checkView.image = UIImage(imageLiteral: "Check")
        checkView.contentMode = .ScaleToFill
        saveView.addSubview(checkView)
        saveView.sendSubviewToBack(checkView)
        saveView.alpha = 0.75
        self.addSubview(saveView)
        
        
        //Animate
        saveView.transform = CGAffineTransformMakeScale(0,0)
        UIView.animateWithDuration(0.75,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 15,
            options: .CurveLinear,
            animations: {
                self.saveView.transform = CGAffineTransformIdentity
            },
            completion: { (didComplete: Bool) in
                if(didComplete){
                    UIView.animateWithDuration(1.0, animations: {self.saveView.alpha = 0.0} )
                }
            }
        )

    }
    
    func clearViewFromIntroduction(){
        flash.removeFromSuperview()
        phoneView.removeFromSuperview()
        portraitLockView.removeFromSuperview()
        upArrowView.removeFromSuperview()
        orientationLabel.removeFromSuperview()
        okayButton.removeFromSuperview()
        self.backgroundColor = UIColor.clearColor()
    }
    
    
    //MARK: First Launch
    func firstLaunch(){
        backgroundColor = UIColor.whiteColor()
        alpha = 0.85
        
        self.flash.removeFromSuperview()
        
        //Configure Orientation Label
        orientationLabel.text = "Welcome!\n\n\n We see you're new so here's a quick run down."
        let labelWidth: CGFloat = Properties.orientationLabelRatio*frame.size.width
        let lOrigin = CGPoint(x:frame.size.width/2-labelWidth/2, y:frame.height/8)
        orientationLabel.frame = CGRect(origin: lOrigin,
            size: CGSize(width: labelWidth, height: 300))
        orientationLabel.font = UIFont(name: Properties.font, size: Properties.orientationFontSize)
        orientationLabel.numberOfLines = 0
        orientationLabel.textAlignment = .Center
        orientationLabel.lineBreakMode = .ByWordWrapping
        orientationLabel.textColor = UIColor(red: 51/255.0,
            green: 89/255.0,
            blue: 254/255.0,
            alpha: 0.75)
        self.bringSubviewToFront(orientationLabel)
        self.addSubview(orientationLabel)
        
        //Configure Okay Button
        okayButton.setAttributedTitle(NSAttributedString(string: "Okay"), forState: .Normal)
        okayButton.backgroundColor = orientationLabel.textColor
        let buttonWidth: CGFloat = Properties.okayButtonRatio*frame.size.width
        let bOrigin = CGPoint(x: frame.size.width/2-buttonWidth/2, y: (frame.height*7)/8)
        okayButton.titleLabel!.font = UIFont(name: Properties.font, size: 18)
        okayButton.tintColor = UIColor.whiteColor()
        okayButton.setTitleColor(UIColor.whiteColor(), forState:  .Normal)
        okayButton.frame = CGRect(origin: bOrigin,
            size: CGSize(width:
                buttonWidth,
                height: Properties.buttonHeight))
        okayButton.addTarget(self, action: "nextScreen", forControlEvents: .TouchUpInside)
        self.addSubview(okayButton)
        whichWelcomeScreen++
    }
    
    func nextScreen(){
        switch(whichWelcomeScreen)
        {
            //Add Pictures for Orientation Lock
        case 1:
            firstScreen()
            //Add arrow for flash introduction
        case 2:
            secondScreen()
            //Rotate to film screen
        case 3:
            thirdScreen()
            //Rotate to stop screen
        case 4:
            fourthScreen()
            //Check mark screen
        case 5:
            fifthScreen()
        case 6:
            sixthScreen()
            //Happy filming screen
        case 7:
            seventhScreen()
            //Clear screen
        default: break
        }
    }

    //MARK: Orientation Screens
    func firstScreen(){
        whichWelcomeScreen++
        orientationLabel.text = "Make sure portrait orientation lock is off"
        orientationLabel.frame = CGRect(origin: CGPoint(x: orientationLabel.frame.origin.x,
            y:orientationLabel.frame.origin.y-30),
            size: CGSize(width: orientationLabel.frame.size.width,
                height: 100))
        orientationLabel.font = UIFont(name: Properties.font, size: Properties.orientationFontSize-3)
        let sideLength: CGFloat = Properties.portraitLockRatio*frame.size.width
        let origin = CGPoint(x:frame.size.width/2-sideLength/2, y:self.frame.height)
        portraitLockView.frame = CGRect(origin: origin, size:
            CGSize(width: sideLength, height: Properties.portraitLockHeight))
        portraitPictureView = UIImageView(frame: portraitLockView.bounds)
        portraitPictureView.alpha = 1.0
        portraitPictureView.image = UIImage(imageLiteral: "LockOn")
        portraitPictureView.contentMode = .ScaleToFill
        portraitLockView.addSubview(portraitPictureView)
        portraitLockView.sendSubviewToBack(portraitPictureView)
        self.addSubview(portraitLockView)
        
        UIView.animateWithDuration(1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 15,
            options: .CurveLinear,
            animations: {
                self.portraitLockView.frame = CGRect(origin:
                    CGPoint(x:self.portraitLockView.frame.origin.x,
                        y: self.orientationLabel.frame.height +
                            self.orientationLabel.frame.origin.y),
                    size: self.portraitLockView.frame.size)
            },
            completion: { (didFinish: Bool) -> () in
                dispatch_async(dispatch_get_main_queue(), {
                    if(didFinish){
                        self.portraitPictureView.animationImages = [UIImage(imageLiteral: "LockOff"),
                            UIImage(imageLiteral: "LockOn")]
                        self.portraitPictureView.animationDuration = 2.0
                        self.portraitPictureView.startAnimating()
                    }
                })
            }
        )
    }
    
    func secondScreen(){
        whichWelcomeScreen++
        portraitPictureView.removeFromSuperview()
        let sideLength = frame.width*Properties.upArrowViewRatio
        upArrowView.frame = CGRect(origin:
            CGPoint(x:frame.width,
                y:frame.height/2 - sideLength/2),
            size: CGSize(width: sideLength,
                height: sideLength))
        let arrowImageView = UIImageView(frame: upArrowView.bounds)
        arrowImageView.image = UIImage(imageLiteral: "UpArrow")
        arrowImageView.contentMode = .ScaleToFill
        arrowImageView.alpha = 1.0
        upArrowView.addSubview(arrowImageView)
        orientationLabel.text = "Toggle flash here"
        orientationLabel.frame.origin = CGPoint(x:orientationLabel.frame.origin.x,
            y: orientationLabel.frame.origin.y+50)
        orientationLabel.textAlignment = .Center
        orientationLabel.alpha = 0.0
        configureFlashButton()
        addSubview(upArrowView)
        addSubview(flash)
        UIView.animateWithDuration(0.75, animations: {self.orientationLabel.alpha = 0.75})
        UIView.animateWithDuration(0.3,
                delay: 0.3,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 10,
                options: [],
                animations: {
                    self.upArrowView.frame.origin =
                        CGPoint(x:self.frame.width/2 - sideLength/2,
                        y:self.frame.height/2 - sideLength/2)
                },
                completion: nil
        )
    }
    
    func thirdScreen(){
        whichWelcomeScreen++
        upArrowView.removeFromSuperview()
        orientationLabel.text = "Rotate to Film"
        orientationLabel.alpha = 0.0
        //Configure UIView
        let sideLength: CGFloat = Properties.phoneViewRatio*frame.size.width
        let origin = CGPoint(x:frame.size.width/2-sideLength/2,
            y:self.frame.height/2-sideLength/2)
        phoneView.frame = CGRect(origin: origin, size: CGSize(width: sideLength,
            height: sideLength))
        
        //Add ImageView
        let pictureView = UIImageView(frame: phoneView.bounds)
        pictureView.image = UIImage(imageLiteral: "Phone")
        pictureView.contentMode = .ScaleToFill
        phoneView.addSubview(pictureView)
        phoneView.sendSubviewToBack(pictureView)
        self.addSubview(phoneView)

        
        //Animate
        UIView.animateWithDuration(0.75, animations: {self.orientationLabel.alpha = 0.75})
        UIView.animateWithDuration(1.5, delay: 0.75, options: [], animations: {
            self.orientationLabel.alpha = 0.75
            self.phoneView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            }, completion: { (didComplete) in
                if didComplete{
                    self.configureRedCircle(self.frame.height/2)
                    self.addSubview(self.circleView)
                    UIView.animateWithDuration(0.5,
                        delay: 0.0,
                        options: [UIViewAnimationOptions.Repeat,
                            UIViewAnimationOptions.Autoreverse,
                            UIViewAnimationOptions.CurveEaseInOut],
                        animations: {self.circleView.alpha = 1.0},
                        completion: nil)
                }
            }
        )
    }
    
    func fourthScreen(){
        whichWelcomeScreen++
        circleView.removeFromSuperview()
        orientationLabel.text = "Rotate back to finish"
        UIView.animateWithDuration(1.0,
            delay: 0.3,
            options: [],
            animations: { self.phoneView.transform = CGAffineTransformMakeRotation(CGFloat(0))},
            completion: nil)
        
    }
    
    func fifthScreen(){
        whichWelcomeScreen++
        phoneView.removeFromSuperview()
        orientationLabel.frame.origin = CGPoint(x: orientationLabel.frame.origin.x,
            y: orientationLabel.frame.origin.y + 30)
        orientationLabel.alpha = 0.0
        orientationLabel.text = "You'll see the check when your video saves."
        UIView.animateWithDuration(0.5,
            animations: {self.orientationLabel.alpha = 0.75},
            completion: {(didComplete) in
                if(didComplete){
                    self.configureAndAnimateSaveView()
                }
            }
        )
    }
    func sixthScreen(){
        whichWelcomeScreen++
        self.orientationLabel.font = UIFont(name: Properties.font, size: 38)
        self.orientationLabel.frame.origin = CGPoint(x:self.orientationLabel.frame.origin.x,
            y:self.frame.height/2-self.orientationLabel.frame.size.height/2-20)
        self.orientationLabel.alpha = 0.0
        orientationLabel.text = "Thats it!\n Happy Filming"
        UIView.animateWithDuration(0.5, animations: { self.orientationLabel.alpha = 0.75})

    }
    func seventhScreen(){
        backgroundColor = UIColor.clearColor()
        circleView.removeFromSuperview()
        okayButton.removeFromSuperview()
        orientationLabel.removeFromSuperview()
        ongoingIntroduction = false
    }
    
    //MARK: Subview Properties
    struct Properties{
        static let upArrowViewRatio: CGFloat = 1/2
        static let orientationLabelRatio: CGFloat = 3/4
        static let okayButtonRatio: CGFloat = 7/8
        static let saveViewRatio: CGFloat = 3/4
        static let phoneViewRatio: CGFloat = 2/3
        static let portraitLockRatio: CGFloat = 2/3
        static let portraitLockHeight: CGFloat = 300
        static let buttonHeight: CGFloat = 30
        static let flashbuttonSize = 75
        static let flashbuttonSizeF: CGFloat = 75
        static let labelHeightF: CGFloat = 25
        static let labelHeight = 25
        static let blackBarWidthF: CGFloat = 25
        static let timerFontSize: CGFloat = 24
        static let orientationFontSize: CGFloat = 30
        static let circleSizeF : CGFloat = 8
        static let focusBeginSizeF : CGFloat = 240
        static let font = "Gill Sans"
    }
}
