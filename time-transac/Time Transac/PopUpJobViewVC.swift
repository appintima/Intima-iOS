//
//  PopUpJobViewVC.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 10/10/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Lottie
import MapKit
import Firebase
import Alamofire
import Material


class PopUpJobViewVC: UIView, CLLocationManagerDelegate {
    
    @IBOutlet weak var hireButton: FlatButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var rating: UIView!
    
    var job: Job!
    var jobLocationStr: String!
    
    private let service: ServiceCalls = ServiceCalls()
    
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        print(job.jobOwnerRating)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        acceptButton.addTarget(self, action: #selector(accept), for: .touchUpInside)
        
    }
    
    @objc func accept(){
        service.acceptPressed(job: self.job, user: Auth.auth().currentUser!) { (deviceToken) in
            let title = "Intima"
            let body = "Your Job Has Been Accepted By \(Auth.auth().currentUser?.displayName ?? "someone")"
            let device = deviceToken
            var headers: HTTPHeaders = HTTPHeaders()
            
            headers = ["Content-Type":"application/json", "Authorization":"key=\(AppDelegate.SERVERKEY)"]
            
            let notification = ["to":"\(device)", "notification":["body":body, "title":title, "badge":1, "sound":"default"]] as [String : Any]
            
            Alamofire.request(AppDelegate.NOTIFICATION_URL as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                print(response)
            })
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "acceptedNotification"), object: nil)
            self.acceptButton.isHidden = true
            
        }
    }
    
    func nameOfFunction(notif: NSNotification) {
        //Insert code here
    }
    
    func parseAddress(placemark: MKPlacemark)->String {
        // put space btween 25 and martha
        let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil) && (placemark.subAdministrativeArea != nil || placemark.administrativeArea != nil) ? ", " : ""
        
        //put a space between "New" and "Brunswick"
        let secondSpace = (placemark.subAdministrativeArea != nil && placemark.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            //street num
            placemark.subThoroughfare ?? "",
            firstSpace,
            //street name
            placemark.thoroughfare ?? "",
            comma,
            //city
            placemark.locality ?? "",
            secondSpace,
            //state
            placemark.administrativeArea ?? ""
        )
        return addressLine
    }
    
    
    func dropPin(placemark: MKPlacemark){
        //store pin for later
        locPlacemark = placemark
        
        self.map.removeAnnotations(self.map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.subtitle = parseAddress(placemark: placemark)
        
        map.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        self.map.setRegion(region, animated: false)
    }
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        CLGeocoder().reverseGeocodeLocation(self.job.location) { (placemarks, error) in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            if let placemark = placemarks?.first{
                let mark = MKPlacemark(placemark: placemark)
                self.dropPin(placemark: mark)
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}


extension PopUpJobViewVC: MKMapViewDelegate{

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        var pinView = self.map.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.purple
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(), size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car") , for: .normal)
        button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
        
    }
    
    
    @objc func getDirections(){
        if let selectedPin = locPlacemark{
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
}






