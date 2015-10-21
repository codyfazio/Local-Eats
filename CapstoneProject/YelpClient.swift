//
//  YelpClient.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/29/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import OAuthSwift
import UIKit
import MapKit

class YelpClient : UIViewController {
    
    // Create a reference to the shared context
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()

    func doOAuthYelp(coordinate: CLLocationCoordinate2D, searchString: String?, completionHandler: (success: Bool, error: String?, results: [[String: AnyObject]]?)-> Void){
    
        let oauthClient = OAuthSwiftClient(
            consumerKey:    CapstoneProjectConstants.Yelp.MY_CON_KEY,
            consumerSecret:    CapstoneProjectConstants.Yelp.MY_CON_SECRET,
            accessToken:        CapstoneProjectConstants.Yelp.MY_ACCESS_TOKEN,
            accessTokenSecret:  CapstoneProjectConstants.Yelp.MY_ACCESS_SECRET
        )
        
            let params = buildParameters(coordinate, searchString: searchString!)
        
            oauthClient.get("http://api.yelp.com/v2/search",
            parameters: params,
            success: { (data, response) -> Void in
                
                do {
                    //TODO: Get reading options to allow nil 
                    if let json: NSDictionary =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                   
                if let restaurantDictionary = json["businesses"] as? [[String: AnyObject]] {
        
                    dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(success: true, error: nil, results: restaurantDictionary)
                    }
                }
                    } } catch {
                        
                }
            
        }) { (error) -> Void in
            completionHandler(success: false, error: error.localizedDescription, results: nil)
        }
    }
    
    func getEateriesForCollectionView(foods: [Food], completionHandler: (success: Bool, error: String?, eateries: [Eatery]?) -> Void) {
        
        
        self.getEateries(foods) {success, error, yelpItems in
            
            if success {
                self.getPhotosForEateries(yelpItems!) {success, error, eateriesWithPhotos in
                    if success {
                        var shuffledResults = eateriesWithPhotos!
                        shuffledResults.shuffle()
                        completionHandler(success: true, error: nil, eateries: shuffledResults)
                        
                    } else {
                        completionHandler(success: false, error: error, eateries: nil)
                    }
                }
                
            } else {
                completionHandler(success: false, error: error, eateries: nil)
            }
        }
    }

    func getEateriesForMapView(food: Food, completionHandler: (success: Bool, error: String?, eateries: [Eatery]?) -> Void) {
        
        var singleFoodArray = [Food]()
        singleFoodArray.append(food)
        self.getEateries(singleFoodArray) {success, error, yelpItems in
            
            if success {
                self.getPhotosForEateries(yelpItems!) {success, error, eateriesWithPhotos in
                    if success {
                        var shuffledResults = eateriesWithPhotos!
                        shuffledResults.shuffle()
                        completionHandler(success: true, error: nil, eateries: shuffledResults)
                        
                    } else {
                        completionHandler(success: false, error: error, eateries: nil)
                    }
                }
                
            } else {
                completionHandler(success: false, error: error, eateries: nil)
            }
        }
    }

    func getEateries(foods: [Food], completionHandler: (success: Bool, error: String?, yelpItems: [Eatery]?) -> Void) {
        
        var index = 0
        var yelpItems = [Eatery]()
        
        for food in foods {
            
            let foodCoordinate = food.location.coordinate
            CapstoneProjectConvenience.sharedInstance().getSuggestedEateriesFromYelp(foodCoordinate, foodItemRegion: nil, currentFoodItemName: food.name) {success, error, yelpResults in
                if success {
                    yelpItems.appendContentsOf(yelpResults!)
                    index = ++index
                    if index == foods.count {
                        completionHandler(success: true, error: nil, yelpItems: yelpItems)
                        }
                } else {
                        //TODO: Better error handling...
                    completionHandler(success: false, error: error, yelpItems: nil)
                }
            }
        }
    }

    func getPhotosForEateries(eateries : [Eatery], completionHandler:(success: Bool, error: String?, eateriesWithPhotos: [Eatery]?) -> Void) {
        
        var foursquareVenuesWithPhotos = [Eatery]()
        var index = 0
        
        for eatery in eateries {
            FoursquareClient.sharedInstance().searchForVenue(eatery) {success, error in
                if success {
                    
                    foursquareVenuesWithPhotos.append(eatery)
                    index = ++index
                    if index == eateries.count {
                        if foursquareVenuesWithPhotos.count > 0 {
                            completionHandler(success: true, error: nil, eateriesWithPhotos: foursquareVenuesWithPhotos)
                        } else {
                            completionHandler(success: false, error: error, eateriesWithPhotos: nil)
                        }
                    }
                } else {
                    index = ++index
                    if index == eateries.count {
                        if foursquareVenuesWithPhotos.count > 0 {
                            completionHandler(success: true, error: nil, eateriesWithPhotos: foursquareVenuesWithPhotos)
                        } else {
                            completionHandler(success: false, error: error, eateriesWithPhotos: nil)
                        }
                    }
                }
            }
        }
    }

    
    func buildParameters(coordinate: CLLocationCoordinate2D, searchString: String) -> [String : String] {
        
        let latitude = coordinate.latitude as Double
        let longitude = coordinate.longitude as Double
        
        let preparedString = searchString.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let parameters : [String: String] = [
            //"location" : "Home",
            "ll": "\(latitude),\(longitude)",
            "term": preparedString
        ]
        return parameters
    }
        
    class func sharedInstance() -> YelpClient {
        
        struct Singleton {
            static let sharedInstance = YelpClient()
        }
        return Singleton.sharedInstance
    }
}
