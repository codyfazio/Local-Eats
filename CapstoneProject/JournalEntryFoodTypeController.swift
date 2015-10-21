//
//  JournalEntryFoodTypeController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 9/4/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit
import MapKit

//Create protocol for passing the food type back to EditJournalEntryViewController
protocol JournalEntryFoodTypeDelegate {
    func passFoodType(foodType : Food) -> Void
}


//Used to select a food type for adding to the Journal Entry
class JournalEntryFoodTypeController : UITableViewController,  UISearchResultsUpdating {
    
    //Create connections to storyboad
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    
    //Create variables
    var delegate : JournalEntryFoodTypeDelegate?
    var items = [Food]()
    var filteredItems = [Food]()
    var currentFoodItem : Food?
    var searchResultsController = UISearchController()
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get all food objects from iCloud
        CloudKitClient.sharedInstance().fetchAllFood() {success, foodArray, error in
            
            //Create an array from fetched results and load the table
            if success {
                self.items = foodArray as! [Food]
                //Load the fetched data into the table
                self.tableView.reloadData()
            } else {
                
                if NetworkingConvenience.sharedInstance().isConnectedToNetwork() {
                    CapstoneProjectConvenience.sharedInstance().displayAlert("iCloud Unavailable", message: "We're having trouble connecting to iCloud. To enjoy all the features of Local Eats, you'll need to sign in.", controller: self, activityIndicator: nil)
                    
                } else {
                    CapstoneProjectConvenience.sharedInstance().displayAlert("No Internet Connection", message: "You appear to be offline. To enjoy all the features of Local Eats, you'll need an internet connection.", controller: self, activityIndicator: nil)
                }
            }
        }

        //UISearchController
        self.searchResultsController = ({

            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.definesPresentationContext = true

            self.tableView.tableHeaderView = controller.searchBar
            return controller
        }) ()
    }

    //UITableView DataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        //Load appropriate data into table
        if (self.searchResultsController.active) {
            return self.filteredItems.count
        } else {
            return self.items.count
        }
    }
    
    //UITableView DataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        //Get indiviual objects and set up cell
        let cell = tableView.dequeueReusableCellWithIdentifier("journalEntryFoodTypeCell", forIndexPath: indexPath) as! JournalEntryFoodTypeCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    //UITableView Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        //Set currentFoodItem
        if (self.searchResultsController.active) {
            currentFoodItem = self.filteredItems[indexPath.row]
        } else {
            currentFoodItem = self.items[indexPath.row]
        }
        
        //Pass currentFoodItem
        delegate?.passFoodType(currentFoodItem!)
        //Return to EditJournalEntryTableViewController
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //Helper function
    func configureCell(cell: JournalEntryFoodTypeCell, atIndexPath indexPath: NSIndexPath) {
    
        var object : Food
        if (self.searchResultsController.active) {
            object = self.filteredItems[indexPath.row]
        } else {
            object = self.items[indexPath.row]
        }
        
        cell.journalEntryFoodTypeCellNameLabel.text = object.name
        cell.journalEntryFoodTypeCellRegionLabel.text = object.region
    }
    
    //UISearchController Protocol
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    
        //First we make sure our array is empty
        filteredItems.removeAll(keepCapacity: false)
    
        //Then we set up our search
        let searchPrediate = NSPredicate(format: "self.name beginswith[c] %@ OR self.region beginswith[c] %@", searchController.searchBar.text!, searchController.searchBar.text!)
        
        //Then we create an array from the results of the search
        let array = (items as NSArray).filteredArrayUsingPredicate(searchPrediate)

        //We set our array to the results of the newly created array
        filteredItems = array as! [Food]
    
        //Then we reload the table to view the updated array
        self.tableView.reloadData()
    }
    
    //Pass info to next controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        searchResultsController.active = false
        if (segue.identifier == "editJournalEntryViewController") {
            let nextViewController = (segue.destinationViewController as! FoodTypeViewController)
            nextViewController.currentFoodItem = currentFoodItem
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