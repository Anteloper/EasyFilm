//
//  FilmController.swift
//  EasyFilm
//
//  Created by Oliver Hill on 1/13/16.
//  Copyright © 2016 Oliver Hill. All rights reserved.


import UIKit
import MobileCoreServices
import CoreMotion

class FilmController: UIViewController,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate { 
    
    //MARK: Global variables
    let cameraController: UIImagePickerController! = UIImagePickerController()
    var isFirstLaunch = false
    let motionManager = CMMotionManager()
    
    //MARK: Lifecycle
    override func viewDidLoad(){
        let isNotFirstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("isFirstLaunch")
        if !isNotFirstLaunch {
            isFirstLaunch = true
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isFirstLaunch")
            configureAccelerometer(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if !startCameraFromViewController(self, withDelegate: self){
            createAlert("Camera not found",
                message: "A connection to the camera could not be made",
                button: "OK")
        }
    }
    
    //MARK: ImagePicker Setup and Presentation
    func startCameraFromViewController(viewController: UIViewController,
        withDelegate delegate: protocol<UIImagePickerControllerDelegate,
        UINavigationControllerDelegate>) -> Bool {

        if UIImagePickerController.isSourceTypeAvailable(.Camera) == false {
            return false
        }
        
        //Camera configuration
        cameraController.sourceType = .Camera
        cameraController.mediaTypes = [kUTTypeMovie as String]
        cameraController.showsCameraControls = false
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        cameraController.videoQuality = UIImagePickerControllerQualityType.TypeHigh

        //Custom view configuration
        let overlayController = OverlayViewController(nibName: "OverlayViewController", bundle: nil)
        let overlayView: OverlayView = overlayController.view as! OverlayView
        overlayView.frame = cameraController.view.frame
        
        //Add the overlay after the camera is displayed
        presentViewController(cameraController, animated: false, completion: {
            self.cameraController.cameraOverlayView = overlayView
            overlayView.setup(isFirstLaunch: self.isFirstLaunch)
        })
            
        return true
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString

        if mediaType == kUTTypeMovie {
            let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path!) {
                UISaveVideoAtPathToSavedPhotosAlbum(path!,
                    self, "video:didFinishSavingWithError:contextInfo:",nil)
            }
        }
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        if let overlay: OverlayView = cameraController.cameraOverlayView as? OverlayView{
            overlay.configureAndAnimateSaveView()
        }
    }
    
    //Shortcut for alerts
    func createAlert(title: String, message: String, button: String){
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: button,
            style: UIAlertActionStyle.Default,
            handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    //MARK: Rotation Management Setup
    func configureAccelerometer(shouldBegin: Bool){
        if motionManager.accelerometerAvailable{
            motionManager.accelerometerUpdateInterval = 1.0
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler:{
                (accelDataMaybe, error) in
                if let accelData: CMAccelerometerData = accelDataMaybe{
                    let xrotation = accelData.acceleration.x
                    if(abs(xrotation) <= 0.6){
                        self.portrait()
                    }
                    else if(xrotation < -0.6){
                        self.landscape(positiveRotation: true)
                    }
                    else if(xrotation > 0.6){
                        self.landscape(positiveRotation: false)
                    }
                }
            })
        }
        else{
            createAlert("Accelerometer not found",
                message: "This app won't function correctly without the use of the acceleromter",
                button: "OK")
        }
    }

    
    //MARK: Rotation Handling
    func portrait(){
        if let overlay: OverlayView = cameraController.cameraOverlayView as? OverlayView{
            if(!overlay.ongoingIntroduction){
                if overlay.isFilming{
                    cameraController.stopVideoCapture()
                    cameraController.cameraFlashMode = .Off
                    overlay.didChangeToPortrait()
                }
            }
        }
    }

    func landscape(positiveRotation isPos: Bool){
        if let overlay: OverlayView = cameraController.cameraOverlayView as? OverlayView{
            if(!overlay.ongoingIntroduction && !overlay.isFilming){
                overlay.didBeginFilmingWithPositiveRotation(isPos)
                if overlay.flashOn{
                    cameraController.cameraFlashMode = .On
                }
                else{
                    cameraController.cameraFlashMode = .Off
                }
                cameraController.startVideoCapture()
            }
        }
    }    
}

