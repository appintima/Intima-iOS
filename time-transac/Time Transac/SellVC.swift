//
//  SellVC02.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-07-19.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Firebase
import Lottie
import CoreLocation
import Material
import FBSDKLoginKit
import Mapbox
import PopupDialog
import Alamofire
import Stripe


class SellVC: UIViewController,  MGLMapViewDelegate, CLLocationManagerDelegate, STPPaymentContextDelegate {
    
    @IBOutlet weak var jobDetailsView: UIView!
    @IBOutlet weak var jobPriceView: UIView!
    @IBOutlet weak var cancelPrice: RaisedButton!
    @IBOutlet weak var cancelDetails: RaisedButton!
    @IBOutlet weak var numberOfHoursTF: TextField!
    @IBOutlet weak var pricePerHour: TextField!
    @IBOutlet weak var jobPriceViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var jobDetailsTF: TextView!
    @IBOutlet weak var jobTitleTF: TextField!
    @IBOutlet weak var jobDetailsConstraint: NSLayoutConstraint!
    @IBOutlet weak var postJobButton: RaisedButton!
    @IBOutlet weak var MapView: MGLMapView!
    fileprivate var viewJobButton: FlatButton!
    let cardHeight: CGFloat = 600
    let cardWidth: CGFloat = 300
    var yPosition:CGFloat = 45
    var scrollViewContentSize: CGFloat = 0
    var dbRef: DatabaseReference!
    var pointAnnotations : [MGLPointAnnotation] = []
    var allAvailableJobs: [Job] = []
    var newJob: Job?
    var currentUser: User2!
    let service = ServiceCalls()
    var menuShowing = false
    var hamburgerAnimation: LOTAnimationView!
    var locationManager = CLLocationManager()
    let camera = MGLMapCamera()
    var currentLocation: CLLocationCoordinate2D!
    var paymentContext: STPPaymentContext? = nil
    let backendBaseURL: String? = "https://us-central1-intima-227c4.cloudfunctions.net/"
    let stripePublishableKey = "pk_test_K45gbx2IXkVSg4pfmoq9SIa9"
    let appleMerchantID: String? = nil
    let companyName = "Intima"
    var timer : Timer!
    
    
    ///////////////////////// Functions that enable stripe payments go here /////////////////////////////
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print(error)
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        let source = paymentResult.source.stripeID
        MyAPIClient.sharedClient.addPaymentSource(id: source, completion: { (error) in })
    }
    
    
    ////////////////////////Functions associated with the controller go here//////////////////////////
    
    override func viewDidLoad() {
        
        
        self.navigationController?.navigationBar.isHidden = true
        prepareCancelButtons()
        dbRef = Database.database().reference()
        self.hideKeyboardWhenTappedAround()
        prepareTitleTextField()
        self.navigationController?.navigationBar.isHidden = true
        postJobButton.image = Icon.cm.pen
        postJobButton.cornerRadius = postJobButton.frame.height/2
        useCurrentLocations()
        prepareJobForm()
        prepareViewButton()
        prepareMap()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    //Prepares the map by adding annotations for jobs from firebase, and setting the mapview.
    @objc func prepareMap(){
        self.MapView.delegate = self
        MapView.compassView.isHidden = true
        print("RELOADED")
        service.getJobFromFirebase { newJobs, annotations  in
            let annotationsWithoutCurrentUser = annotations
            self.MapView.addAnnotations(annotationsWithoutCurrentUser)
            self.allAvailableJobs = newJobs

            print(annotationsWithoutCurrentUser)
            self.MapView.addAnnotations(annotationsWithoutCurrentUser)
        }//end of closure
    }
    
    //Sets the camera for the mapview and sets current location to users current locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.camera.centerCoordinate = locValue
        self.camera.altitude = CLLocationDistance(12000)
        self.camera.pitch = CGFloat(60)
        self.MapView.setCamera(camera, animated: true)
        currentLocation = locValue
        manager.stopUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    //Any adjustments to job form visuals should be done here.
    func prepareJobForm() {
        self.jobDetailsView.cornerRadius = 7
        self.jobPriceView.cornerRadius = 7
    }
    
    //When the postJob red button is pressed
    @IBAction func postJobPressed(_ sender: Any) {
    
        postJobButton.isHidden = true
        jobDetailsConstraint.constant = 77
        UIView.animate(withDuration: 0.5, animations: {self.view.layoutIfNeeded()})
        
    }
    
    //When next is pressed on the Job details form
    @IBAction func nextPressedOnDetails(_ sender: Any) {
        
        if (!jobDetailsTF.isEmpty && !jobTitleTF.isEmpty ){
            jobDetailsConstraint.constant = 800
            UIView.animate(withDuration: 1, animations: {self.view.layoutIfNeeded()})
            jobPriceViewConstraint.constant = 77
            UIView.animate(withDuration: 2, animations: {self.view.layoutIfNeeded()})
            
        }
    }
    
    @IBAction func submitJob(_ sender: Any) {
        
        if (CLLocationManager.locationServicesEnabled()){
            if (pricePerHour.text == "" || numberOfHoursTF.text == "" || jobTitleTF.text == "" ||
                jobDetailsTF.text == ""){
                
                print("Empty fields, please check again")
                return
            }
                
            else{   // add job things to firebase
                
                let popup = preparePopupForJobPosting(wage: pricePerHour.text!, time: numberOfHoursTF.text!)
                self.present(popup, animated: true, completion: nil)
            }
            
        }
        else{
            print("Location not enabled")
            return
        }
        
    }
    @IBAction func cancelDetailsPressed(_ sender: Any) {
        self.resetTextFields()
        jobDetailsConstraint.constant = 800
        UIView.animate(withDuration: 1, animations: {self.view.layoutIfNeeded()})
        postJobButton.isHidden = false
    }
    
    @IBAction func cancelPricePressed(_ sender: Any) {

        jobPriceViewConstraint.constant = 1600
        UIView.animate(withDuration: 1.5, animations: {self.view.layoutIfNeeded()})
        jobDetailsConstraint.constant = 77
        UIView.animate(withDuration: 2, animations: {self.view.layoutIfNeeded()})
        
    }
    

    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        let annotationView = CustomAnnotationView()
        annotationView.frame = CGRect(x: 0, y: 0, width: 40, height: 40 )
        
        let locationAnimation = annotationView.returnHandledAnimationScaleToFill(filename: "bouncy_mapmaker", subView: annotationView, tagNum: 1)
        locationAnimation.loopAnimation = true
        annotationView.addSubview(locationAnimation)
        locationAnimation.play()
        annotationView.isUserInteractionEnabled = true
        return annotationView
    }
    
    func prepareTitleTextField(){
        
        self.pricePerHour.font = UIFont(name: "Century Gothic", size: 17)
        self.pricePerHour.textColor = Color.white
        self.pricePerHour.placeholderActiveColor = Color.white
        self.pricePerHour.detailColor = Color.white
        self.pricePerHour.placeholderNormalColor = Color.white
        self.numberOfHoursTF.font = UIFont(name: "Century Gothic", size: 17)
        self.numberOfHoursTF.textColor = Color.white
        self.numberOfHoursTF.placeholderActiveColor = Color.white
        self.numberOfHoursTF.detailColor = Color.white
        self.numberOfHoursTF.placeholderNormalColor = Color.white
        self.jobTitleTF.placeholderLabel.font = UIFont(name: "Century Gothic", size: 17)
        self.jobDetailsTF.placeholder = "Job description"
        self.jobDetailsTF.placeholderColor = Color.white
        self.jobDetailsTF.font = UIFont(name: "Century Gothic", size: 17)
        self.jobDetailsTF.textColor = Color.white
        self.jobTitleTF.font = UIFont(name: "Century Gothic", size: 17)
        self.jobTitleTF.textColor = Color.white
        self.jobTitleTF.placeholder = "Job Title"
        self.jobTitleTF.placeholderActiveColor = Color.white
        self.jobTitleTF.detailLabel.text = "A short title for your job"
        self.jobTitleTF.detailColor = Color.white
        self.jobTitleTF.placeholderNormalColor = Color.white
        
    }
    
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        
        let animation = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        let ratingAnimation = LOTAnimationView(name: "5_stars")
        animation.handledAnimation(Animation: ratingAnimation)
        var rating = CGFloat(0)
        for Job in allAvailableJobs{
            if Job.title == annotation.title!!{
                rating = CGFloat(Job.jobOwnerRating/5)
            }
            
        }
        ratingAnimation.play(toProgress: rating, withCompletion: nil)
        return animation
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }

    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        
        for Job in allAvailableJobs{
            if Job.title == annotation.title!!{
                let popup = self.prepareAndShowPopup(job: Job)
                self.present(popup, animated: true, completion: nil)
            }
        }
    }
    
    @objc func prepareSnackbarForJobPost() {
        guard let snackbar2 = snackbarController?.snackbar else {
            return
        }
        
        snackbar2.text = "Your Job has been successfully posted"
    }
    
    @objc func prepareSnackbar() {
        guard let snackbar = snackbarController?.snackbar else {
            return
        }
        
        snackbar.text = "Awaiting confirmation from Job owner"
        snackbar.rightViews = [viewJobButton]
    }
    
    @objc
    fileprivate func animateSnackbar() {
        guard let sc = snackbarController else {
            return
        }
        
        _ = sc.animate(snackbar: .visible, delay: 1)
        _ = sc.animate(snackbar: .hidden, delay: 4)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func useCurrentLocations(){
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func prepareCancelButtons(){
        self.cancelDetails.cornerRadius = self.cancelDetails.frame.height/2
        self.cancelPrice.cornerRadius = self.cancelPrice.frame.height/2
        self.cancelDetails.image = Icon.cm.clear
        self.cancelPrice.image = Icon.cm.arrowBack
    }
    
   
}

extension SellVC {
    
    func preparePopupForJobPosting(wage: String, time: String) -> PopupDialog{
        
        let price = (Double(wage )!)*(Double(time )!)
        let priceForStripe = Int(price*100)
        let title = "Post Job?"
        let message = "We will charge you " + "$" + "\(price)" + " for your job plus a $1.00 fee for the posting to avoid spam. You can cancel your job at anytime before it has been confirmed and begun, excluding the posting fee"
        
        let popup = PopupDialog(title: title, message: message)
        
        let continueButton = DefaultButton(title: "Continue", dismissOnTap: true) {
            MyAPIClient.sharedClient.completeCharge(amount: priceForStripe, completion: { (error) in
                if error != nil{
                    let errorPopup = PopupDialog(title: "Error processing payment.", message:"Your payment method has failed, or none has been added. Please check your payment methods by tapping on the menu, and selecting payment methods.")
                    self.present(errorPopup, animated: true)
                }
                else{
                    print("Sucessfully posted job")
                    
                    self.service.addJobToFirebase(jobTitle: self.jobTitleTF.text!, jobDetails: self.jobDetailsTF.text!, pricePerHour: self.pricePerHour.text!, numberOfHours: self.numberOfHoursTF.text!, locationCoord: self.currentLocation)
                    
                    self.jobPriceViewConstraint.constant = 1600
                    UIView.animate(withDuration: 1, animations: {self.view.layoutIfNeeded()})
                    self.postJobButton.isHidden = false
                    self.resetTextFields()
                    self.prepareSnackbarForJobPost()
                    self.animateSnackbar()
                }
            })
        }
        
        let cancelButton = CancelButton(title: "Cancel") {
            print("Job cancelled")
        }
        
        popup.addButtons([continueButton,cancelButton])
        
        return popup
    }
    
    
    func prepareAndShowPopup(job: Job) -> PopupDialog{
        
        
        // Prepare the popup assets
        let title = "Requirement: " + "\(job.maxTime)" + " Hours, for: " + "$" + "\(job.wage_per_hour)" + "/Hour"
        let message = job.description
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Cancel") {
            print("Job Cancelled")
        }
        
        let buttonTwo = DefaultButton(title: "Accept job", dismissOnTap: true) {
            self.service.acceptPressed(job: job, user: Auth.auth().currentUser!) { (deviceToken) in
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
                self.animateSnackbar()
                
            }
            print("Accepted Job")
        }
        
        let viewCandidatesButton = DefaultButton(title: "View users who accepted your job", dismissOnTap: true) {
            print("View Users")
        }
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        
        if job.jobOwnerEmailHash != self.service.MD5(string: (Auth.auth().currentUser?.email)!){
            popup.addButtons([buttonTwo, buttonOne])
        }
        
        else{
            popup.addButton(viewCandidatesButton)
        }
        
        
        return popup
    }
    

    func resetTextFields(){
        pricePerHour.text! = ""
        numberOfHoursTF.text = ""
        jobTitleTF.text = ""
        jobDetailsTF.text = ""
    }
    
}

extension SellVC {

    fileprivate func prepareViewButton() {
        viewJobButton = FlatButton(title: "View", titleColor: Color.yellow.base)
        viewJobButton.pulseAnimation = .backing
        viewJobButton.titleLabel?.font = snackbarController?.snackbar.textLabel.font
    }
    

    fileprivate func scheduleAnimation() {
        Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(animateSnackbar), userInfo: nil, repeats: false)
    }
}



