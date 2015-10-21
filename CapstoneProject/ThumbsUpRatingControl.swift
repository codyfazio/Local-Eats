//
//  ThumbsUpRatingControl.swift
//  
//
//  Created by Cody Fazio on 9/15/15.
//
//

import Foundation
import UIKit

class ThumbsUpRatingControl : UIView {
    
    
    // Set variables
    var rating = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var ratingButtons = [UIButton]()
    var spacing = 5
    var thumbs = 2
    
    let filledStarImage = UIImage(named: "filledStar")
    let emptyStarImage = UIImage(named: "emptyStar")
    
    let thumbsDownEmptyImage = UIImage(named:"thumbsDownEmpty")
    let thumbsUpEmptyImage = UIImage(named: "thumbsUpEmpty")
    let thumbsDownFilledImage = UIImage(named:"thumbsDownFilled")
    let thumbsUpFilledImage = UIImage(named: "thumbsUpFilled")
    
    // Initialization
    required init (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
       
        
        for _ in 0..<thumbs {
            
            let button = UIButton(type: UIButtonType.Custom) as UIButton
            button.backgroundColor = UIColor.clearColor()
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.adjustsImageWhenHighlighted = false
            
            let label = UILabel()
            label.center = button.center
            label.textColor = UIColor.whiteColor()
            button.addTarget(self, action: "ratingButtonTapped:", forControlEvents: .TouchDown)
            ratingButtons += [button]
            getImagesForButton(button)
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        
        
        let buttonSize = Int(frame.size.height)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Set the button's width and height to a square the size of the frame's height
        
        
        
        //Offset each button's origin by the width of the button plus spacing
        for (index,button) in ratingButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
        }
        
        updateButtonSelectionStates()
    }

    func getImagesForButton(button: UIButton) {
        
        rating = ratingButtons.indexOf(button)! + 1
        
        let buttonType = ButtonType(rawValue: rating)!
        
        switch buttonType {
            
        case .ThumbsDown:
            button.setImage(thumbsDownEmptyImage, forState: .Normal)
            button.setImage(thumbsDownFilledImage, forState: .Selected)
            button.setImage(thumbsDownFilledImage, forState: .Highlighted)
        
        case .ThumbsUp:
            button.setImage(thumbsUpEmptyImage, forState: .Normal)
            button.setImage(thumbsUpFilledImage, forState: .Selected)
            button.setImage(thumbsUpFilledImage, forState: .Highlighted)
            
        }
    }
    
    enum ButtonType : Int {
        
        case ThumbsDown = 1, ThumbsUp
    }
    
    // Button Action
    func ratingButtonTapped(button: UIButton) {
        rating = ratingButtons.indexOf(button)! + 1
        updateButtonSelectionStates()
    }

    func updateButtonSelectionStates() {
        
        for (index,button) in ratingButtons.enumerate() {
            button.selected = (index == rating.predecessor())
        }
        
    }

    
}
