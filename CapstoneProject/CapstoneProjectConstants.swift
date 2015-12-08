//
//  CapstoneProjectConstants.swift
//  CapstoneProject
//
//  Created by Cody Clingan on 8/29/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation

class CapstoneProjectConstants {
    
    struct Yelp {
    
        static let CONSUMER_KEY = "consumerKey"
        static let MY_CON_KEY = "SPexuTwSupNpCRciT4urJA"
        static let CONSUMER_SECRET = "consumerSecret"
        static let MY_CON_SECRET = "g1Z-qfH1ScmZx4X6FOksuuP-okA"
        static let ACCESS_TOKEN = "accessToken"
        static let MY_ACCESS_TOKEN = "Wr9cbNgN0Mh4xK0Pb1CD-bKuiar9Tn3i"
        static let ACCESS_TOKEN_SECRET = "accessTokenSecret"
        static let MY_ACCESS_SECRET = "RnpediRF8Xa1Pj65LESXMqR2f9g"
        
    }
    enum YelpRatingImages : Double {
        
        case OneStar = 1.0
        case OneOneHalfStars = 1.5
        case TwoStars = 2.0
        case TwoOneHalfStars = 2.5
        case ThreeStars = 3.0
        case ThreeOneHalfStars = 3.5
        case FourStars = 4.0
        case FourOneHalfStars = 4.5
        case FiveStars = 5

    }

}