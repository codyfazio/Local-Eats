//
//  CustomCollectionCells.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/30/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

class YelpCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var restaurantNameLabel: UILabel!
    
    @IBOutlet weak var moreInfoButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var yelpRatingView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}