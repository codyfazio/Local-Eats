//
//  PhotoOperations.swift
//  
//
//  Created by Cody Fazio on 12/7/15.
//  Adapted from Ray Wenderlich tutorial on NSOperations
//  http://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift

import UIKit
import CloudKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case New, Downloaded, Failed
}

class PhotoRecord {
    let recordIDForPhotoDownload: CKRecordID
    //let url:NSURL
    var state = PhotoRecordState.New
    
    //TODO: Need a placeholder image here!!!
    var image = UIImage(named: "Placeholder")
    
    init(foodRecord:CKRecord) {
        self.recordIDForPhotoDownload = foodRecord.recordID
        //self.url = url
    }
}

class PendingOperations {
    lazy var downloadsInProgress = [NSIndexPath:NSOperation]()
    lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Download queue"
        //Leave this out to allow the OS to manage concurrency and improve performance
        //queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}

class ImageDownloader: NSOperation {
    
    let photoRecord: PhotoRecord
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        CloudKitClient.sharedInstance().fetchPhoto(photoRecord.recordIDForPhotoDownload) {photo, isUser in
            if photo != nil {
                self.photoRecord.image = photo
                self.photoRecord.state = .Downloaded

            }
            else
            {
                self.photoRecord.state = .Failed
                self.photoRecord.image = UIImage(named: "Failed")
            }
            
            
            if self.cancelled {
                return
            }
        }
    }
}
