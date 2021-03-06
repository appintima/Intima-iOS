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
import SHSearchBar
import Kingfisher
import NotificationBannerSwift
import ISHPullUp


class SellVC: UIViewController,  MGLMapViewDelegate, CLLocationManagerDelegate, STPPaymentContextDelegate, SHSearchBarDelegate, ISHPullUpContentDelegate {

    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var scheduleJob: TextField!
    @IBOutlet weak var submitJobButton: RaisedButton!
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
    var rasterSize: CGFloat = 11.0
    var viewConstraints: [NSLayoutConstraint]?
    let cardHeight: CGFloat = 600
    let cardWidth: CGFloat = 300
    var yPosition:CGFloat = 45
    var scrollViewContentSize: CGFloat = 0
    var dbRef: DatabaseReference!
    var pointAnnotations : [CustomMGLAnnotation] = []
    var allAvailableJobs: [Job] = []
    var acceptedJob: Job!
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
    var searchBar: SHSearchBar!
    var latestAccepted:Job!
    var applicantEHash:String!
    let pulseAnimation = LOTAnimationView(name: "pulse_loader")
    var filteredJobs: [MGLPointAnnotation] = []
    var allAnnotations: [String:CustomMGLAnnotation]!
    
    var applicantInfo: [String:AnyObject]!
    let postedJobAnimation = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let check = LOTAnimationView(name: "check")
    

    
    
    ////////////////////////Functions associated with the controller go here//////////////////////////
    
    override func viewDidLoad() {
       
        self.MapView.delegate = self
        MapView.compassView.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        prepareCancelButtons()
        dbRef = Database.database().reference()
        self.hideKeyboardWhenTappedAround()
        prepareTitleTextField()
        preparePostJobButton()
        useCurrentLocations()
        prepareJobForm()
        if #available(iOS 11.0, *) {
            MapView.preservesSuperviewLayoutMargins = false
        } else {
            MapView.preservesSuperviewLayoutMargins = true
        }
        self.prepareSearchBar()
        self.prepareBannerLeftView()

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    

    @IBAction func buttonPressedForProfile(_ sender: UIButton) {

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfileToCancel"{
            if let dest = segue.destination as? ConfirmProfilePageVC{
                dest.applicantInfo = self.applicantInfo
                
            }
        }
        
        if segue.identifier == "goToStartJob"{
            if let dest = segue.destination as? StartJobNavigation{
                dest.job = self.acceptedJob
            }
        }
        
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
        self.navigationController?.navigationBar.isHidden = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.prepareMap()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    

    //When the postJob red button is pressed
    @IBAction func postJobPressed(_ sender: Any) {
        self.postJobButton.isHidden = true
        self.jobDetailsConstraint.constant = 77
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
    
    //When submit is pressed after the job price form
    @IBAction func submitJob(_ sender: Any) {//Check
        
        if (CLLocationManager.locationServicesEnabled()){
            if (pricePerHour.text == "" || numberOfHoursTF.text == "" || jobTitleTF.text == "" ||
                jobDetailsTF.text == ""){
                return
            }
            else{   // add job things to firebase
                let popup = preparePopupForJobPosting(wage: pricePerHour.text!, time: numberOfHoursTF.text!)
                self.present(popup, animated: true, completion: nil)
            }
            
        }else{
            let locationServicesPopup = PopupDialog(title: "Error", message: "Please enable location services to allow us to determine the location for your job")
            self.present(locationServicesPopup, animated: true)
            print("Location not enabled")
            return
        }
        
    }
    
    //When you cancel the details, the view is animated here
    @IBAction func cancelDetailsPressed(_ sender: Any) {
        
        jobDetailsConstraint.constant = 800
        UIView.animate(withDuration: 1, animations: {self.view.layoutIfNeeded()})
        postJobButton.isHidden = false
        self.resetTextFields()
    }
    
    //When you cancel price by pressing back, the view is animated here
    @IBAction func cancelPricePressed(_ sender: Any) {

        jobPriceViewConstraint.constant = 1600
        UIView.animate(withDuration: 1.5, animations: {self.view.layoutIfNeeded()})
        jobDetailsConstraint.constant = 77
        UIView.animate(withDuration: 2, animations: {self.view.layoutIfNeeded()})
        
    }
    

    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        
        if let anno = annotation as? CustomMGLAnnotation{
            let popup = self.prepareAndShowPopup(job: anno.job!)
            self.present(popup, animated: true, completion: nil)
        }
        
    }
    
    //Loads the bouncing animation for the map annotation
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        let annotationView = CustomAnnotationView()
        annotationView.frame = CGRect(x: 0, y: 0, width: 35, height: 35 )
        let locationAnimation = annotationView.returnHandledAnimationScaleToFill(filename: "bouncy_mapmaker", subView: annotationView, tagNum: 1)
        locationAnimation.loopAnimation = true
        annotationView.addSubview(locationAnimation)
        locationAnimation.play()
        annotationView.isUserInteractionEnabled = true
        return annotationView
    }
    
    
    //Search feature to filter jobs by title, needs additional work to be used properly
//    func searchBarDidEndEditing(_ searchBar: SHSearchBar) {
//        let searchText = searchBar.text
//        if !(searchText?.isEmpty)!{
//            for j in allAvailableJobs {
//                if (j.title.lowercased().range(of: searchText!.lowercased()) != nil) {
//
//                    let point = CustomMGLAnnotation()
//                    point.coordinate = j.location.coordinate
//                    point.title = j.title
//                    point.subtitle = ("$"+"\(j.wage_per_hour)"+"/Hour")
//                    filteredJobs.append(point)
//                }
//            }
//            print("Runs code")
//            self.MapView.removeAnnotations(pointAnnotations)
//            self.MapView.addAnnotations(filteredJobs)
//        }
//    }
    
    func searchBar(_ searchBar: SHSearchBar, textDidChange text: String) {
        if searchBar.text!.isEmpty{
            if self.MapView.annotations == nil{
                let annArr = Array(self.allAnnotations.values)
                self.MapView.addAnnotations(annArr)
            }
        }
        else{
            let allannos = self.MapView.annotations
            if allannos != nil{
                self.MapView.removeAnnotations(allannos!)
            }
            var searchAnnos:[CustomMGLAnnotation] = []
            let annArr = Array(self.allAnnotations.values)

            for anno in annArr{
                if (anno.title?.lowercased().range(of: searchBar.text!.lowercased()) != nil){
                    searchAnnos.append(anno)
                }
            }
            self.MapView.addAnnotations(searchAnnos)
        
        }
    }
    
    func searchBarShouldClear(_ searchBar: SHSearchBar) -> Bool {
        self.MapView.removeAnnotations(filteredJobs)
        self.MapView.addAnnotations(pointAnnotations)

        return true
    }
    
    //Prepares custom textfields for the job form
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
        self.jobDetailsTF.placeholder = "Enter a job description; here is where you can be clear and concise with the full details of your job"
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
        self.scheduleJob.font = UIFont(name: "Century Gothic", size: 17)
        self.scheduleJob.textColor = Color.white
        self.scheduleJob.placeholderActiveColor = Color.white
        self.scheduleJob.detailColor = Color.white
        self.scheduleJob.placeholderNormalColor = Color.white
    }
    
    
    //Prepares the post job button
    func preparePostJobButton(){
        postJobButton.image = Icon.cm.pen
        postJobButton.cornerRadius = postJobButton.frame.height/2
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    //Loads a rating animation using the users rating, and puts this when the map annotation is clicked
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        
        let animation = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        let ratingAnimation = LOTAnimationView(name: "5_stars")
        animation.handledAnimation(Animation: ratingAnimation)
        var rating = CGFloat(0)
        
        if let anno = annotation as? CustomMGLAnnotation{
            rating = CGFloat((anno.job?.jobOwnerRating)!/5)
        }        
        ratingAnimation.play(toProgress: rating, withCompletion: nil)
        return animation
    }
    
/**
    //Loads an animation
 */
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        let picture = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        picture.cornerRadius = picture.frame.height/2
        
        if let anno = annotation as? CustomMGLAnnotation{
            if let profilePic = anno.job?.jobOwnerPhotoURL{
                picture.kf.setImage(with: profilePic)
            }
            else{
                print("default pic")
                picture.image = #imageLiteral(resourceName: "emptyProfilePicture")
            }
        }
        return picture
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
            
            //Attempt to charge a payment
            self.submitJobButton.isHidden = true
            //LoadingAnimation initialize and play
            MyAPIClient.sharedClient.completeCharge(amount: priceForStripe, completion: { charge_id in
                //If no error when paying
                if charge_id != nil{
                    //
                    self.service.addJobToFirebase(jobTitle: self.jobTitleTF.text!, jobDetails: self.jobDetailsTF.text!, pricePerHour: self.pricePerHour.text!, numberOfHours: self.numberOfHoursTF.text!, locationCoord: self.currentLocation, chargeID: charge_id!)
                    
                    self.jobPriceViewConstraint.constant = 1600
                    UIView.animate(withDuration: 1, animations: {self.view.layoutIfNeeded()})
                    self.postJobButton.isHidden = false
                    self.resetTextFields()
                    self.prepareBannerForPost()
                    print("Sucessfully posted job")
                    self.submitJobButton.isHidden = false
                    
                    return
                }
                //If error when paying
                else{
                    let errorPopup = PopupDialog(title: "Error processing payment.", message:"Your payment method has failed, or none has been added. Please check your payment methods by tapping on the menu, and selecting payment methods.")
                    self.present(errorPopup, animated: true, completion: {
                        self.submitJobButton.isHidden = false
                    })
                    return
                }
            })
        }

        let cancelButton = CancelButton(title: "Cancel") {
            print("Job cancelled")
        }
        popup.addButtons([continueButton,cancelButton])
        return popup
    }
    
    
    func prepareBannerForAccept(){
        
        let banner = NotificationBanner(title: "Accepted", subtitle: "Awaiting confirmation from job owner", leftView: postedJobAnimation, style: .success)
        banner.show()
        check.play()
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
                let body = "Your Job Has Been Accepted By \(Auth.auth().currentUser?.displayName)" ?? "someone"
                let device = deviceToken
                var headers: HTTPHeaders = HTTPHeaders()
                self.acceptedJob = job
                headers = ["Content-Type":"application/json", "Authorization":"key=\(AppDelegate.SERVERKEY)"]
                
                let notification = ["to":"\(device)", "notification":["body":body, "title":title, "badge":1, "sound":"default"]] as [String : Any]
                
                Alamofire.request(AppDelegate.NOTIFICATION_URL as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                    
                    if let err = response.error{
                        print(err.localizedDescription)
                    }else{
                        self.performSegue(withIdentifier: "goToStartJob", sender: nil)
                    }

                })
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "acceptedNotification"), object: nil)
                
                
            }
            print("Accepted Job")
            self.prepareBannerForAccept()
        }
        popup.addButtons([buttonTwo, buttonOne])
        return popup
    }
    
    //Resets text fields on job form after it is no longer needed.
    func resetTextFields(){
        pricePerHour.text! = ""
        numberOfHoursTF.text = ""
        jobTitleTF.text = ""
        jobDetailsTF.text = ""
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forContentViewController contentVC: UIViewController) {
        
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = edgeInsets
            rootView.layoutMargins = .zero
        } else {
            // update edgeInsets
            rootView.layoutMargins = edgeInsets
        }
        
        // call layoutIfNeeded right away to participate in animations
        // this method may be called from within animation blocks
        rootView.layoutIfNeeded()
    }
    
    
}


