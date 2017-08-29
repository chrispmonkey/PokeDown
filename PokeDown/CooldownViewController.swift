//
//  CooldownViewController.swift
//  PokeDown
//
//  Created by Christopher Price on 8/23/17.
//  Copyright © 2017 Christopher L. Price. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class CooldownViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var startLocationTextField: UITextField!
    @IBOutlet weak var endLocationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var timeToWaitLabel: UILabel!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startLocationTextField.text = "36.206,-115.254"
        endLocationTextField.text = "36.16692,-115.08649"
        
        mapView.delegate = self
        
        // 2
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // 3
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
        /*
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        */
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5
        
        return renderer
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func calculateTimeToWaitButtonPressed(_ sender: Any) {
        var newLocOne = startLocationTextField.text?.components(separatedBy: ",")
        var newLocTwo = endLocationTextField.text?.components(separatedBy: ",")
        
        print(newLocOne ?? "N/A")
        print(newLocTwo ?? "N/A")
        
        let coordinate₀ = CLLocation(latitude: Double(newLocOne![0])!, longitude: Double(newLocOne![1])!)
        let coordinate₁ = CLLocation(latitude: Double(newLocTwo![0])!, longitude: Double(newLocTwo![1])!)
        
        print(coordinate₀)
        print(coordinate₁)
        
        let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
        print(distanceInMeters)
        
        let distanceInKilometers = distanceInMeters/1000
        print(distanceInKilometers)
        
        let timeToWait = (distanceInKilometers/96.56)*60
        print(timeToWait)
        if (timeToWait >= 180){
            timeToWaitLabel.text = String(format: "~2 Hours", timeToWait)
        }else{
            timeToWaitLabel.text = String(format: "~%.2f Minutes", timeToWait)
        }
        calculateMapDirection(start: coordinate₀, finish: coordinate₁)
    }
    
    func calculateMapDirection(start: CLLocation, finish:CLLocation){
        let sourceCoordinates = start.coordinate//locationManager.location?.coordinate
        let destinationCoordinates = finish.coordinate//CLLocationCoordinate2DMake(36.16692, -115.08649)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request:directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            
            guard let response = response else
            {
                if let error = error {
                    print("Something went wrong: %@", error)
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let rekt = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
        })
    }
    @IBAction func copyFinishLocationToClipboardLongPressDetected(_ sender: Any) {
        UIPasteboard.general.string = endLocationTextField.text
        print("End location text copied")
    }
    
    @IBAction func viewTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
