//
//  NetworkingConvenience.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/16/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import CoreData

class NetworkingConvenience : NSObject {
    
    //Create variables
    var session: NSURLSession
    
   //Initialize session
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func buildTask(request:NSMutableURLRequest, completionHandler: (success: Bool, result: NSData!, response: NSURLResponse? , errorString: String?) -> Void) -> NSURLSessionDataTask
    {
        let task = session.dataTaskWithRequest(request) {(data, response, downloadError) in
            
            if downloadError != nil {
                completionHandler(success: false, result: nil, response: nil, errorString: String(stringInterpolationSegment: downloadError!.localizedDescription))
            } else {
                completionHandler(success: true, result: data, response: response, errorString: nil)
            }
    }
        task.resume()
        return task
    }
    
    //Builds get request to pass into build task function
    func buildGetRequest(urlBaseString: String!, method: String!, passedBody: [String: AnyObject]?, headers: [String: AnyObject]?, mutableParameters: [String: AnyObject]?) -> NSMutableURLRequest? {
        
        let result = buildURL(urlBaseString, method: method, mutableParameters: mutableParameters)
       // var jsonError: NSError? = nil
        let request = NSMutableURLRequest(URL: result)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if headers != nil
        {for (key,value) in headers! {
            request.addValue((value as? String)!, forHTTPHeaderField: key)
            }
        }
        return request
    }
    
    //Builds Post request from Get request and returns it for building tasks
    func buildPostRequest(urlBaseString: String!, method: String!, passedBody: [String: AnyObject], headers: [String : AnyObject]?, mutableParameters: [String: AnyObject]?) -> NSMutableURLRequest? {
        
        var jsonError : NSError? = nil
        let request = buildGetRequest(urlBaseString, method: method, passedBody: passedBody, headers: headers, mutableParameters: mutableParameters)
        request!.HTTPMethod = "POST"
        request!.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            try request!.HTTPBody = NSJSONSerialization.dataWithJSONObject(passedBody, options: NSJSONWritingOptions.PrettyPrinted)
           
        } catch {
            jsonError = error as NSError
            NSLog("Unresolved error \(jsonError), \(jsonError!.userInfo)")
        }
        
        return request!
    }
    
    func buildURL(urlBaseString: String, method: String, mutableParameters: [String : AnyObject]?) -> NSURL {
        
        var url : NSURL!
        if (mutableParameters != nil) {
            let urlString = urlBaseString + method + escapedParameters(mutableParameters!)
            url = NSURL(string: urlString)
        } else {
            let urlString = urlBaseString + method
            url = NSURL(string: urlString)

        }
        return url
    }
    
    //Read data returned from network into a usable form
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError : NSError? = nil
        var parsedResult : AnyObject?
        
        do {
           parsedResult =  try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch {
            parsingError = error as NSError
            NSLog("Unresolved error \(parsingError), \(parsingError!.userInfo)")
            
        }
    
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    //Function for checking network connection
    func isConnectedToNetwork() -> Bool {
        
        var status: Bool?
        let urlPath = "http://www.apple.com"
        let url = NSURL(string : urlPath)!
        let request = NSURLRequest(URL: url)
        var response: NSURLResponse?
        
        var data : NSData?
        do {
             data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
        } catch {
            let sendSychronousRequestError = error as NSError
            status = false
            NSLog("Unresolved error \(sendSychronousRequestError), \(sendSychronousRequestError.userInfo)")
            
        }
        
        if data != nil {
            checkResponse(response!) {success, responseCode in
                if success {
                    status = true
                } else {
                    status = false
                }
            }
        }
        return status!
    }
    
    func checkResponse(response: NSURLResponse, completionHandler: (success: Bool, responseCode: Int?) -> Void) {
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                completionHandler(success: true, responseCode: nil)
            } else {
                completionHandler(success: false, responseCode: httpResponse.statusCode)
            }
        }
    }
    
    //Helper function for escaping necessary data into a form usable in creating a URL
    func escapedParameters(parameters: [String:AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key,value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    //Create a global instance of this class
    class func sharedInstance() -> NetworkingConvenience {
        
        struct Singleton {
            static let sharedInstance = NetworkingConvenience()
        }
        return Singleton.sharedInstance
    }
    
}
