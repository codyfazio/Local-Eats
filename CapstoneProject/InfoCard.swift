
//
//  InfoCard.swift
//  CapstoneProject
//
//  Created by Cody Clingan on 8/31/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit


//Used to display food info
class InfoCard : UIViewController {
    
    //Create necessary connections to storyboard
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingTitleLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageStatusLabel: UILabel!

    //Create variables
    var currentFoodItem : Food?
    var currentJournalEntry : JournalEntry?
    
    //Lifecycle
    override func viewDidLoad() {

        //Set properties
        nameLabel.text = currentFoodItem!.name
        locationLabel.text = currentFoodItem!.region
        self.activityIndicator.startAnimating()
        getRating()
        setBackgroundImage()
    }
    
    //Helper function
    func getRating() {
        
        if currentFoodItem?.ratingImage != nil {
            ratingImageView.image = currentFoodItem?.ratingImage
        } else {
            CapstoneProjectConvenience.sharedInstance().setFoodRating(currentFoodItem!){image, rating in
                if image != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.currentFoodItem?.ratingImage = image
                        self.ratingImageView.image = image
                    }
                }
            }
        }
    }
    
    //Helper function
    func setBackgroundImage() {
        let emptyImage = UIImage()
        if currentJournalEntry != nil {
            backgroundImageView.image = currentJournalEntry!.photoImage
            self.activityIndicator.stopAnimating()
        } else {
            
            if currentFoodItem?.photoImage != nil {
                self.backgroundImageView.image = currentFoodItem?.photoImage
                self.activityIndicator.stopAnimating()
            } else {
                let id = currentFoodItem?.record.recordID
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                CloudKitClient.sharedInstance().fetchPhoto(id) {photo, isUser in
                    if isUser {
                        if let photo = photo {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.backgroundImageView.image = photo
                                self.currentFoodItem?.photoImage = photo
                                self.activityIndicator.stopAnimating()
                            }
                        } else {
                            self.imageStatusLabel.text = "No Image Found"
                            self.backgroundImageView.image = emptyImage
                            self.backgroundImageView.backgroundColor = UIColor.grayColor()
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
                }
            }
        }
    }
}