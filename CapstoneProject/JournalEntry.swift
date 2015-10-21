//
//  JournalEntry.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/27/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(JournalEntry)

class JournalEntry : NSManagedObject {
    
    
    struct Keys {
        
        static let Name = "name"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Review = "review"
        static let Rating = "rating"
        static let Date = "date"
           }
    
    // Managed variables that work in conjunction with our Data Model attributes
    @NSManaged var name: String
    @NSManaged var latitude : NSNumber
    @NSManaged var longitude : NSNumber
    @NSManaged var review : String
    @NSManaged var rating : NSNumber
    @NSManaged var food : Food?
    @NSManaged var eatery : Eatery? 
    @NSManaged var date : NSDate
    
    //Standard init when using Core Data
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Journal Entry init with support for our managedObjectContext
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("JournalEntry", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = dictionary[Keys.Name] as! String
        review = dictionary[Keys.Review] as! String
        rating = dictionary[Keys.Rating] as! Double
        date = dictionary[Keys.Date] as! NSDate
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude]as! Double

    }
    
    // Computed property that stores our retrieved image in cache and on disk
    var photoImage: UIImage? {
        
        get {return ImageCache.Caches.imageCache.imageWithIdentifier(getDateString())}
        set {ImageCache.Caches.imageCache.storeImage(newValue, withIdentifier: getDateString()) }
    }
    
    func getDateString() -> String {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        let dateString = formatter.stringFromDate(date)
        return dateString
    }
    
    override func prepareForDeletion() {
        let fileManager = NSFileManager.defaultManager()
        
       // Need to figure out where images are coming from!
        let cachedImagePath = ImageCache.Caches.imageCache.pathForIdentifier(getDateString())
        
        if fileManager.fileExistsAtPath(cachedImagePath) {
            do {
                try fileManager.removeItemAtPath(cachedImagePath)
            } catch {
                
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                print("Cached image could not be deleted.")
                
            }
        }
    }
}