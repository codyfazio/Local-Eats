//
//  CloudKitClient.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/16/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreLocation


// This class performs all communication between iCloud and our app. It fetches our food types from iCloud so we can make additions withough negatively effecting the user experience. We also store user ratings and food photos in iCloud. This allows us to get an average rating from all our users, and display random photos for different food types sourced from our users. 

let FoodType = "Food"

class CloudKitClient {
    
    let container : CKContainer
    let publicDB : CKDatabase
    let privateDB : CKDatabase
    var userRecordID : CKRecordID!
    
    init() {
        container = CKContainer.defaultContainer()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    
    // Create a reference to the shared context
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    func fetchFoodTypes(location: CLLocation, radiusInMeters: CLLocationDistance, completionHandler: (success: Bool, foodArray: NSArray?, error : NSError?, isUser: Bool)  -> Void) {
        
        var foodArray = [Food]()
        
        let locationPredicate = NSPredicate(format:
            "distanceToLocation:fromLocation:(%@, Location) < %f", location,
            radiusInMeters)
    
        let query = CKQuery(recordType: FoodType, predicate: locationPredicate)
    
        publicDB.performQuery(query, inZoneWithID: nil) {results, error in
        
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(success: false, foodArray: nil, error: error, isUser: true)
                    return
                }
                
            } else {
                
                if results != nil {
                    var count = 0
                    for record in results! {
                        let food = Food(record : record , database: self.publicDB, context: self.sharedContext)
                        if (self.validateRegion(food, currentLocation: location)) {
                            foodArray.append(food)
                            count = ++count
                        } else {
                            count = ++count
                        }
                        
                        if count == results?.count {
                                completionHandler(success: true, foodArray: foodArray, error: nil, isUser: true)
                            }
                        }
                } else {
                    completionHandler(success: true, foodArray: nil, error: nil, isUser: true)
                }
            }
        }
    }
    
    func fetchAllFood (completionHandler: (success: Bool, foodArray: NSArray?, error :String?)  -> Void) {
        
        var foodArray = [Food]()
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: FoodType, predicate: predicate)
        
        publicDB.performQuery(query, inZoneWithID: nil) {results, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(success: false, foodArray: nil, error: error!.localizedDescription)
                    return
                }
                
            } else {
                LocalFoodViewController.sharedInstance().items.removeAll(keepCapacity: true)
               
                for record in results! {
                    let food = Food(record : record , database: self.publicDB, context: self.sharedContext)
                    foodArray.append(food)
                }
                
                var count = 0
                for each in foodArray {
                    self.fetchRatings(each.record.recordID) {rating, isUser in
                        if isUser {
                            each.rating = rating
                            count = ++count
                            if count == foodArray.count {
                                dispatch_async(dispatch_get_main_queue()) {
                                    completionHandler(success: true, foodArray: foodArray, error: nil)
                                }
                            }
                        } else {
                            //Display iCloud Login Alert
                            completionHandler(success: false, foodArray: nil, error: "Error fetching food")
                        }
                    }
                }
            }
        }
    }
    
    func fetchRatings(userRecord : CKRecordID!, completionHandler:(rating: Double, isUser: Bool) -> ()) {
        
        let predicate = NSPredicate(format: "Food == %@", userRecord)
        
        let query = CKQuery(recordType: "Rating", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) {results, error in
            
            if error != nil {
                completionHandler(rating: 0 , isUser: false)
            } else {
                
                let resultsArray = results! as NSArray
                if let rating = resultsArray.valueForKeyPath("@avg.Rating") as? Double {
                    completionHandler(rating: rating, isUser: true)
                
                } else {
                    completionHandler(rating: 0, isUser: true)
                }
            }
        }
    }
    
    func fetchPhotos(foods : [Food], completionHandler: (success: Bool, error: String?) ->Void ) {
        
        var count = 0
        for each in foods {
                self.fetchPhoto(each.record.recordID) {photo, isUser in
                            if isUser {
                                if photo != nil {
                                dispatch_async(dispatch_get_main_queue()){
                                    each.photoImage = photo
                                    count = ++count
                                        if count == foods.count {
                                            completionHandler(success: true, error: nil)
                                        }
                                    }
                                } else {
                                    count = ++count
                                    if count == foods.count {
                                        completionHandler(success: true, error: nil)
                                    }
                                }
                            } else {
                                completionHandler(success: false, error: "Error fetching food")
                            }
                        }
                        
                    }
    }
    
    func fetchPhoto(userRecord : CKRecordID!, completionHandler:(photo: UIImage?, isUser: Bool) -> ()) {
        
        let predicate = NSPredicate(format: "Food == %@", userRecord)
        
        let query = CKQuery(recordType: "FoodPhoto", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) {results, error in
            
            if error != nil {
                completionHandler(photo: nil , isUser: false)
            } else {
                
                if (results != nil && results!.count != 0) {
                    var resultsArray = results
              
                        resultsArray!.shuffle()
                        if let photoRecord = resultsArray!.first  {
                            if let photoAsset = photoRecord.objectForKey("Photo") as? CKAsset {
                               
                                let photo = UIImage(contentsOfFile: photoAsset.fileURL.path!)
                                completionHandler(photo: photo, isUser: true)
                            
                            } else {
                                completionHandler(photo: nil, isUser: true)
                            }
                    }
                } else {
                    completionHandler(photo: nil, isUser: true)
                }

            }
        }
    }

    func postToiCloud(parentRecord: CKRecord, rating: NSNumber, entry: JournalEntry, completionHandler: (success: Bool, error: String?) -> Void) {
        
        self.postRating(parentRecord, rating: rating) {success, error in
            if success {
                self.postPhoto(parentRecord, entry: entry) {success, error in
                    if success {
                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: error)
                    }
                }
            } else {
                completionHandler(success: false, error: error)
            }
        }
        
    }
    
    func postRating(parentRecord: CKRecord, rating: NSNumber, completionHandler: (success: Bool, error: String?) -> Void) {
        
        let ratingRecord = CKRecord(recordType: "Rating")
        ratingRecord.setObject(rating, forKey: "Rating")
        
        let reference = CKReference(record: parentRecord, action: .DeleteSelf)
        ratingRecord.setObject(reference, forKey: "Food")
        
        self.getUserID() {userID, error in
            if let userRecord = userID {
                let userReference = CKReference(recordID: userRecord, action: .None)
                ratingRecord.setObject(userReference, forKey: "User")
                self.publicDB.saveRecord(ratingRecord) {record, error in
                    if error != nil {
                        
                        completionHandler(success: false, error: error!.localizedDescription)
                
                    } else {
                        
                        completionHandler(success: true, error: nil)
                    }
                }
            }
        }
    }
    
    func postPhoto(parentRecord: CKRecord, entry: JournalEntry, completionHandler:(success:Bool, error: String?) -> Void) {
        
        
        let identifier = entry.getDateString()
        let photoFileURL = ImageCache.Caches.imageCache.URLForIdentifier(identifier)
        
        let asset = CKAsset(fileURL: photoFileURL)
        
        let reference = CKReference(record: parentRecord, action: .DeleteSelf)
      
        
        self.getUserID() {userID, error in
            if let userRecord = userID {
                let userReference = CKReference(recordID: userRecord, action: .None)
                
                let photoRecord = CKRecord(recordType: "FoodPhoto")
                photoRecord.setObject(asset, forKey: "Photo")
                photoRecord.setObject(reference, forKey: "Food")
                photoRecord.setObject(userReference, forKey: "User")
                
                
                self.publicDB.saveRecord(photoRecord) {record, error in
                    if error != nil {
                        completionHandler(success: false, error: error!.localizedDescription)
                    } else {
                        completionHandler(success: true, error: nil)
                    }
                }
            }
        }
    }
    
    func getUserID(completion: (userID: CKRecordID!, error: NSError!)->()) {
        if userRecordID != nil {
            completion(userID: userRecordID, error: nil)
        } else {
            self.container.fetchUserRecordIDWithCompletionHandler() {
                recordID, error in
                if recordID != nil {
                    self.userRecordID = recordID
                }
                completion(userID: recordID, error: error)
            }
        }
    }

    func validateRegion(currentFood : Food, currentLocation: CLLocation) -> Bool {
        
        var result = false
        
        let distanceToFoodCenter = currentLocation.distanceFromLocation(currentFood.location)
        let currentFoodRadius = (currentFood.regionRadius as Double) * 1000
        if (distanceToFoodCenter < currentFoodRadius) {
            result = true
        } else {
            result = false
        }
        
        return result
    }
    
    class func sharedInstance() -> CloudKitClient {
        
        struct Singleton {
            static let sharedInstance = CloudKitClient()
        }
        return Singleton.sharedInstance
    }
    
}
