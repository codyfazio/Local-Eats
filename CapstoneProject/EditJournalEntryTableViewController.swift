//
//  EditJournalEntryTableViewController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 9/3/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

//Create protocol for controlling the activity indicator in EditJournalEntryViewController
protocol ActivityIndicatorDelegate {
    func start() -> Void
    func stop() -> Void
}

//Used to add (and eventually edit) Journal Entries
class EditJournalEntryTableViewController : UITableViewController, JournalEntryFoodTypeDelegate, EaterySelectionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate    {
    
    //Create necessary connections to storyboard
    @IBOutlet weak var addJournalEntryButton: UIButton!
    @IBOutlet weak var selectFoodLabel: UILabel!
    @IBOutlet weak var selectEateryLabel: UILabel!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var ratingControl: ThumbsUpRatingControl!
   
    //Create variables
    var currentFoodItem : Food?
    var previousFoodItem : Food?
    var currentEatery : Eatery?
    var yelpResultItems : [Eatery]?
    var photo = UIImage()
    var date : NSDate?
    var activityDelegate : ActivityIndicatorDelegate?
    
    //Lifecycle
    override func viewDidLoad() {
        self.reviewTextView.delegate = self
        self.navigationController?.toolbarHidden = false
    }
    
    //Present controller for adding a photo from library or camera to the view
    @IBAction func addPhotoButtonClicked(sender: UIButton) {
        
        let alertController = UIAlertController(title: "Add a photo", message: nil, preferredStyle: .ActionSheet)
        
            let libraryAction = UIAlertAction(title: "From library", style: .Default, handler: { action in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
                })
            alertController.addAction(libraryAction)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let cameraAction = UIAlertAction(title: "From camera", style: .Default, handler: { action in
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            })
            alertController.addAction(cameraAction)
        }

        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //Dismiss image picker controller without selecting an image
    func imagePickerControllerDidCancel(picker:UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //When an image for add to the journal entry has been selected, store the image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage { imageView.image = image
            photo = image
            self.addPhotoButton.titleLabel?.text = "Change Photo"
            self.dismissViewControllerAnimated(true, completion: nil) }
    }
    
    //Animate the activity indicator and create the journal entry
    @IBAction func addToJournalButtonClicked(sender: AnyObject) {
        self.activityDelegate?.start()
        createJournalEntry()
    }
    
   //Pass info to appropriate controllers
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "pushJournalEntryFoodTypeController") {
           let controller = segue.destinationViewController as! JournalEntryFoodTypeController
            controller.delegate = self
        
        } else if (segue.identifier == "pushEaterySelectionMapViewController") {
            let controller = segue.destinationViewController as!
            EaterySelectionMapViewController
            controller.delegate = self
            controller.yelpItems = self.yelpResultItems
            controller.currentFoodItem = self.currentFoodItem
        }
    }
    
    //Make sure we have currentFoodItem before we try to get an eatery
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if let ident = identifier {
            if ident == "pushEaterySelectionMapViewController" {
                if self.currentFoodItem == nil {
                    
                    CapstoneProjectConvenience.sharedInstance().displayAlert("Choose a food.", message: "Before you can select an eatery, you must pick a food.", controller: self, activityIndicator: nil)
                    return false
                }
            }
        }
        return true
    }
    
    //Create a reference to the shared context
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    //
    
    //Helper function for creating entries
    func createJournalEntry() {

        let rating = self.ratingControl.rating
        let review = self.reviewTextView.text
        date = NSDate.init()
        CapstoneProjectConvenience.sharedInstance().createJournalEntry(currentFoodItem!, eatery: currentEatery!,
            date: self.date!, photo: self.photo, rating: rating, review: review) {success, error in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                CapstoneProjectConvenience.sharedInstance().displayAlert("Oops! Something went wrong...", message: "Unfortunately, we were unable to save your entry. Please try again.", controller: self, activityIndicator: nil)
                self.activityDelegate?.stop()
            }
        }
    }
    
    //JournalEntryFoodTypeDelegate
    func passFoodType(foodType: Food) -> Void {
        
        if self.previousFoodItem == nil {
            self.currentFoodItem = foodType
            self.previousFoodItem = self.currentFoodItem
        } else {
        self.previousFoodItem = self.currentFoodItem 
        self.currentFoodItem = foodType
        }
        selectFoodLabel.text = self.currentFoodItem?.name
        
    }
    
    //EaterySelectionDelegate
    func passEatery(eatery: Eatery) -> Void {
        self.currentEatery = eatery
        selectEateryLabel.text = self.currentEatery?.name
    }
    
    //TextView Delegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //Global shared instance
    class func sharedInstance() -> EditJournalEntryViewController {
        struct Singleton {
            static var sharedInstance = EditJournalEntryViewController()
        }
        return Singleton.sharedInstance
    }

}