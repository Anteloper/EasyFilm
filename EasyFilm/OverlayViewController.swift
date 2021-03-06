//
//  OverlayViewController.swift
//  EasyFilm
//
//  Created by Oliver Hill on 1/18/16.
//  Copyright © 2016 Oliver Hill. All rights reserved.
//

import UIKit


class OverlayViewController: UIViewController {
    
    var overlayView = OverlayView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView = view as! OverlayView
    }
    
    func userFocused(touches: Set<UITouch>, event: UIEvent?){
        overlayView.animateFocus(touches, with: event)
    }
    
}
