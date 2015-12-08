//
//  LocalFoodViewController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/25/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

// This controller is used to display a table of all local food types and enable search on said table.

import Foundation
import UIKit
import MapKit



class LocalFoodViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    //Create variables
    var items = [Food]()
    var filteredItems = [Food]()
    var currentFoodItem : Food?
    var singleFoodItemArray = [Food]()
    var searchResultsController : UISearchController!
    
    
    //Create connection to storyboard
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    

    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()
        activityIndicator.startAnimating()
        
        //Get food type objects from iCloud and load/reload them into the table
        self.getFoods(){success, error in
            if success {
                //Set ourselves as the delegate and datasource
                self.tableView.delegate = self
                self.tableView.dataSource = self
                
                //Setup the UISearchController
                self.searchResultsController = ({
                    
                    let controller = UISearchController(searchResultsController: nil)
                    controller.searchResultsUpdater = self
                    controller.dimsBackgroundDuringPresentation = false
                    controller.searchBar.sizeToFit()
                    controller.definesPresentationContext = true
                    
                    self.tableView.tableHeaderView = controller.searchBar
                    
                    return controller
                }) ()

                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                
            } else {
               //TODO: Handle error
            }
        }

    }
    
    //Lifecycle
    override func viewWillAppear(animated: Bool) {
        self.activityIndicator.startAnimating()
        self.getFoods(){success, error in
            if success {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    //Used to center the activity indicator in the view
    func setupActivityIndicator() {
        activityIndicator.frame = CGRectMake(0.0, 0.0, 10.0, 10.0)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.bringSubviewToFront(self.view)

    }
    
    //RefreshButton
    @IBAction func refreshButtonClicked(sender: UIBarButtonItem) {
        
        self.getFoods(){success, error in
            if success {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }

    }
    
    //UITableView DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Check to see if we're using the searchController, and update the table with the appropriate number of rows
        if (self.searchResultsController.active) {
            return self.filteredItems.count
        } else {
            return self.items.count
        }
    }
    
    //UITableView DataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        self.activityIndicator.stopAnimating()

        //Create an instance of cell using our custom localFoodCell
        let cell = tableView.dequeueReusableCellWithIdentifier("localFoodCell", forIndexPath: indexPath) as! LocalFoodCell
        
        //Setup the cell just how we want
        cell.activityIndicator.startAnimating()
        self.configureCell(cell, atIndexPath: indexPath)
        
        
        return cell
    }
    
    //Get the currentFoodItem associated with the cell and perform a segue to view it in more detail
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.searchResultsController.active) {
            currentFoodItem = self.filteredItems[indexPath.row]
            singleFoodItemArray.append(currentFoodItem!)
            self.searchResultsController.dismissViewControllerAnimated(true, completion: nil)
        } else {
            currentFoodItem = self.items[indexPath.row]
            singleFoodItemArray.append(currentFoodItem!)
            
        }
        
        
        self.performSegueWithIdentifier("pushFoodTypeFromLocalFood", sender: self)
    }
    
    
    //Get the item used in the current row and populate the cell's view with it's data
    func configureCell(cell: LocalFoodCell, atIndexPath indexPath: NSIndexPath) -> Void {
        
        var object : Food
        cell.backgroundColor = UIColor.clearColor()
        
        if (self.searchResultsController.active) {
            object = self.filteredItems[indexPath.row]
        } else {
            object = self.items[indexPath.row]
        }
        
        cell.localFoodCellName.text = object.name
        cell.localFoodCellRegion.text = object.region

        if object.ratingImage != nil {
            cell.localFoodRatingImageView.image = object.ratingImage
            cell.activityIndicator.stopAnimating()

        } else {
            CapstoneProjectConvenience.sharedInstance().setFoodRating(object){image, rating in
                        if image != nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                object.ratingImage = image
                                cell.localFoodRatingImageView.image = image
                                cell.activityIndicator.stopAnimating()
                            }
                        } else {
                    //TODO: Error handling
                    cell.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    
    func getFoods(completionHandler: (success: Bool, error: String?) ->Void) {
        
        if NetworkingConvenience.sharedInstance().isConnectedToNetwork() {
        CapstoneProjectConvenience.sharedInstance().getFoodsForLocalFood(){success, foods, error in
            if success{
                self.items = foods!
                completionHandler(success: true, error: nil)
            } else {
                if NetworkingConvenience.sharedInstance().isConnectedToNetwork() {
                    CapstoneProjectConvenience.sharedInstance().displayAlert("iCloud Unavailable", message: "We're having trouble connecting to iCloud. To enjoy all the features of Local Eats, you'll need to sign in.", controller: self, activityIndicator: self.activityIndicator)
                    completionHandler(success: false, error: "iCloud Unavailable")
                    
                } else {
                    CapstoneProjectConvenience.sharedInstance().displayAlert("No Internet Connection", message: "You appear to be offline. To enjoy all the features of Local Eats, you'll need an internet connection.", controller: self, activityIndicator: self.activityIndicator)
                    completionHandler(success: false, error: "Network Unavailable")
                    
                }
            }
        }
        } else {
            CapstoneProjectConvenience.sharedInstance().displayAlert("No Internet Connection", message: "You appear to be offline. To enjoy all the features of Local Eats, you'll need an internet connection.", controller: self, activityIndicator: self.activityIndicator)
            completionHandler(success: false, error: "Network Unavailable")
            self.activityIndicator.stopAnimating()

        }
    }
    
      //UISearchController Protocol
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        //First we make sure our array is empty
        filteredItems.removeAll(keepCapacity: false)
        
        //Then we set up our search
        let searchPredicate = NSPredicate(format: "self.name beginswith[c] %@ OR self.region beginswith[c] %@", searchController.searchBar.text!, searchController.searchBar.text!)
        
        //Then we create an array from the results of the search
        let array = (items as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        //We set our array to the results of the newly created array
        filteredItems = array as! [Food]
        
        //Then we reload the table to view the updated array
        self.tableView.reloadData()
    }
    
    //Pass info to the next controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if (segue.identifier == "pushFoodTypeFromLocalFood") {
                let nextViewController = (segue.destinationViewController as! FoodTypeViewController)
                nextViewController.currentFoodItem = currentFoodItem
                nextViewController.currentFoodItems = singleFoodItemArray   
        }
    }
    
    //Global shared instance
    class func sharedInstance() -> LocalFoodViewController {
        struct Singleton {
            static var sharedInstance = LocalFoodViewController()
        }
        return Singleton.sharedInstance
    }
}