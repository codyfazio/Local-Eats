//
//  FoodTypeViewController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/25/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

// This controller serves as the parent for the several containers that make up the view
import Foundation
import UIKit


class FoodTypeViewController : UIViewController, ActivityIndicatorDelegate {
    
    //Create variable to house the object that is passed in and used to get data for our container views
    var currentFoodItem : Food?
    var currentFoodItems : [Food]?
    var activityIndicatorDelegate : ActivityIndicatorDelegate?

    //Create connections to Storyboard
    @IBOutlet weak var yelpActivityIndicator: UIActivityIndicatorView!
    
    //Pass in the object
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if (segue.identifier == "pushFoodTypeInfoCard") {
            let foodTypeInfoCardViewController = segue.destinationViewController as! InfoCard
            foodTypeInfoCardViewController.currentFoodItem  = self.currentFoodItem
          
        } else if (segue.identifier == "pushYelpResultsFromFoodType") {
            let yelpResultsViewController = segue.destinationViewController as! YelpResultsController
                yelpResultsViewController.currentFoodItem = currentFoodItem
                yelpResultsViewController.currentFoodItems = currentFoodItems
                yelpResultsViewController.activityIndicatorDelegate = self
            
        } else if (segue.identifier == "pushFoodTypeToPageView") {
            let foodTypeDetailViewController = segue.destinationViewController as! FoodTypePageViewController
            foodTypeDetailViewController.currentFoodItem = currentFoodItem
        }
    }
    
    
    //ActivityIndicatorDelgate Method
    func start() {
        if self.yelpActivityIndicator.isAnimating() == false {
            self.yelpActivityIndicator.startAnimating()
        }
    }
    
    //ActivityIndicatorDelgate Method
    func stop() {
        if self.yelpActivityIndicator.isAnimating() == true {
            self.yelpActivityIndicator.stopAnimating()
        }
    }

}
