//
//  FoursquareClient.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/16/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation

class FoursquareClient: NSObject {
    
    //Create variables 
    var session: NSURLSession
    
    //Initialize session
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Create a reference to the shared context
    lazy var sharedContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    func searchForVenue(eatery: Eatery, completionHandler: (success: Bool, error: String?) -> Void) {
        
        var mutableParameters : [String: AnyObject]?
        var passedBody : [String : AnyObject]?
        var headers : [String: AnyObject]?
        let venueName = eatery.name
        let venuePhoneNumber = eatery.phone
        let lat = Double(eatery.latitude)
        let long = Double(eatery.longitude)
        
        mutableParameters = buildSearchParameters(venueName, venuePhoneNumber: venuePhoneNumber, lat: lat, long: long)
        
        let searchVenueRequest = NetworkingConvenience.sharedInstance().buildGetRequest(FoursquareConstants.Constants.BaseURLSecure, method: FoursquareConstants.Constants.SearchMethod, passedBody: passedBody, headers: headers, mutableParameters: mutableParameters)
        
        if searchVenueRequest != nil {
            NetworkingConvenience.sharedInstance().buildTask(searchVenueRequest!) {success, data, response, downloadError in
                if downloadError != nil {
                    completionHandler(success: false, error: downloadError!)
                } else {
                    NetworkingConvenience.sharedInstance().parseJSONWithCompletionHandler(data) {parsedData, parsedError in
                    
                        if parsedError != nil {
                            completionHandler(success: false, error: parsedError!.localizedDescription)
                        } else {
                            
                            if let response = parsedData["response"] as? [String: AnyObject] {
                                if let venue = response["venues"] as? NSArray? {
                                    if venue?.count > 0 {
                                        if let venueID : AnyObject = venue!.objectAtIndex(0) as AnyObject?  {
                                            let idString : String = venueID.valueForKey("id") as! String
                                            self.photoFromVenue(idString) {success, error, photo in
                                                if success {
                                                    eatery.photo = photo
                                                    completionHandler(success: true, error: nil)
                                                } else {
                                                    completionHandler(success: false, error: error)
                                                }
                                            }
                                        } else {
                                             completionHandler(success: false, error: "Couldn't get venueID")
                                        }
                                    } else {
                                        completionHandler(success: false, error: "No venue found")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func photoFromVenue(venueID : String, completionHandler: (success: Bool, error: String?, photo: EateryPhoto?) -> Void) {
        
        var mutableParameters : [String: AnyObject]?
        var passedBody : [String : AnyObject]? = nil
        var headers : [String: AnyObject]? = nil
        
        mutableParameters = buildVenueParameters()
        
        let searchVenueRequest = NetworkingConvenience.sharedInstance().buildGetRequest(FoursquareConstants.Constants.BaseURLSecure, method: venueID, passedBody: passedBody, headers: headers, mutableParameters: mutableParameters)

        if searchVenueRequest != nil {
            NetworkingConvenience.sharedInstance().buildTask(searchVenueRequest!) {success, data, response, downloadError in
                if downloadError != nil {
                    completionHandler(success: false, error: downloadError!, photo: nil)
                } else {
                    NetworkingConvenience.sharedInstance().parseJSONWithCompletionHandler(data) {parsedData, parsedError in
                        
                        if parsedError != nil {
                            completionHandler(success: false, error: parsedError!.localizedDescription, photo: nil)
                        } else {
                            
                            if let response = parsedData["response"] as? NSDictionary {
                                if let venue = response["venue"] as? NSDictionary {
                                    if let bestPhoto = venue["bestPhoto"] as? NSDictionary {
                                        var prefix : String?
                                        var suffix : String?
                                        let size = FoursquareConstants.Constants.BestPhotoSize
                                        if let bestPhotoPrefix = bestPhoto["prefix"] as? String {
                                            prefix = bestPhotoPrefix
                                        }
                                        if let bestPhotoSuffix = bestPhoto["suffix"] as? String {
                                            suffix = bestPhotoSuffix
                                        }
                                        
                                        if (prefix != nil && suffix != nil) {
                                        let photo = self.buildFoursquarePhoto(prefix!, suffix: suffix!, size: size)
                                        completionHandler(success: true, error: nil, photo: photo)
                                        }
                                        
                                    } else {
                                        completionHandler(success: false, error: "No image found." , photo: nil)
                                    }
                                } else {
                                    completionHandler(success: false, error: "No venue found." , photo: nil)
                                }
                            } else {
                                completionHandler(success: false, error: "Response could not be read." , photo: nil)
                            }
                        }
                    }
                }
            }
            
        }
    }

    func buildSearchParameters(venueName: String, venuePhoneNumber : String?, lat : Double, long: Double) -> [String: AnyObject] {
        
        var mutableParameters : [String: AnyObject] = [
            
            "client_id" : FoursquareConstants.Constants.ClientID,
            "client_secret" : FoursquareConstants.Constants.ClientSecret,
            
            FoursquareConstants.Constants.Location : "\(lat), \(long)",
            
            FoursquareConstants.Constants.Query : venueName,
            FoursquareConstants.Constants.Version : FoursquareConstants.Constants.VersionValue,
            FoursquareConstants.Constants.Mode : FoursquareConstants.Constants.ModeValue,
            FoursquareConstants.Constants.Intent : FoursquareConstants.Constants.IntentValue
        ]
        
        if let phone = venuePhoneNumber {
            mutableParameters[FoursquareConstants.Constants.Phone] = phone
        }
        return mutableParameters
    }
    
    func buildVenueParameters() -> [String: AnyObject] {
        
        let mutableParameters : [String: AnyObject] = [
            
            "client_id" : FoursquareConstants.Constants.ClientID,
            "client_secret" : FoursquareConstants.Constants.ClientSecret,
            
            FoursquareConstants.Constants.Version : FoursquareConstants.Constants.VersionValue,
            FoursquareConstants.Constants.Mode : FoursquareConstants.Constants.ModeValue,
        ]
        return mutableParameters
    }
    
    func buildFoursquarePhoto(prefix: String, suffix: String, size: String) -> EateryPhoto {
        
        let urlString = prefix + size + suffix
        let photoDictionary = ["urlString" : urlString]
        let eateryPhoto = EateryPhoto(dictionary: photoDictionary, context: self.sharedContext)
        return eateryPhoto
    }
    
    // Called to download the photo image after we create our photo object
    func downloadPhotoImageForEatery(imageForDownload: EateryPhoto, completionHandler: (success: Bool, data: NSData?, errorString: String?) -> Void) -> NSURLSessionDataTask {
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: imageForDownload.url)
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(success: false, data: nil, errorString: error.description)
            } else {
                if let data = data {
                    completionHandler(success: true, data: data, errorString: nil)
                }
            }
        }
        task.resume()
        return task
    }

    class func sharedInstance() -> FoursquareClient {
        
        struct Singleton {
            static let sharedInstance = FoursquareClient()
        }
        return Singleton.sharedInstance
    }
}