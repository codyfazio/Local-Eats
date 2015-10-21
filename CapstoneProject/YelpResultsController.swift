//
//  YelpResultsController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 9/1/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

//Used in several containers to display eatery results from Yelp
class YelpResultsController : UICollectionViewController {
    
    //Create variables
    var yelpItems : [Eatery] = []
    var currentFoodItem : Food?
    var currentFoodItems : [Food]?
    var currentJournalEntry : JournalEntry?
    var currentEatery : Eatery?
    var activityIndicatorDelegate : ActivityIndicatorDelegate?
    
   //Lifecycle
    override func viewDidLoad() {
       super.viewDidLoad()
        
        //Set up collection view
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.clearColor()
        activityIndicatorDelegate?.start()
       
        
        //Get initial yelp results or load with saved yelp result from journal entry
        if currentFoodItems != nil {
            self.updateYelpResults() {success, error in
                if success {
                    self.collectionView?.reloadData()
                    
                }  else {
                   CapstoneProjectConvenience.sharedInstance().displayAlert("Yelp Results", message: "We're having trouble finding eateries at the moment.", controller: self, activityIndicator: nil)
                }
            }
        } else if currentJournalEntry != nil {
            self.yelpItems.append((currentJournalEntry?.eatery)!)
                self.collectionView?.reloadData()
        }
    }
    
    //Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.collectionView?.reloadData()
        activityIndicatorDelegate?.start()
    }

    //UICollectionView DataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.yelpItems.count
    }
    
    //UICollectionView DataSource
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //Get the current cell and configure it
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("yelpCollectionCell", forIndexPath: indexPath) as! YelpCollectionCell
        
        activityIndicatorDelegate?.stop()
        cell.activityIndicator.startAnimating()
        configureCollectionCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    //Helper function
    func configureCollectionCell(cell: YelpCollectionCell, atIndexPath indexPath: NSIndexPath) {
        
        //Get the object for the current cell
        let object = self.yelpItems[indexPath.row]
        let photo = object.photo
        
        //Pass the object out as the currentEatery in case we need it for viewing in Yelp and set up the moreInfoButton
        currentEatery  = object
        [cell.moreInfoButton .addTarget(self, action: "openInYelp", forControlEvents: UIControlEvents.TouchUpInside)]
        cell.backgroundColor = UIColor.clearColor()
        cell.restaurantNameLabel.text =  object.name
        cell.yelpRatingView.image = getRatingImage(Double(object.rating!))

        
        //Check for eatery photo, and set cell properties
        if photo?.photoImage != nil {
            cell.backgroundImageView.image = photo!.photoImage
            cell.activityIndicator.stopAnimating()
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            FoursquareClient.sharedInstance().downloadPhotoImageForEatery(photo!){success, data, errorString in
                    
                    if success {
                        let image = UIImage(data: data!)
                        photo!.photoImage = image
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        }
                    } else {
                        print(errorString)
                    }
                }
            }
        }
    }
    

    
    //Get Eateries from Yelp
    func updateYelpResults(completionHandler: (success: Bool, error: String?) -> Void) {
        
        YelpClient.sharedInstance().getEateriesForCollectionView(currentFoodItems!) {success, error, eateries in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.yelpItems = eateries!
                    completionHandler(success: true, error: nil)
                }
            } else {
                //TODO: Better error handling here.
                completionHandler(success: false, error: error)
            }
        }
    }
    
    //Displays the eatery's info page
    func openInYelp() {
        
        if let appURL = NSURL(string: "yelp:") {
            
            let canOpenApp = UIApplication.sharedApplication().canOpenURL(appURL)
            if canOpenApp {
                UIApplication.sharedApplication().openURL(NSURL(string: "yelp:///biz/\(self.currentEatery!.id)")!)
            } else {
                UIApplication.sharedApplication().openURL(NSURL(string: "http://yelp.com/biz/\(self.currentEatery!.id)")!)
            }
        }
    }
    
    //Helper function
    func getRatingImage(rating: Double) -> UIImage? {
        
        var image : UIImage?
        CapstoneProjectConvenience.sharedInstance().getImageForYelpRating(rating) {ratingImage, error in
            
            if let _ = error {
               image = nil
            } else {
                image = ratingImage
            }
        }
        return image
    }
 }