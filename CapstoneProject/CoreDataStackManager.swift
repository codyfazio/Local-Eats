//
//  CoreDataStackManager.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/16/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//


// Found a great guide to updating the Core Data Stack to Swift 2.0
//http://purelywebdesign.co.uk/tutorial/add-coredata-to-an-exiting-swift-2-0-project/
import Foundation
import CoreData

private let SQLITE_FILE_NAME = "CapstoneProject.sqlite"

class CoreDataStackManager {
    
    
    class func sharedInstance() -> CoreDataStackManager {
        struct Singleton {
            static let sharedInstance = CoreDataStackManager()
        }
        return Singleton.sharedInstance
    }
    
    lazy var applicationDocumentsDirectory : NSURL = {
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel : NSManagedObjectModel = {
        
        let modelURL = NSBundle.mainBundle().URLForResource("CapstoneProject", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CapstoneProject.sqlite")
        //var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if (managedObjectContext?.hasChanges != nil) {
            do {
                try managedObjectContext?.save()
            } catch {
                
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

