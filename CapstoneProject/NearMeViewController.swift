//
//  NearMeViewController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/25/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit 
import MapKit
import CoreLocation


//Initial View Controller
//Used to show local foods nearest to the user
class NearMeViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, ActivityIndicatorDelegate {
    
    //Create necessary connections to storyboard
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yelpResultsActivityIndicator: UIActivityIndicatorView!

    //Create variables
    var currentFoodItem : Food?
    var currentEatery : Eatery?
    var items = [Food]()
    var yelpItems = [Eatery]()
    let locationManager = CLLocationManager()
    var currentLocationCoordinate : CLLocationCoordinate2D?
    var photos = [PhotoRecord]()
    let pendingOperations = PendingOperations()
    
    //Lifecycle
    override func viewDidLoad() {
        
        //Start activity indicator
        self.tableViewActivityIndicator.startAnimating()
        
        //Set this controller as its own delegare and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        //Set up location manager to the user's location.
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //Disable refresh button until we get our current location
        refreshButton.enabled = false
    }
    
    //Lifecycle
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        self.tableViewActivityIndicator.startAnimating()
    }
    
    //UITableView DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    //UITableView DataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Get object for cell and configure it
        let cell = tableView.dequeueReusableCellWithIdentifier("nearMeFoodCell", forIndexPath: indexPath) as! NearMeFoodCell
        cell.activityIndicator.startAnimating()
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    //UITableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Get the currentFoodItem and segue to view it
        currentFoodItem = self.items[indexPath.row]
        self.performSegueWithIdentifier("pushFoodTypeFromNearMe", sender: self)
    }
    
    //Helper function
    func configureCell(cell: NearMeFoodCell, atIndexPath indexPath: NSIndexPath) {
        
        //Get the current food
        let object = self.items[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()

        
        //Get the food rating and set the rest of the cell's properties
        if object.ratingImage != nil {
            cell.nearMeRatingImageView.image = object.ratingImage
            cell.foodCellName.text = object.name
            cell.foodCellRegion.text = object.region
            cell.activityIndicator.stopAnimating()
            
        } else {
        CapstoneProjectConvenience.sharedInstance().setFoodRating(object) {image, rating in
            
            if let ratingImage = image {
                dispatch_async(dispatch_get_main_queue()) {
                object.ratingImage = image
                cell.nearMeRatingImageView.image = ratingImage
                cell.foodCellName.text = object.name
                cell.foodCellRegion.text = object.region
                cell.activityIndicator.stopAnimating()
                    
                    }
                }
            }
        }
        self.tableViewActivityIndicator.stopAnimating()
    }
    
    //Location Manager Delegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocationCoordinate == nil {
            currentLocationCoordinate = manager.location!.coordinate
            self.updateFoodResults()
        } else {
            currentLocationCoordinate = manager.location!.coordinate
        }
        refreshButton.enabled = true
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        if self.presentedViewController == nil {
        CapstoneProjectConvenience.sharedInstance().displayAlert("Location Unavailable", message: "To show you a list of local foods near you, we'll need your location. This can be shared with us in settings.", controller: self, activityIndicator: self.tableViewActivityIndicator)
        }
    }
    
    @IBAction func refreshButtonClicked(sender: AnyObject) {
        updateFoodResults()
    }
    
    //Gets the most current list of foods near us, passes info to the YelpResultsController, and refreshes the views
    func updateFoodResults() {
        
        self.tableViewActivityIndicator.startAnimating()
        self.yelpItems.removeAll(keepCapacity: false)
        getFoods() {success, error in
            if success {
                for each in self.childViewControllers {
                    if each.isKindOfClass(YelpResultsController) {
                        let controller = each as! YelpResultsController
                        controller.currentFoodItems = self.items
                        controller.updateYelpResults() {success, error in
                            if success {
                                self.tableView.reloadData()
                                controller.collectionView?.reloadData()
                                self.tableViewActivityIndicator.stopAnimating()
                            } else {
                                self.tableViewActivityIndicator.stopAnimating()
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Get foods near us
    func getFoods(completionHandler: (success: Bool, error: String?) -> Void)  {
        
        let location = locationManager.location
        if NetworkingConvenience.sharedInstance().isConnectedToNetwork() {
            CapstoneProjectConvenience.sharedInstance().getFoodsForNearMe(location!) {success, error, foods, isUser in
                if success {
                    if foods != nil {
                        self.items = foods!
                        fetchPhotoDetails()
                        
                        
                        
                        
                        
                        
                        completionHandler(success: true, error: nil)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.yelpResultsActivityIndicator.stopAnimating()
                            if self.presentedViewController == nil {
                                CapstoneProjectConvenience.sharedInstance().displayAlert("No foods found.", message: "Unfortunately, we're not finding any foods near you. We're constantly updating our database, so check back for this location soon!", controller: self, activityIndicator: self.tableViewActivityIndicator)
                                completionHandler(success: true, error: "No foods found.")
                            }
                        }
                    }
                } else {
                    if NetworkingConvenience.sharedInstance().isConnectedToNetwork() {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.yelpResultsActivityIndicator.stopAnimating()
                            if self.presentedViewController == nil {
                                CapstoneProjectConvenience.sharedInstance().displayAlert("iCloud Unavailable", message: "We're having trouble connecting to iCloud. To enjoy all the features of Local Eats, you'll need to sign in.", controller: self, activityIndicator: self.tableViewActivityIndicator)
                                completionHandler(success: false, error: "iCloud Unavailable")
                                }
                            }
                    } else {
                        if self.presentedViewController == nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.yelpResultsActivityIndicator.stopAnimating()
                                CapstoneProjectConvenience.sharedInstance().displayAlert("No Internet Connection", message: "You appear to be offline. To enjoy all the features of Local Eats, you'll need an internet connection.", controller: self, activityIndicator: self.tableViewActivityIndicator)

                                completionHandler(success: false, error: "Network Unavailable")
                            }
                        }
                    }
                }
            }
        } else {
            if self.presentedViewController == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.yelpResultsActivityIndicator.stopAnimating()
                    CapstoneProjectConvenience.sharedInstance().displayAlert("No Internet Connection", message: "You appear to be offline. To enjoy all the features of Local Eats, you'll need an internet connection.", controller: self, activityIndicator: self.tableViewActivityIndicator)
                    completionHandler(success: false, error: "Network Unavailable")
                }
            }
        }
    }
    
    //ActivityIndicatorDelgate Method
    func start() {
        if self.yelpResultsActivityIndicator.isAnimating() == false {
            self.yelpResultsActivityIndicator.startAnimating()
        }
    }
    
    //ActivityIndicatorDelgate Method
    func stop() {
        if self.yelpResultsActivityIndicator.isAnimating() == true {
            self.yelpResultsActivityIndicator.stopAnimating()
        }
    }

    //Pass currentFoodItem to the FoodTypeViewController before it is segued
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "pushFoodTypeFromNearMe") {
            let nextViewController = (segue.destinationViewController as! FoodTypeViewController)
            nextViewController.currentFoodItem = currentFoodItem
            let itemsArray: [Food] = [currentFoodItem!]
            nextViewController.currentFoodItems = itemsArray

            
        } else if (segue.identifier == "pushYelpResultsFromNearMe") {
            let nextViewController = (segue.destinationViewController as! YelpResultsController)
            nextViewController.activityIndicatorDelegate = self 
        }
    }

    //Global shared instance
    class func sharedInstance() -> NearMeViewController {
        struct Singleton {
            static var sharedInstance = NearMeViewController()
        }
        return Singleton.sharedInstance
    }

}