//
//  JournalViewController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/25/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

// Used to create and update the tableView for viewing the user's journal entries

import Foundation
import UIKit
import CoreData

class JournalViewController : UITableViewController, UISearchResultsUpdating {
    
    
    //Create connections to storyboard
    @IBOutlet weak var addJournalEntryButton: UIBarButtonItem!
 
    //Create variables
    var currentEntry = JournalEntry?()
//    var entries = [JournalEntry]?()
    var filteredEntries = [JournalEntry]()
    var searchResultsController : UISearchController!
    
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!

    //Lifecycle
    override func viewDidLoad() {
        
        // Set ourselves as the delegate for the fetchResultsController and get our initial data from CoreData
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            let fetchError = error as NSError
            NSLog("Unresolved error \(fetchError), \(fetchError.userInfo)")

        }
        
        //Set up UISearchController
    
        self.searchResultsController = ({
            
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.definesPresentationContext = true
            
            self.tableView.tableHeaderView = controller.searchBar
            return controller
            
        }) ()

        //Load table data
        self.tableView.reloadData()
    
    }
    
    //Lifecycle
    override func viewWillAppear(animated: Bool) {
        
        //Load table data
        self.tableView.reloadData()
    }
    
    //Lifecycle
    override func viewWillDisappear(animated: Bool) {
        
        //Dismiss search controller
        self.searchResultsController.dismissViewControllerAnimated(false, completion: nil)
    }
    
    //UITableView DataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Get section info from active controller
        if (self.searchResultsController != nil && self.searchResultsController.active) {
            return self.filteredEntries.count
        } else {
            let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
    }
    
    //UITableView DataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Get individual entry objects and populate cells
        var entry : JournalEntry
        
        if self.searchResultsController.active {
            entry = self.filteredEntries[indexPath.row] as JournalEntry
            
        } else {
            entry = self.fetchedResultsController.objectAtIndexPath(indexPath) as! JournalEntry
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("journalEntryCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = entry.name
        
        //Format journal entry date for display
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        cell.detailTextLabel?.text = formatter.stringFromDate(entry.date)
    
        return cell
    }
    
    //UITableView Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Perfrom segue for appropriate entry
        if (self.searchResultsController.active) {
            self.currentEntry = self.filteredEntries[indexPath.row]
            self.performSegueWithIdentifier("pushJournalEntryViewController", sender: self)

        } else {
            self.currentEntry = self.fetchedResultsController.objectAtIndexPath(indexPath) as? JournalEntry
            self.performSegueWithIdentifier("pushJournalEntryViewController", sender: self)
        }
    }
    
    //UITableView Delegate
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //Allow user to delete a journal entry via swipe gesture and save the change
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            sharedContext.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    
       

    //UISearchController DataSource
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        //Empty the filteredEntries array each time a change is made in the search field
        filteredEntries.removeAll(keepCapacity: false)
        
        //Create the predicate to search on. Currently, we just search for objects beginning with characters the user types
        let searchPredicate = NSPredicate(format: "self.name beginswith[c] %@", searchController.searchBar.text!, searchController.searchBar.text!)
        //Create an array using the filter results
        let entries = (self.fetchedResultsController.fetchedObjects! as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredEntries = entries as! [JournalEntry]
        
        //Load the tableView with results from our search
        self.tableView.reloadData()
    }
    
    // Create a reference to the shared context
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    // Create an instance of fetchedResultsController to get data from our Photo entity
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        //Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: "JournalEntry")
        
        //Add a sort descriptor
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Fetch all journal entries
        let predicate = NSPredicate(value: true)
        fetchRequest.predicate = predicate
        
        //Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        //Return the fetched results controller
        return fetchedResultsController
        
        }()
    

    //Segue to EditJournalEntryViewController
    @IBAction func addJournalEntryButtonTapped(sender: UIBarButtonItem) {
        
        if NetworkingConvenience.sharedInstance().isConnectedToNetwork(){
            let controller = storyboard?.instantiateViewControllerWithIdentifier("editJournalEntryNavigationController") as! UINavigationController
            presentViewController(controller, animated: true, completion: nil)
       
        } else {
            CapstoneProjectConvenience.sharedInstance().displayAlert("No Internet Connection", message: "You appear to be offline. You can still view all previous entries. However, to add a new journal entry, you'll need an internet connection. ", controller: self, activityIndicator: nil)
            }
    }
    
    //Pass necessary info to the next controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "pushJournalEntryViewController") {
            let journalEntryViewController = segue.destinationViewController as! JournalEntryViewController
            journalEntryViewController.currentJournalEntry = self.currentEntry
            journalEntryViewController.currentFoodItem = self.currentEntry?.food
        }
    }
}

//Extension for fetching info from the context
extension JournalViewController : NSFetchedResultsControllerDelegate {
    
    // Prepare to make all changes necessary to view
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        self.tableView.beginUpdates()
    }

    //Sort changes into arrays so we can efficiently perform the changes all at once
    func controller(controller: NSFetchedResultsController, didChangeObject photoObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        
        switch(type) {
        case NSFetchedResultsChangeType.Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case NSFetchedResultsChangeType.Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case NSFetchedResultsChangeType.Update:
            break
        default:
            break
            
        }
    }
    
    //Perfom the changes we sorted into arrays 
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView.insertRowsAtIndexPaths(insertedIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.deleteRowsAtIndexPaths(deletedIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        //self.tableView.reloadRowsAtIndexPaths(<#indexPaths: [AnyObject]#>, withRowAnimation: <#UITableViewRowAnimation#>)
        self.tableView.endUpdates()
    }
}


