//
//  ViewController.swift
//  introMapKit
//
//  Created by Ios Dev on 20/07/2018.
//  Copyright © 2018 avchugunov. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addAnnotationButton: UIBarButtonItem!
    let regionRadius: CLLocationDistance = 1000
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        //allow user to pin
        let GR = UITapGestureRecognizer(target: self, action: #selector(self.tappedInMapVeiw(recognizer:)))
        GR.delegate = self
        mapView.addGestureRecognizer(GR)
        
        // show artwork on map
        let spinner = SpinnerView.displaySpinner(onView: self.view)
        uploadArtworks { (artworks) in
            DispatchQueue.main.async {
                SpinnerView.removeSpinnerView(spinner: spinner)
                var haveArtworks = false
                if let arts = artworks {
                    haveArtworks = arts.count > 0
                    for art in arts {
                        self.mapView.addAnnotation(art)
                    }
                }
                if haveArtworks {
                    let firstLoc = self.mapView.annotations.first!
                    self.centerMapOnLocation(location: CLLocation(latitude: firstLoc.coordinate.latitude, longitude: firstLoc.coordinate.longitude))
                }
                self.locationManager.requestWhenInUseAuthorization()
                // Ask for Authorisation from the User.
                if CLLocationManager.locationServicesEnabled() {
                    self.locationManager.delegate = self
                    //self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.locationManager.startUpdatingLocation()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func uploadArtworks(completion: @escaping ([Artwork]?) -> Void) {
        Alamofire.request("https://api.myjson.com/bins/15sy6i").responseJSON { (response) in
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            guard let value = response.result.value else {
                    return
            }
            print("Value: \(value)")
            let arts = JSON(value)["artworks"].array?.map({ (json) in
                Artwork(title: json["title"].stringValue, locationName: json["locationName"].stringValue, discipline: json["discipline"].stringValue, coordinate: CLLocationCoordinate2D(latitude: json["latitude"].doubleValue, longitude: json["longitude"].doubleValue), description: json["description"].stringValue)
            })
            completion(arts)
        }
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAnnotationIdentifier" {
            let navC = segue.destination as! UINavigationController
            let DVC = navC.topViewController as! AddAnnotationViewController
            print("last pin on prepare: \(String(describing: mapView.annotations.last!.title))       \(String(describing: mapView.annotations.last!.coordinate.latitude))")
            let lastPin = mapView.annotations.last!.coordinate
            DVC.coordinate = lastPin
        }
    }
    
    @IBAction func unwindToMainVC(segue: UIStoryboardSegue) {
        let sourceVC = segue.source as! AddAnnotationViewController
        if let newArtwork = sourceVC.newArtwork {
            print("last pin on unwind: \(String(describing: mapView.annotations.last!.title))       \(String(describing: mapView.annotations.last!.coordinate.latitude))")
            mapView.removeAnnotation(mapView.annotations.last!)
            mapView.addAnnotation(newArtwork)
            centerMapOnLocation(location: CLLocation(latitude: newArtwork.coordinate.latitude, longitude: newArtwork.coordinate.longitude))
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Artwork else { return nil }
        
        let identifier = "marker"
        var view:MKMarkerAnnotationView
        //var view:MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
        //if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            //view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.glyphText = "111"
            view.markerTintColor = UIColor.green
            view.glyphTintColor = UIColor.red
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            let pointVeiw = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//            pointVeiw.backgroundColor = UIColor.black
//            UIGraphicsBeginImageContextWithOptions(pointVeiw.bounds.size, pointVeiw.isOpaque, 0.0)
//            defer { UIGraphicsEndImageContext() }
//            if let context = UIGraphicsGetCurrentContext() {
//                pointVeiw.layer.render(in: context)
//                let image = UIGraphicsGetImageFromCurrentImageContext()
                //view.image = image
                //view.glyphImage = nil
            //}
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let userLoc = self.mapView.userLocation
        print("user loc: \(userLoc.coordinate.latitude); \(userLoc.coordinate.longitude)")
        let location = view.annotation as! Artwork
        let DVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailController") as! DetailViewController
        DVC.artwork = location
        self.navigationController?.pushViewController(DVC, animated: true)
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update locations")
        if let firstLoc = locations.first {
            if mapView.annotations.count == 0 {
                self.centerMapOnLocation(location: CLLocation(latitude: firstLoc.coordinate.latitude, longitude: firstLoc.coordinate.longitude))
            }
        }
        locationManager.startUpdatingLocation()
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    @IBAction func tappedInMapVeiw(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}

