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

//The top level view controller. Never directly visible but instantiates and serves as the delegate
//For the UIImagePickerController (the camera) and the OverlayViewController(custom controls and tutorial)
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
        super.viewDidLoad()
        let isNotFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if !isNotFirstLaunch{
            isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
        }
        configureAccelerometer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        cameraController.videoQuality = UIImagePickerController.QualityType.typeHigh
        

        //Custom view configuration
        overlayController = OverlayViewController(nibName: "OverlayViewController", bundle: nil)
        let overlayView: OverlayView = overlayController.view as! OverlayView
        overlayView.frame = view.frame
        
        //Add the overlay after the camera is displayed
        present(cameraController, animated: false, completion: {
            self.cameraController.cameraOverlayView = overlayView
            overlayView.setup(isFirstLaunch: self.isFirstLaunch)
        })
            
        return true
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard info[UIImagePickerController.InfoKey.mediaType] != nil else { return }
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        
        if mediaType == kUTTypeMovie{
            let path = (info[UIImagePickerController.InfoKey.mediaURL] as! URL).path
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(FilmController.video(_:didFinishSavingWithError:contextInfo:)),nil)
            }
        }
    }
    
    @objc func video(_ videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        overlayController.overlayView.configureAndAnimateSaveView()
    }
    
    //Shortcut for alerts
    func createAlert(_ title: String, message: String, button: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: button, style: UIAlertAction.Style.default, handler: nil))
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
                    let yrotation = accelData.acceleration.y
                    
                    if abs(xrotation) <= 0.6 && abs(yrotation) >= 0.6{
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
                //No idea why but flash does not work without toggling the showControls on and off
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

