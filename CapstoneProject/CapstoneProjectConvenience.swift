//
//  CapstoneProjectConvenience.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 9/5/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class CapstoneProjectConvenience: NSObject {
    
    // Create a reference to the shared context
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //Helper function that takes a food item's location, checks to make sure its nearby and still open, and returns an array 
    //of eateries
    func getSuggestedEateriesFromYelp(currentFoodItemCoordinate: CLLocationCoordinate2D, foodItemRegion: MKCoordinateRegion?, currentFoodItemName:  String, completionHandler: (success: Bool, error: String?, yelpResults: [Eatery]?) -> Void) {
        
        YelpClient.sharedInstance().doOAuthYelp(currentFoodItemCoordinate, searchString: currentFoodItemName) {success, error, results in
            if success {
                
                self.createEateriesFromJSON(results!){success, error, yelpResults in
                    if success {
                        
                            completionHandler(success: true, error: nil, yelpResults: yelpResults)
                    
                    } else {
                            completionHandler(success: false, error: error, yelpResults: nil)
                        }
                    }
            } else {
                    completionHandler(success: false, error: error, yelpResults: nil)
            }
        }
        
    }
    
    //Helper function for finding specific eatery
    func performSearchForEateries(searchTerm: String, mapRegion: MKCoordinateRegion, completionHandler: (success : Bool, error: String?, eateries: [Eatery]?) -> Void) {
        
        
        var foundEateries = [Eatery]()
        var mapItemsArray = [MKMapItem]()
        
        //First, perform search in region for searchTerm
        self.searchWithNaturalLanguageQuery(searchTerm, mapRegion: mapRegion) {success, error, response in
            if success {
                
                
                //Because the search API only uses the region as a suggestion, we make sure the results are in our region
                //They are returned as mapItems
                mapItemsArray = self.createArrayFromResultsInRegion(response!, mapRegion: mapRegion)
                
                var index = 0
                for item in mapItemsArray {
                    
                    //Get coordinate of the item
                    let itemCoordinate = item.placemark.coordinate
                    
                    //Search yelp for eateries with coordinate and original search term
                    YelpClient.sharedInstance().doOAuthYelp(itemCoordinate, searchString: searchTerm) {success, error, results in
                      
                        if success {
                            
                            //Check to see if we can match the result of our naturalLanguageQuery to a Yelp result
                            self.verifyEateryFromYelpSearch(item.name!, results: results!) {status, eatery in
                                if status {
                                    foundEateries.append(eatery!)
                                }
                                
                                index = index + 1
                                if (index == mapItemsArray.count) {
                                    
                                    completionHandler(success: true, error: nil, eateries: foundEateries)
                                }
                            }
                            
                        } else {
                            completionHandler(success: false, error: "Error searching yelp for eateries.", eateries: nil)
                        }
                    }
                }
            } else {
               completionHandler(success: false, error: error, eateries: nil)
            
            }
        }
    }
    
    //Function for getting search results through natural language query
    func searchWithNaturalLanguageQuery(searchTerm: String, mapRegion : MKCoordinateRegion, completionHandler: (success: Bool, error: String?, response: MKLocalSearchResponse? ) -> Void) {
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchTerm
        
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearchRequest.region = mapRegion
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if error != nil {
               completionHandler(success: false, error: error!.localizedDescription, response: nil)
                
            } else {
    
                completionHandler(success: true, error: nil, response: localSearchResponse)
            }
        }
        
    }
    
    //Function performs a secondary check to ensure yelp items are in the specified search region
    func createArrayFromResultsInRegion(searchResponse : MKLocalSearchResponse, mapRegion: MKCoordinateRegion) -> [MKMapItem] {
        
        let mapRect = self.mapRectFromCoordinateRegion(mapRegion)
        var itemsInRegion = [MKMapItem]()
        
        for item in searchResponse.mapItems{
            
            let currentMapItem = item as MKMapItem
            let itemCoordinate =  currentMapItem.placemark.coordinate
            let itemPoint = MKMapPointForCoordinate(itemCoordinate)
           
            if MKMapRectContainsPoint(mapRect, itemPoint) {
                itemsInRegion.append(currentMapItem)
            }
        }
       return itemsInRegion
    }
    
    //Function takes an array of yelp results and returns an array of eateries
    func createEateriesFromJSON(searchResults: [[String: AnyObject]], completionHandler:(success: Bool, error: String?, eateries: [Eatery]?) -> Void)  {
        
        var eateries = [Eatery]()
        
        if searchResults.count > 0 {
            for index in 0...searchResults.count.predecessor() {
                
                let eatery = Eatery(dictionary: searchResults[index], context: self.sharedContext)
                let isClosed = eatery.closed
                if (isClosed == false)  {
                    eateries.append(eatery)
                }
            }
                completionHandler(success: true, error: nil, eateries: eateries)
        } else {
                completionHandler(success: false, error: "No eateries found.", eateries: nil)
        }
    }
    
    
    //Helper function converted from objective C here...
    //http://stackoverflow.com/questions/9270268/convert-mkcoordinateregion-to-mkmaprect
    func mapRectFromCoordinateRegion(region: MKCoordinateRegion) -> MKMapRect{
        
        let a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
            region.center.latitude + region.span.latitudeDelta/2,
            region.center.longitude - region.span.longitudeDelta/2))
        let b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
            region.center.latitude - region.span.latitudeDelta/2,
            region.center.longitude + region.span.longitudeDelta/2))
        
         return MKMapRectMake(min(a.x,b.x), min(a.y,b.y), abs(a.x-b.x), abs(a.y-b.y))

    }
    
    //Function that takes the student data objects created from Parse and packages them for making map pins
    func buildAnnotations(yelpItems : [Eatery]) -> [MKPointAnnotation] {
        
        var annotations = [MKPointAnnotation]()
        
        for item in yelpItems {
            
            let annotation = MKPointAnnotation()
            
            let latitude = item.latitude as CLLocationDegrees
            let longitude = item.longitude as CLLocationDegrees
            
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            annotation.title = item.name

    
            annotations.append(annotation)
        }
        return annotations
    }
    
    
    //Function takes the necessary parameters and creates a journal entry. It then assigns a food type and photo to that entry.
    func createJournalEntry(food: Food, eatery: Eatery, date: NSDate, photo: UIImage,
        rating: Int, review: String, completionHandler: (success: Bool, error: String?) -> Void) {
            
        let identifier = self.buildIdentifierFromDate(date)
        let parameters : [String : AnyObject] = [
            
            "name" : food.name,
            "rating" : rating,
            "review" : review,
            "latitude" : eatery.latitude,
            "longitude" : eatery.longitude,
            "date" : date
        ]

        let newJournalEntry = JournalEntry(dictionary: parameters, context: self.sharedContext)
        
        newJournalEntry.food = food
        newJournalEntry.eatery = eatery

        ImageCache.Caches.imageCache.storeImage(photo, withIdentifier: identifier)
        
        let record = food.record
        CloudKitClient.sharedInstance().postToiCloud(record, rating: rating, entry: newJournalEntry) {success, error in
            if success {
                CoreDataStackManager.sharedInstance().saveContext()
                completionHandler(success: true, error: nil)
            } else {
                completionHandler(success: false, error: error)
            }
        }
    }
    
    //Helper function for getting foods near the user, creating food objects, and downloading their associated photos
    func getFoodsForNearMe(location: CLLocation, completionHandler: (success: Bool, error: NSError?, foods: [Food]?, isUser: Bool) -> Void) {
        
        //TODO: Add radius max value (500 miles converted to kilometers) to CapstoneProjectConstants
        let radius = 804.672 * 1000
        
        CloudKitClient.sharedInstance().fetchFoodTypes(location, radiusInMeters: radius) {success, foodArray, error, isUser in
            
                if success {
                    if foodArray!.count != 0 {
                        let foods = foodArray as! [Food]?
                            var count = 0
                            for each in foods! {
                                CloudKitClient.sharedInstance().fetchRatings(each.record.recordID) {rating, isUser in
                                    if isUser {
                                        each.rating = rating
                                        count = ++count
                                        if count == foods!.count {
                                            dispatch_async(dispatch_get_main_queue()) {
                                                completionHandler(success: true, error: nil, foods: foods, isUser: true)
                                            }
                                        }
                                    } else {
                                        count = ++count
                                        if count == foods!.count {
                                            dispatch_async(dispatch_get_main_queue()) {
                                                completionHandler(success: true, error: nil, foods: foods, isUser: false)
                                            }
                                        }

                                        completionHandler(success: true, error: nil, foods: nil, isUser: false)
                                    }
                                }
                            }
                    } else {
                        completionHandler(success: true, error: nil, foods: nil, isUser: true)
                    }
                } else {
                    if isUser {
                        completionHandler(success: false, error: error, foods: nil, isUser: true)
                    } else {
                        completionHandler(success: false, error: error, foods: nil, isUser: false)
                    }
                }
        }
    }
    
    //Helper function for getting all foods from iCloud
    func getFoodsForLocalFood(completionHandler: (success: Bool, foods: [Food]?, error: String?) -> Void) {
        
        CloudKitClient.sharedInstance().fetchAllFood(){success, foodArray, error in
            if success {
                let foods = foodArray as! [Food]
                completionHandler(success: true, foods: foods, error: nil)
            } else {
                completionHandler(success: false, foods: nil, error: error)
            }
        }
    }
    
    //Helper function for creating a date identifier to store and retrieve images
    func buildIdentifierFromDate(date: NSDate) -> String {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        let dateString = formatter.stringFromDate(date)
        return dateString
    }
    
    //Helper function for cross referencing items between MapKit(natural language query) and Yelp
    func verifyEateryFromYelpSearch (eateryName: String, results : [[String: AnyObject]], completionHandler: (status: Bool, eatery : Eatery?) -> Void) {
        
        var eatery : Eatery?
        for item in results {
            
            if let itemName = item["name"] as? String {
                if itemName == eateryName {
                    eatery = Eatery(dictionary: item as [String : AnyObject], context: self.sharedContext)
                }
            }
        }
        
        if eatery != nil {
                completionHandler(status: true, eatery: eatery)
        } else {
                completionHandler(status: false,  eatery: nil)
        }
    }

    //Helper function that checks a yelp business rating and returns the appropriate Yelp rating image
    func getImageForYelpRating (rating: Double, completionHandler:(image: UIImage?, error: String?) -> Void) {
        
        let numberOfYelpStars = CapstoneProjectConstants.YelpRatingImages(rawValue: rating)
        var ratingImage = UIImage?()
        
        if (rating >= 1 && rating <= 5) {
            switch numberOfYelpStars! {
                
                case .OneStar:
                    ratingImage = UIImage(named: "1star")!
                    
                case .OneOneHalfStars:
                    ratingImage = UIImage(named: "1.5stars")!

                case .TwoStars:
                    ratingImage = UIImage(named: "2stars")!

                case .TwoOneHalfStars:
                    ratingImage = UIImage(named: "2.5stars")!

                case .ThreeStars:
                    ratingImage = UIImage(named: "3stars")!

                case .ThreeOneHalfStars:
                    ratingImage = UIImage(named: "3.5stars")!

                case .FourStars:
                    ratingImage = UIImage(named: "4stars")!

                case .FourOneHalfStars:
                    ratingImage = UIImage(named: "4.5stars")!

                case .FiveStars:
                    ratingImage = UIImage(named: "5stars")!
                }
            completionHandler(image: ratingImage, error: nil)
        } else {
            completionHandler(image: ratingImage, error: "Value out of bounds for Yelp Image")
        }
        
    }
    
    //Helper function for getting the ratings from iCloud
    func getFoodRating (food:Food, completionHandler: (Bool) -> Void) {
        CloudKitClient.sharedInstance().fetchRatings(food.record.recordID){ averageRating, isUser in
            
            if isUser {
                food.rating = averageRating
                completionHandler(true)
            } else {
                
                food.rating = nil
                completionHandler(false)
            }
        }
    }
    
    //Helper function takes the food rating from iCloud and returns the appropriate thumb image
    func setFoodRating(food : Food, completionHandler: (UIImage?, rating: String) -> Void)  {
        
        var ratingImage = UIImage?()

        if let rating = food.rating  {
            
            let foodRating = Double(rating)
            
            if foodRating >  1 {
            switch foodRating {
                
            case 1.0..<1.5:
                ratingImage = UIImage(named: "thumbsDownFilled")!
            case 1.5...2:
                ratingImage = UIImage(named: "thumbsUpFilled")!
            default:
                ratingImage = UIImage(named: "thumbsDownEmpty")!
                
            }
            
            let convertedRating = self.convertFoodRating(foodRating)
            completionHandler(ratingImage, rating: convertedRating)
                
            } else {
                getFoodRating(food) {success in
                    if success {
                        let newFoodRating = Double(food.rating!)
                        switch foodRating {
                            
                        case 1.0..<1.5:
                            ratingImage = UIImage(named: "thumbsDownFilled")!
                        case 1.5...2:
                            ratingImage = UIImage(named: "thumbsUpFilled")!
                        default:
                            ratingImage = UIImage(named: "thumbsDownEmpty")!
                            
                        }
                        let convertedRating = self.convertFoodRating(newFoodRating)

                        completionHandler(ratingImage, rating: convertedRating)
                    }
                }
            }
            
        } else {
            getFoodRating(food) {success in
                if success {
                    let neededFoodRating = Double(food.rating!)
                    switch neededFoodRating {
                        
                    case 1.0..<1.5:
                        ratingImage = UIImage(named: "thumbsDownFilled")!
                    case 1.5...2:
                        ratingImage = UIImage(named: "thumbsUpFilled")!
                    default:
                        ratingImage = UIImage(named: "thumbsDownEmpty")!

                    }
                    let convertedRating = self.convertFoodRating(neededFoodRating)
                    completionHandler(ratingImage, rating: convertedRating)
                }
            }
        }
    }
    
    func convertFoodRating(rating: Double) -> String {
        
        let scaledRating = (rating - 1) * 10
        let ratingString = String(scaledRating)
        return ratingString
    }
    
    //Convenience function for displaying alerts
    func displayAlert(title: String, message: String, controller: UIViewController,  activityIndicator: UIActivityIndicatorView?) {
        let alertView = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        dispatch_async(dispatch_get_main_queue()) {
            if activityIndicator != nil {
                activityIndicator!.stopAnimating()
            }
            controller.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    

    //Global shared instance
    class func sharedInstance() -> CapstoneProjectConvenience {
        
        struct Singleton {
            static let sharedInstance = CapstoneProjectConvenience()
        }
        return Singleton.sharedInstance
    }
}

//Extensions
extension Array {
    mutating func shuffle() {
        if count > 1 {
        for i in 0 ..< (count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if j != i {
                swap(&self[i], &self[j])
            }
        }
    }
    }
}

//Used to re-extend pathExtension and lastPathComponent to Strings (removed in Swift 2)
extension String {
    var pathExtension: String? {
        return NSString(string: self).pathExtension
    }
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
}