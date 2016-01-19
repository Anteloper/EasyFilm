//
//  OverlayView.swift
//  EasyFilm
//
//  Created by Oliver Hill on 1/18/16.
//  Copyright © 2016 Oliver Hill. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    var isHorizontal = false{
        didSet{
            if isHorizontal{
                textLabel.text = "Filming..."
                textLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                let origin = CGPoint(x: self.frame.size.width/2 + textLabel.frame.size.width/2, y: 0)
                let size = CGSize(width: textLabel.frame.height, height: textLabel.frame.width)
                textLabel.frame = CGRect(origin: origin, size: size)
            }
            else{
                textLabel.text = "Rotate to Film"
            }
        }
    }

}
