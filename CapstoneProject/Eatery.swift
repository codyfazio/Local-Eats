//
//  Eatery.swift
//  CapstoneProject
//
//  Created by Cody Clingan on 8/31/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import CoreData

@objc(Eatery)

class Eatery : NSManagedObject {
    
    struct Keys {
        
        static let ID = "id"
        static let Name = "name"
        static let PhoneNumber = "phone"
        static let LocationString = "location"
        static let URL = "url"
        static let Distance = "distance"
        static let Rating = "rating"
        static let Eat24URL = "eat24URL"
        static let ImageURL = "image_url"
        static let YelpRatingLargeImageURL = "rating_img_url_large"
        static let PermanentlyClosed = "is_closed"
    }
    
    @NSManaged var id : String
    @NSManaged var name : String
    @NSManaged var phone : String?
    @NSManaged var url : String
    @NSManaged var imageURL : String?
    @NSManaged var latitude : NSNumber
    @NSManaged var longitude : NSNumber
    @NSManaged var distance : NSNumber // In meters
    @NSManaged var rating : NSNumber?
    @NSManaged var eat24url : String?
    @NSManaged var ratingImgURLLarge : String?
    @NSManaged var closed : Bool
    @NSManaged var photo : EateryPhoto?
    var photoDownloadInProgress = false 
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Eatery", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.ID] as! String
        name = dictionary[Keys.Name] as! String
        phone = dictionary[Keys.PhoneNumber] as? String 
        url = dictionary[Keys.URL] as! String
        distance = dictionary[Keys.Distance] as! Double
        rating = dictionary[Keys.Rating] as! Double?
        eat24url = dictionary[Keys.Eat24URL] as! String?
        imageURL = dictionary[Keys.ImageURL] as! String?
        ratingImgURLLarge = dictionary[Keys.YelpRatingLargeImageURL] as! String?
        closed = dictionary[Keys.PermanentlyClosed] as! Bool
        
        
        let location  = dictionary[Keys.LocationString] as! NSDictionary
        if let coordinate = location["coordinate"] as? NSDictionary {
            latitude = coordinate["latitude"] as! Double
            longitude = coordinate["longitude"] as! Double
        }
    }
}
