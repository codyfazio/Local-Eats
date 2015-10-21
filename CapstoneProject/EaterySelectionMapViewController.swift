//
//  EaterySelectionMapViewController.swift
//  CapstoneProject
//
//  Created by Cody Fazio on 9/3/15.
//  Copyright (c) 2015 Cody Fazio. All rights reserved.
//

import Foundation
import UIKit
import MapKit

//Create protocol for passing back the eatery for a Journal Entry
protocol EaterySelectionDelegate {
    func passEatery(eatery: Eatery) -> Void
}

//Used to allow the user to select an eatery either via search or by tapping an annotation
class EaterySelectionMapViewController : UIViewController, MKMapViewDelegate, UISearchBarDelegate  {
    
    //Create necessary connection in storyboard
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarButton: UIBarButtonItem!

    //Create variables
    var delegate : EaterySelectionDelegate?
    var yelpItems : [Eatery]?
    var currentFoodItem : Food?
    var localSearchRequest : MKLocalSearchRequest?
    var localSearch : MKLocalSearch?
    var searchTerm : String?
    var searchRegion : MKCoordinateRegion?
    var searchResultsController = UISearchController()
    var annotations : [MKAnnotation]?
 
    //Lifecycle
    override func viewDidLoad() {
       
        navigationController?.toolbarHidden = true 
        searchTerm = currentFoodItem!.name
        mapView.delegate = self

        //UISearchController
        self.searchResultsController = ({
            
            let controller = UISearchController(searchResultsController: nil)
           
                controller.searchBar.delegate = self
                controller.dimsBackgroundDuringPresentation = false
                controller.hidesNavigationBarDuringPresentation = false
                controller.searchBar.sizeToFit()
                self.navigationItem.backBarButtonItem?.title = "Back"
                self.navigationItem.titleView = controller.searchBar
                
                return controller
            }) ()

        let searchRadius = Double(currentFoodItem!.regionRadius)
        searchRegion = MKCoordinateRegionMakeWithDistance(currentFoodItem!.location.coordinate, searchRadius, searchRadius)
    }
    
    //Lifecycle
    override func viewWillAppear(animated: Bool) {
        updateMapWithYelpResultsForFoodType(nil)
    }
  
    //UISearchController Protocol
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        
        //Hide the keyboard
        searchBar.resignFirstResponder()
        
        //Clear the map
        if self.mapView.annotations.count != 0 {
            self.mapView.removeAnnotations(annotations!)
        }
        
        //Get the searchTerm from the searchBar and perform the search
        searchTerm = searchBar.text
        searchForSpecificEatery()
    }
    
    //UISearchController Protocol
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        //Reload the map with original pins
        searchTerm = currentFoodItem?.name
        updateMapWithYelpResultsForFoodType(nil)
    }
    
    //MapView DataSource
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) 
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //MapView Delegate
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotationTitle = annotationView.annotation!.title!
 
        for item in self.yelpItems! {
            if (item.name == annotationTitle) {
                if control == annotationView.rightCalloutAccessoryView {
                    delegate?.passEatery(item)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    //Get eateries and update the map
    func updateMapWithYelpResultsForFoodType(newCoordinate: CLLocationCoordinate2D?){
        
        YelpClient.sharedInstance().getEateriesForMapView(currentFoodItem!) {success, error, yelpResults in
            if success {
                //Clear the map and empty our arrays
                self.yelpItems?.removeAll(keepCapacity: false)
                
                if self.annotations != nil {
                    self.mapView.removeAnnotations(self.annotations!)
                }
                self.annotations?.removeAll(keepCapacity: false)
                
                //Fill the arrays with new data
                self.yelpItems = yelpResults
                self.annotations = CapstoneProjectConvenience.sharedInstance().buildAnnotations(self.yelpItems!)
                
                //Show the new pins
                self.mapView.showAnnotations(self.annotations!, animated: true)

            } else {
                //TODO: Error handling
            }
        }
        
    }
    
    //Update the map with search results for a specific location
    func searchForSpecificEatery() {
        CapstoneProjectConvenience.sharedInstance().performSearchForEateries(searchTerm!, mapRegion: self.mapView.region) {success, error, eateries in
            if success {
                
                //Clear the map and empty our arrays
                self.yelpItems?.removeAll(keepCapacity: false)
                
                //Fill the arrays with new data
                self.yelpItems = eateries
                self.annotations = CapstoneProjectConvenience.sharedInstance().buildAnnotations(self.yelpItems!)
                
                //Show the new pins
                self.mapView.addAnnotations(self.annotations!)
                
            } else {
                CapstoneProjectConvenience.sharedInstance().displayAlert("No eatery found.", message: "We couldn't find any restaurant with that name. Try another!", controller: self, activityIndicator: nil)
            }
        }
    }
}

