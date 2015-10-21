//
//  FoodTypePageViewController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 9/7/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

//Protocol for passing food type to the detail controller
protocol FoodTypePageViewDelegate {
    func passFoodType(foodType : Food) -> Void
}

//Manages the views that comprise the page view
class FoodTypePageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    //Create variables
    var currentFoodItem : Food?
    var pageViewDelegate : FoodTypePageViewDelegate?
    var index = 0
    var identifiers : Array = ["briefDescriptionController", "historyController", "recommendationsController"] // Insert storyboard ids of controller to be displayed here.
    
    //Lifecycle
    //Set dataSource and delegate to self, set up the controller array, and display the initial controller
    override func viewDidLoad() {
        
        pageViewDelegate?.passFoodType(currentFoodItem!)         
        self.dataSource = self
        self.delegate = self
        
        let startingViewController = self.viewControllerAtIndex(self.index)!
        let viewControllers : Array? = [startingViewController]
        self.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        //Set up page control
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGrayColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.whiteColor()
        
    }
    
    //Function for keeping track of view controllers
    func viewControllerAtIndex(index: Int) -> UIViewController! {
        
        switch (index) {
        case 0:
            
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("briefDescriptionController") as! FoodTypeDetailViewController
               controller.currentFoodItem = currentFoodItem
            
            return controller
        case 1:
            let controller =  self.storyboard?.instantiateViewControllerWithIdentifier("historyController") as! FoodTypeDetailViewController
                controller.currentFoodItem = currentFoodItem
            return controller
        case 2:
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("recommendationsController") as! FoodTypeDetailViewController
                controller.currentFoodItem = currentFoodItem
            return controller
            
        default:
            return nil
        }
    }
    
    //PageViewController 
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier!
        let index = self.identifiers.indexOf(identifier)
        
        if index == identifiers.count - 1 {
            return nil
        }
        self.index = index! + 1
        return self.viewControllerAtIndex(self.index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let identifier = viewController.restorationIdentifier
        let index = self.identifiers.indexOf(identifier!)
        
        if index == 0 {
            return nil
        }
        
        self.index = index! - 1
        return self.viewControllerAtIndex(self.index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.identifiers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    class func sharedInstance() -> FoodTypePageViewController {
        struct Singleton {
            static var sharedInstance = FoodTypePageViewController()
        
        }
        return Singleton.sharedInstance
    }
}
