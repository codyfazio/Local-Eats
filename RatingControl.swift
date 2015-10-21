//
//  RatingControl.swift
//  
//
//  Created by Cody Clingan on 8/27/15.
//
//

import UIKit

class RatingControl: UIView {

   // Initialization
    required init?(coder aDecoder: NSCoder){
        super.init?(coder: aDecoder)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44)
        button.backgoundColor = UIColor.redColor()
        addSubview(button)
    }
}
