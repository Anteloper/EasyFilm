//
//  FilmController.swift
//  EasyFilm
//
//  Created by Oliver Hill on 1/13/16.
//  Copyright © 2016 Oliver Hill. All rights reserved.


import UIKit
import MobileCoreServices
import CoreMotion
import AVFoundation

class FilmController: UIViewController,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate { 
    
    //MARK: Global variables
    fileprivate let cameraController: UIImagePickerController! = UIImagePickerController()
    fileprivate var isFirstLaunch = false
    fileprivate let motionManager = CMMotionManager()
    fileprivate var overlayController = OverlayViewController()
    
    
    //MARK: Lifecycle
    override func viewDidLoad(){
        let isNotFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if !isNotFirstLaunch{
            isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
        }
        configureAccelerometer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !startCameraFromViewController(self, withDelegate: self){
            createAlert("Camera not found",
                message: "A connection to the camera could not be made",
                button: "OK")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        overlayController.userFocused(touches: touches, event: event)
    }
    
    //MARK: ImagePicker Setup and Presentation
    func startCameraFromViewController(_ viewController: UIViewController,
        withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {

        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        
        //Camera configuration
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as String]
        cameraController.showsCameraControls = false
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        cameraController.videoQuality = UIImagePickerControllerQualityType.typeHigh
        

        //Custom view configuration
        overlayController = OverlayViewController(nibName: "OverlayViewController", bundle: nil)
        let overlayView: OverlayView = overlayController.view as! OverlayView
        overlayView.frame = cameraController.view.frame
        
        //Add the overlay after the camera is displayed
        present(cameraController, animated: false, completion: {
            self.cameraController.cameraOverlayView = overlayView
            //todo
            overlayView.setup(isFirstLaunch: self.isFirstLaunch)
        })
            
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any]) {
            
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString

        if mediaType == kUTTypeMovie {
            let path = (info[UIImagePickerControllerMediaURL] as! URL).path
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                UISaveVideoAtPathToSavedPhotosAlbum(path,
                    self, #selector(FilmController.video(_:didFinishSavingWithError:contextInfo:)),nil)
            }
        }
    }
    
    func video(_ videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        overlayController.overlayView.configureAndAnimateSaveView()
    }
    
    //Shortcut for alerts
    func createAlert(_ title: String, message: String, button: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Rotation Management Setup
    func configureAccelerometer(){
        if motionManager.isAccelerometerAvailable{
            motionManager.accelerometerUpdateInterval = 1.0
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{
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
        let overlay = overlayController.overlayView
        if(!overlay.ongoingIntroduction){
            if overlay.isFilming{
                cameraController.stopVideoCapture()
                cameraController.cameraFlashMode = .off
                overlay.didChangeToPortrait()
            }
        }
    }
    


    func landscape(positiveRotation isPos: Bool){
        let overlay = overlayController.overlayView
        if(!overlay.ongoingIntroduction && !overlay.isFilming){
            overlay.didBeginFilmingWithPositiveRotation(isPos)
            if overlay.flashOn{
                cameraController.showsCameraControls = true
                cameraController.cameraFlashMode = .on
                cameraController.showsCameraControls = false
            }
            else{
                cameraController.cameraFlashMode = .off
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.cameraController.startVideoCapture()
            })
        }
    }
}

