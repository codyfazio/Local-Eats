//
//  EateryPhoto.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 9/20/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(EateryPhoto)

class EateryPhoto : NSManagedObject {
    
    // Used to get info from Foursquare response to create our Photo objects
    struct Keys {
        static let URL = "urlString"
    }
    
    // Managed variables that work in conjuction with our Data Model attributes
    @NSManaged var url : String
    @NSManaged var eatery : Eatery?
    @NSManaged var downloadedPhoto : UIImage?
    
    // Standard init when using Core Data
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context : NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // Photo object init with support for our managedObjectContext
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("EateryPhoto", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        url = dictionary[Keys.URL] as! String
    }
    
    // Computed property that stores our retrieved image in cache and on disk
    var photoImage: UIImage? {
        get {return ImageCache.Caches.imageCache.imageWithIdentifier(url.lastPathComponent)}
        set {ImageCache.Caches.imageCache.storeImage(newValue, withIdentifier: url.lastPathComponent) }
    }
    
    override func prepareForDeletion() {
        let fileManager = NSFileManager.defaultManager()
        let cachedImagePath = ImageCache.Caches.imageCache.pathForIdentifier(url.lastPathComponent)
        
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
