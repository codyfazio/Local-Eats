//
//  CustomTableCells.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 8/26/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit

class NearMeFoodCell : UITableViewCell {
    
    @IBOutlet weak var foodCellName: UILabel!
    @IBOutlet weak var foodCellRegion: UILabel!
    @IBOutlet weak var nearMeRatingImageView: UIImageView!
    @IBOutlet weak var nearMeRatingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}

class LocalFoodCell : UITableViewCell {
    
    @IBOutlet weak var localFoodCellName: UILabel!
    @IBOutlet weak var localFoodCellRegion: UILabel!
    @IBOutlet weak var localFoodRatingImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}

class JournalEntryFoodTypeCell : UITableViewCell {
    
    @IBOutlet weak var journalEntryFoodTypeCellPhotoView: UIImageView!
    @IBOutlet weak var journalEntryFoodTypeCellNameLabel: UILabel!
    @IBOutlet weak var journalEntryFoodTypeCellRegionLabel: UILabel!
}

