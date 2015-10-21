//
//  FoursquareConstants.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/16/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation

class FoursquareConstants {
    
    struct Constants {
        static let ClientID = "AZXLQTIHAN1NHSA10N1WBMW01UMEHBIMKZB5NMXXRQ51D1IJ"
        static let ClientSecret = "5H2VM1YXHFYHJE3OPRBHQDGIHURF0PQ413ZFFZFVQI13NWJY"
        
        static let BaseURLSecure = "https://api.foursquare.com/v2/venues/"
        static let ExploreMethod = "explore"
        static let SearchMethod = "search"
        static let Query = "query"
        static let Version = "v"
        static let VersionValue = "20150816"
        static let Mode = "m"
        static let ModeValue = "foursquare"
        static let Location = "near"
        static let Phone = "phone"
        static let LatLong = "ll"
        static let Intent = "intent"
        static let IntentValue = "match" //Finds venues that are are nearly-exact matches for the given parameters
        static let BestPhotoSize = "300x500"
    }
}