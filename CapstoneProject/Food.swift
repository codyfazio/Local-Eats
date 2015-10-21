//
//  Food.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/26/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import CloudKit
import UIKit
import CoreData

@objc(Food)

class Food : NSManagedObject {
    
    @NSManaged var record : CKRecord!
    @NSManaged var name : String!
    @NSManaged var location : CLLocation!
    @NSManaged var region : String?
    @NSManaged var regionRadius : NSNumber!
    @NSManaged var briefDescription : String!
    @NSManaged var history : String!
    @NSManaged var recommendations : String?
    @NSManaged var rating : NSNumber?
    var database : CKDatabase!
    var ratingImage : UIImage?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(record : CKRecord, database: CKDatabase, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Food", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.record = record
        self.database = database
        
        self.name = record.objectForKey("Name") as! String
        self.region = record.objectForKey("Region") as! String?
        self.location = record.objectForKey("Location") as! CLLocation
        self.regionRadius = record.objectForKey("RegionRadius") as! Double
        self.briefDescription = record.objectForKey("BriefDescription") as! String
        self.history = record.objectForKey("History") as! String
        self.recommendations = record.objectForKey("Recommendations") as! String?
        
    }
    
    // Computed property that stores our retrieved image in cache and on disk
    var photoImage: UIImage? {

        get {return ImageCache.Caches.imageCache.imageWithIdentifier(getIdentifier())}
        set {ImageCache.Caches.imageCache.storeImage(newValue, withIdentifier: getIdentifier()) }
    }

    func getIdentifier() -> String {

        let identifier = String(self.record.recordID)
        return identifier
    }
    
    override func prepareForDeletion() {
        let fileManager = NSFileManager.defaultManager()
        let cachedImagePath = ImageCache.Caches.imageCache.pathForIdentifier(getIdentifier())
        
        if fileManager.fileExistsAtPath(cachedImagePath) {
            do {
                try fileManager.removeItemAtPath(cachedImagePath)
            } catch {
                let removeItemError = error as NSError
                NSLog("Unresolved error \(removeItemError), \(removeItemError.userInfo)")
                print("Cached image could not be deleted.")
            }
        }
    }
}

