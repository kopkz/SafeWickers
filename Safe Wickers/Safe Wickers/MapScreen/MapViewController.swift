//
//  MapViewController.swift
//  Safe Wickers
//
//  Created by 匡正 on 22/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var focusLocation: CLLocation?
    var beachList:[Beach] = []
    var beachAnnotations:[MKAnnotation] = []
    
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    
    func addNavBarImage() {
        let navController = navigationController!
        navigationController?.navigationBar.barTintColor = UIColor(red:0.27, green:0.45, blue:0.58, alpha:1)
        let image = UIImage(named: "titleLogo.png")
        let imageView = UIImageView(image: image)
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        navController.navigationBar.backItem?.title = "Back"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage()
        self.navigationController?.navigationBar.tintColor = UIColor.white

        // Do any additional setup after loading the view.
        showCusLocation()
        
        mapView.delegate = self
        mapView.register(myAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        centerMapOnLocation(location: focusLocation!)
        loadAnnotation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   // set up the map
    func showCusLocation()
    {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
    }
    
    // zoom the map to search region
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 20000, longitudinalMeters: 20000)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    // mark the beach in the location
    func loadAnnotation(){
        for beach in beachList {
            let beachAnnotation = myAnnotation(title: beach.beachName!, distance: beach.distance!, discipline: beach.descrip!, coordinate: CLLocationCoordinate2DMake(beach.latitude!, beach.longitude!), ifSafe: beach.risk!)
            beachAnnotations.append(beachAnnotation)
        }
        
        mapView.addAnnotations(beachAnnotations)
    }
//    // configue of annotattion
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        let reuseID = "beachAnnotation"
//        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
//        let rightButton: AnyObject! = UIButton(type: UIButton.ButtonType.detailDisclosure)
//        annotationView!.rightCalloutAccessoryView = rightButton as? UIView
//
//        return annotationView
//    }
    
    
    // go to beach detail screen
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "mapToBeachDetail", sender: view)
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToBeachDetail" {
            let destination = segue.destination as! BeachDetailViewController
            let beachTitle = (sender as! myAnnotationView).annotation?.title
            var seletedBeach: Beach?
            for beach in beachList {
                if beach.beachName == beachTitle{
                    seletedBeach = beach
                }
            }
            
            destination.beach = seletedBeach
        }
    }
    

}
