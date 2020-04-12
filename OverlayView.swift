//
//  OverlayView.swift
//  EasyFilm
//
//  Created by Oliver Hill on 1/18/16.
//  Copyright © 2016 Oliver Hill. All rights reserved.


import UIKit

class OverlayView: UIView {
    
    //MARK: Properties
    
    //Flags for FilmController
    internal var flashOn = false
    internal var ongoingIntroduction = true
    internal var isFilming = false
    
    //File Variables
    fileprivate var phoneView = UIView()
    fileprivate var upArrowView = UIView()
    fileprivate var orientationLabel = UILabel()
    fileprivate var textLabel = UILabel()
    fileprivate var counter : Int?
    fileprivate var circleView = UIView()
    fileprivate var timer = Timer()
    fileprivate var blackbar = UIView()
    fileprivate var flash = UIButton()
    fileprivate var okayButton = UIButton()
    fileprivate var whichWelcomeScreen = 0
    fileprivate var focusView = UIView()
    fileprivate var saveView = UIView()
    
    
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
        textLabel.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        phoneView.removeFromSuperview()
        textLabel.removeFromSuperview()
        blackbar.removeFromSuperview()
        circleView.removeFromSuperview()
        addSubview(flash)
    }
    
    //MARK: Began Filming
    func didBeginFilmingWithPositiveRotation(_ isPositive: Bool){
        isFilming = true
        //Configure local orientation-based variables
        var rotation = Double.pi/2
        var bbOrigin = CGPoint(x:self.frame.size.width-25, y:0)
        var circleYValue: CGFloat = frame.size.height/2-55
        if !isPositive{
            rotation = -(Double.pi/2)
            bbOrigin = CGPoint.zero
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
        UIView.animate(withDuration: 1.0, animations: {
            self.blackbar.alpha = 0.5
            self.textLabel.alpha = 1.0
            self.textLabel.frame = self.blackbar.frame
            }, completion: { (isComplete) in
                if(isComplete){
                    UIView.animate(withDuration: 0.5,
                        delay: 0.0,
                        options: [UIView.AnimationOptions.repeat, UIView.AnimationOptions.autoreverse],
                        animations: {self.circleView.alpha = 1.0},
                        completion: nil)
                }
            }
        )
    }
    
    //MARK: Flash Toggled
    @objc func flashPressed(){
        //Adjust picture based on flashOn, update flashOn
        if flashOn{
            flash.setBackgroundImage(UIImage(named: "FlashEmpty"), for: UIControl.State())
        }
        else{
            flash.setBackgroundImage(UIImage(named: "FlashFull"), for: UIControl.State())
        }
        flashOn = !flashOn

        //Animate
        flash.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 15,
            options: .curveLinear,
            animations: { self.flash.transform = CGAffineTransform.identity},
            completion: nil
        )
    }
    
    
    //MARK: Timer
    @objc func updateCounter(){
        counter! += 1
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
    
    //MARK: Focus
    func animateFocus(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !ongoingIntroduction && (event?.allTouches!.count)! == 1{
            let touch: UITouch = touches.first!
            focusView.removeFromSuperview()
            let centerPoint = touch.location(in: self)
            configureFocusView(centerPoint)
            self.addSubview(focusView)
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 10,
                           options: UIView.AnimationOptions(),
                           animations: {self.focusView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)},
                           completion: { (didComplete) in
                            if(didComplete){
                                UIView.animate(withDuration: 1.0,
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
    
    
    //MARK: Subview Configurations
    func configureTimerLabel(_ rotation: CGFloat, xPos: CGPoint){
        textLabel.text = "00:00:00"
        self.textLabel.transform = CGAffineTransform(rotationAngle: rotation)
        textLabel.frame = CGRect(origin: CGPoint(x:frame.size.width/2, y:0),size:blackbar.frame.size)
        textLabel.alpha = 1.0
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        self.textLabel.font = UIFont(name: Properties.font, size: Properties.timerFontSize)
        self.bringSubviewToFront(textLabel)
    }
    
    func configureBlackBar(_ bbOrigin: CGPoint){
        blackbar.removeFromSuperview()
        blackbar = UIView(frame: CGRect(origin: bbOrigin, size:
            CGSize(width: Properties.blackBarWidthF, height: self.frame.size.height)))
        blackbar.backgroundColor = UIColor.black
        blackbar.alpha = 0.5
        self.bringSubviewToFront(blackbar)
    }
    
    func configureTimer(){
        timer.invalidate()
        counter = 0
        timer = Timer.scheduledTimer(timeInterval: 1,
            target: self,
            selector: (#selector(OverlayView.updateCounter)),
            userInfo: nil,
            repeats: true)
    }
    
    func configureFlashButton(){
        flash.setBackgroundImage(UIImage(named: "FlashEmpty"), for: UIControl.State())
        flash.frame = CGRect(origin: CGPoint(x: frame.size.width/2-Properties.flashbuttonSizeF/2,
            y: frame.size.height/12),
            size: CGSize(width: Properties.flashbuttonSize, height: Properties.flashbuttonSize*2))
        flash.addTarget(self, action: #selector(OverlayView.flashPressed), for: .touchUpInside)
    }
    
    func configureRedCircle(_ yValue: CGFloat){
        circleView.removeFromSuperview()
        if !ongoingIntroduction{
            circleView.frame = CGRect(origin: CGPoint(x: (blackbar.frame.origin.x +
                                Properties.blackBarWidthF/2)-Properties.circleSizeF/2,
                                y: yValue), size:
                                CGSize(width: Properties.circleSizeF,
                                height: Properties.circleSizeF))
        }
        circleView.alpha = 0.0
        let circleImage = UIImageView(frame: circleView.bounds)
        circleImage.image = UIImage(named: "Circle")
        circleImage.contentMode = .scaleToFill
        circleView.addSubview(circleImage)
        self.bringSubviewToFront(circleView)
        self.addSubview(circleView)
    }
    
    func configureFocusView(_ centerPoint: CGPoint){
        focusView = UIView(frame: CGRect(origin: CGPoint(x:centerPoint.x-(Properties.focusBeginSizeF/2),
            y: centerPoint.y - Properties.focusBeginSizeF/2),
            size: CGSize(width: Properties.focusBeginSizeF,
            height: Properties.focusBeginSizeF)))
        let focusImageView = UIImageView(frame: focusView.bounds)
        focusImageView.image = UIImage(named: "Focus")
        focusImageView.contentMode = .scaleToFill
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
        checkView.image = UIImage(named: "Check")
        checkView.contentMode = .scaleToFill
        saveView.addSubview(checkView)
        saveView.sendSubviewToBack(checkView)
        saveView.alpha = 0.6
        self.addSubview(saveView)
        
        
        //Animate
        saveView.transform = CGAffineTransform(scaleX: 0,y: 0)
        UIView.animate(withDuration: 0.75,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 15,
            options: .curveLinear,
            animations: {
                self.saveView.transform = CGAffineTransform.identity
            },
            completion: { (didComplete: Bool) in
                if(didComplete && !self.ongoingIntroduction){
                    UIView.animate(withDuration: 1.0, animations: {self.saveView.alpha = 0.0} )
                }
            }
        )

    }
    
    func clearViewFromIntroduction(){
        flash.removeFromSuperview()
        phoneView.removeFromSuperview()
        upArrowView.removeFromSuperview()
        orientationLabel.removeFromSuperview()
        okayButton.removeFromSuperview()
        self.backgroundColor = UIColor.clear
    }
    
    
    //MARK: First Launch
    func firstLaunch(){
        backgroundColor = UIColor.white
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
        orientationLabel.textAlignment = .center
        orientationLabel.lineBreakMode = .byWordWrapping
        orientationLabel.textColor = Properties.iconColor
        self.bringSubviewToFront(orientationLabel)
        self.addSubview(orientationLabel)
        
        //Configure Okay Button
        let okayString = NSAttributedString(string: "Okay", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        okayButton.setAttributedTitle(okayString, for: UIControl.State())
        okayButton.backgroundColor = Properties.iconColor
        let buttonWidth: CGFloat = Properties.okayButtonRatio*frame.size.width
        let bOrigin = CGPoint(x: frame.size.width/2-buttonWidth/2, y: (frame.height*7)/8)
        okayButton.titleLabel!.font = UIFont(name: Properties.font, size: 24)
        okayButton.tintColor = UIColor.white
        okayButton.setTitleColor(UIColor.white, for:  UIControl.State())
        okayButton.frame = CGRect(origin: bOrigin,
            size: CGSize(width:
                buttonWidth,
                height: Properties.okayButtonHeight))
        okayButton.addTarget(self, action: #selector(OverlayView.nextScreen), for: .touchUpInside)
        self.addSubview(okayButton)
        whichWelcomeScreen += 1
    }
    
    @objc func nextScreen(){
        switch(whichWelcomeScreen){

        //Add arrow for flash introduction
        case 1: firstScreen()
        
        //Rotate to film screen
        case 2: secondScreen()
           
        //Rotate to stop screen
        case 3: thirdScreen()
            
        //Check mark screen
        case 4:fourthScreen()
            
        //Happy filming screen
        case 5: fifthScreen()
        
        //Clear screen
        case 6: sixthScreen()
    
        default: break
        }
    }

    
    
    //MARK: Orientation Screens
    func firstScreen(){
        whichWelcomeScreen += 1
        orientationLabel.frame = CGRect(origin: CGPoint(x: orientationLabel.frame.origin.x,
            y:orientationLabel.frame.origin.y-30),
            size: CGSize(width: orientationLabel.frame.size.width,
                height: 100))
        orientationLabel.font = UIFont(name: Properties.font, size: Properties.orientationFontSize-3)

        let sideLength = frame.width*Properties.upArrowViewRatio
        upArrowView.frame = CGRect(origin:
            CGPoint(x:frame.width,
                y:frame.height/2 - sideLength/2),
            size: CGSize(width: sideLength,
                height: sideLength))
        let arrowImageView = UIImageView(frame: upArrowView.bounds)
        arrowImageView.image = UIImage(named: "Arrow")
        arrowImageView.contentMode = .scaleToFill
        arrowImageView.alpha = 1.0
        upArrowView.addSubview(arrowImageView)
        orientationLabel.text = "Toggle flash here"
        orientationLabel.frame.origin = CGPoint(x:orientationLabel.frame.origin.x,
            y: orientationLabel.frame.origin.y+50)
        orientationLabel.textAlignment = .center
        orientationLabel.alpha = 0.0
        configureFlashButton()
        addSubview(upArrowView)
        addSubview(flash)
        UIView.animate(withDuration: 0.75, animations: {self.orientationLabel.alpha = 0.75})
        UIView.animate(withDuration: 0.3,
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
        upArrowView.alpha = orientationLabel.alpha
    }
    
    func secondScreen(){
        whichWelcomeScreen += 1
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
        pictureView.image = UIImage(named: "Phone")
        pictureView.contentMode = .scaleToFill
        phoneView.addSubview(pictureView)
        phoneView.sendSubviewToBack(pictureView)
        self.addSubview(phoneView)
        
        //Animate
        UIView.animate(withDuration: 0.75, animations: {self.orientationLabel.alpha = 0.75})
        UIView.animate(withDuration: 1.5, delay: 0.75, options: [], animations: {
            self.orientationLabel.alpha = 0.75
            self.phoneView.transform = CGAffineTransform(rotationAngle: CGFloat(-(Double.pi/2)))
            }, completion: { (didComplete) in
                if didComplete{
                    self.configureRedCircle(self.frame.height/2)
                    self.addSubview(self.circleView)
                    UIView.animate(withDuration: 0.5,
                        delay: 0.0,
                        options: [UIView.AnimationOptions.repeat, UIView.AnimationOptions.autoreverse],
                        animations: {self.circleView.alpha = 1.0},
                        completion: nil)
                }
            }
        )
        phoneView.alpha = orientationLabel.alpha
    }
    
    func thirdScreen(){
        whichWelcomeScreen += 1
        circleView.removeFromSuperview()
        orientationLabel.text = "Rotate back to finish"
        UIView.animate(withDuration: 1.0,
            delay: 0.3,
            options: [],
            animations: { self.phoneView.transform = CGAffineTransform(rotationAngle: CGFloat(0))},
            completion: nil)
    }
    
    func fourthScreen(){
        whichWelcomeScreen += 1
        phoneView.removeFromSuperview()
        orientationLabel.frame.origin = CGPoint(x: orientationLabel.frame.origin.x,
            y: orientationLabel.frame.origin.y + 30)
        orientationLabel.alpha = 0.0
        orientationLabel.text = "You'll see the check when your video saves."
        UIView.animate(withDuration: 0.5,
            animations: {self.orientationLabel.alpha = 0.75},
            completion: {(didComplete) in
                if(didComplete){
                    self.configureAndAnimateSaveView()
                }
            }
        )
    }
    
    func fifthScreen(){
        flash.removeFromSuperview()
        saveView.removeFromSuperview()
        whichWelcomeScreen += 1
        self.orientationLabel.font = UIFont(name: Properties.font, size: 38)
        self.orientationLabel.frame.origin = CGPoint(x:self.orientationLabel.frame.origin.x,
            y:self.frame.height/2-self.orientationLabel.frame.size.height/2-40)
        self.orientationLabel.alpha = 0.0
        orientationLabel.text = "That's it!\n Happy Filming"
        UIView.animate(withDuration: 0.5, animations: { self.orientationLabel.alpha = 0.75})
    }
    
    func sixthScreen(){
        backgroundColor = UIColor.clear
        circleView.removeFromSuperview()
        saveView.removeFromSuperview()
        okayButton.removeFromSuperview()
        orientationLabel.removeFromSuperview()
        self.addSubview(flash)
        ongoingIntroduction = false
    }
}
