//
//  FoodTypeDetailViewController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 9/8/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit


//Used to populate each detail view with appropriate information
class FoodTypeDetailViewController : UIViewController, FoodTypePageViewDelegate {
    
    //Create variables
    var textBody : String?
    var currentFoodItem : Food?
    var foodTypePageViewDelegate : FoodTypePageViewDelegate?
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var historyTextView: UITextView!
    @IBOutlet weak var recommendationTextView: UITextView!
    
    //Lifecycle
    override func viewDidLoad() {
        getTextForDisplay()
    }
    
    //Lifecycle
    override func viewWillAppear(animated: Bool) {
        getTextForDisplay()
    }
    
    //Helper function for setting text in each view
    func getTextForDisplay()  {
        switch self.restorationIdentifier! {
            
        case FoodTypeDetails.Description.rawValue :
             descriptionTextView.text = self.currentFoodItem!.briefDescription
             self.descriptionTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        case FoodTypeDetails.History.rawValue :
            historyTextView.text = self.currentFoodItem!.history
            self.historyTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        case FoodTypeDetails.Recommendations.rawValue :
            recommendationTextView.text = self.currentFoodItem!.recommendations
             self.recommendationTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        default :
            return
        }
    }
    
    //FoodTypePageViewDelegate Method
    func passFoodType(foodType: Food) -> Void {
         self.currentFoodItem = foodType
    }
    
    //Enum for selecting appropriate controller
    enum FoodTypeDetails : String {
        
        case Description = "briefDescriptionController"
        case History = "historyController"
        case Recommendations = "recommendationsController"
    }
}
