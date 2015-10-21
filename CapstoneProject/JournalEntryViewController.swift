//
//  JournalEntryViewController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/25/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

// This controller serves as the parent for the several containers that make up the view
import Foundation
import UIKit

class JournalEntryViewController : UIViewController {
   
    //Create variables
    var currentFoodItem : Food?
    var currentJournalEntry : JournalEntry?
    
    //Make necessary connections to storyboard
    @IBOutlet weak var reviewTextView: UITextView!
   
    //Lifecycle
    //Set the review text
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        reviewTextView.text = currentJournalEntry?.review
    }
    
    
    //Pass info to container views
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if (segue.identifier == "pushFoodTypeInfoCardFromJournalView") {
            let foodTypeInfoCardViewController = segue.destinationViewController as! InfoCard
                foodTypeInfoCardViewController.currentFoodItem  = self.currentFoodItem
                foodTypeInfoCardViewController.currentJournalEntry = self.currentJournalEntry
        
        } else if (segue.identifier == "pushYelpResultsFromJournalEntry") {
            let yelpResultsViewController = segue.destinationViewController as! YelpResultsController
            yelpResultsViewController.currentJournalEntry = currentJournalEntry
        }
    }
}