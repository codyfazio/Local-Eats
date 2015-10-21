//
//  EditJournalEntryViewController.swift
//  CapstoneProject
//
//  Created by Cody Clingan on 10/5/15.
//  Copyright © 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

//Used mainly to add an activity indicator to EditJournalEntryTableViewController (due to its static cells) 
class EditJournalEntryViewController : UIViewController, ActivityIndicatorDelegate {
    
    //Create necessary connections to storyboard
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.toolbar.hidden = true
    }
    
    //Dismiss controller if cancel button is touched
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //ActivityIndicatorDelgate Method
    func start() {
        if self.activityIndicator.isAnimating() == false {
            self.activityIndicator.startAnimating()
        }
    }
    
    //ActivityIndicatorDelgate Method
    func stop() {
        if self.activityIndicator.isAnimating() == true {
            self.activityIndicator.stopAnimating()
        }
    }
    
    //Set this controller as actitity delegate for notifications
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "pushJournalEntryTableViewController") {
            let controller = segue.destinationViewController as! EditJournalEntryTableViewController
            controller.activityDelegate = self
        }
    }
    
    //Global shared instance
    class func sharedInstance() -> EditJournalEntryViewController {
        struct Singleton {
            static let sharedInstance = EditJournalEntryViewController()
        }
        return Singleton.sharedInstance
    }
}
