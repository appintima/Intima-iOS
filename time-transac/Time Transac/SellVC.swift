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

class SellVC: UIViewController,  MGLMapViewDelegate, CLLocationManagerDelegate, STPPaymentContextDelegate, SHSearchBarDelegate {
    
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
    var pointAnnotations : [MGLPointAnnotation] = []
    var allAvailableJobs: [Job] = []
//    var newJob: Job?
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
        prepareViewButton()
        prepareMap()
        prepareSearchBar()
        

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    //Prepares the map by adding annotations for jobs from firebase, and setting the mapview.
    @objc func prepareMap(){
        
        service.getJobFromFirebase { newJobs, annotations  in
            let annotationsWithoutCurrentUser = annotations
            self.MapView.addAnnotations(annotationsWithoutCurrentUser)
            self.allAvailableJobs = newJobs

            self.MapView.addAnnotations(annotationsWithoutCurrentUser)
        }//end of closure
    }
    
    func prepareSearchBar(){
    
        let searchGlassIconTemplate = UIImage(named: "icon-search")!.withRenderingMode(.alwaysTemplate)
        let leftView1 = imageViewWithIcon(searchGlassIconTemplate, rasterSize: rasterSize)
        searchBar = defaultSearchBar(withRasterSize: rasterSize, leftView: leftView1, rightView: nil, delegate: self)
        view.addSubview(searchBar)
        self.setupLayoutConstraints()

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
    
    //When submit is pressed after the job price form
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
            let locationServicesPopup = PopupDialog(title: "Error", message: "Please enable location services to allow us to determine the location for your job")
            self.present(locationServicesPopup, animated: true)
            print("Location not enabled")
            return
        }
        
    }
    
    //When you cancel the details, the view is animated here
    @IBAction func cancelDetailsPressed(_ sender: Any) {
        self.resetTextFields()
        jobDetailsConstraint.constant = 800
        UIView.animate(withDuration: 1, animations: {self.view.layoutIfNeeded()})
        postJobButton.isHidden = false
    }
    
    //When you cancel price by pressing back, the view is animated here
    @IBAction func cancelPricePressed(_ sender: Any) {

        jobPriceViewConstraint.constant = 1600
        UIView.animate(withDuration: 1.5, animations: {self.view.layoutIfNeeded()})
        jobDetailsConstraint.constant = 77
        UIView.animate(withDuration: 2, animations: {self.view.layoutIfNeeded()})
        
    }
    
    //Loads the bouncing animation for the map annotation
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
    
    
    //Search feature to filter jobs by title, needs additional work to be used properly
    func searchBarDidEndEditing(_ searchBar: SHSearchBar) {
        let searchText = searchBar.text
        if !(searchText?.isEmpty)!{
            for job in allAvailableJobs {
                if (job.title.lowercased().range(of: searchText!.lowercased()) != nil) {
                    print("Found a job")
                }
            }
        }
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
        for Job in allAvailableJobs{
            if Job.title == annotation.title!!{
                rating = CGFloat(Job.jobOwnerRating/5)
            }
        }
        ratingAnimation.play(toProgress: rating, withCompletion: nil)
        return animation
    }
    
    
    //Loads a button for pressing on a job annotations to display more information
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }
    
    //Loads logic for what happens when the button to display more inforamation is pressed
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        
        for Job in allAvailableJobs{
            if Job.title == annotation.title!!{
                let popup = self.prepareAndShowPopup(job: Job)
                self.present(popup, animated: true, completion: nil)
            }
        }
    }
    
    //Prepares a snackbar for when a job has been successfully posted and paid for
    @objc func prepareSnackbarForJobPost() {
        guard let snackbar2 = snackbarController?.snackbar else {
            return
        }
        snackbar2.text = "Your Job has been successfully posted"
    }
    
    //Prepares a snackbar for when a job has been accepted by a user
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
            
            //Attempt to charge a payment
            self.submitJobButton.isHidden = true
            MyAPIClient.sharedClient.completeCharge(amount: priceForStripe, completion: { charge_id in
                //If no error when paying
                if charge_id != nil{
                    self.service.addJobToFirebase(jobTitle: self.jobTitleTF.text!, jobDetails: self.jobDetailsTF.text!, pricePerHour: self.pricePerHour.text!, numberOfHours: self.numberOfHoursTF.text!, locationCoord: self.currentLocation, chargeID: charge_id!)
                    
                    self.jobPriceViewConstraint.constant = 1600
                    UIView.animate(withDuration: 1, animations: {self.view.layoutIfNeeded()})
                    self.postJobButton.isHidden = false
                    self.resetTextFields()
                    self.prepareSnackbarForJobPost()
                    self.animateSnackbar()
                    print("Sucessfully posted job")
                    self.submitJobButton.isHidden = true
                }
                //If error when paying
                else{
                    let errorPopup = PopupDialog(title: "Error processing payment.", message:"Your payment method has failed, or none has been added. Please check your payment methods by tapping on the menu, and selecting payment methods.")
                    self.present(errorPopup, animated: true)
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
                })
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "acceptedNotification"), object: nil)
                self.prepareSnackbar()
                self.animateSnackbar()
                
            }
            print("Accepted Job")
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
    
}

extension SellVC: Constrainable {
    
    func setupLayoutConstraints() {
        let searchbarHeight: CGFloat = 44.0
        
        // Deactivate old constraints
        viewConstraints?.forEach { $0.isActive = false }
        
        let constraints = [
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            searchBar.leadingAnchor.constraint(equalTo:
                view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
            searchBar.heightAnchor.constraint(equalToConstant: searchbarHeight),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        if viewConstraints != nil {
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
        
        viewConstraints = constraints
    }
}



// MARK: - Helper Functions
func defaultSearchBar(withRasterSize rasterSize: CGFloat, leftView: UIView?, rightView: UIView?, delegate: SHSearchBarDelegate, useCancelButton: Bool = false) -> SHSearchBar {
    var config = defaultSearchBarConfig(rasterSize)
    config.leftView = leftView
    config.rightView = rightView
    config.useCancelButton = useCancelButton
    
    if leftView != nil {
        config.leftViewMode = .always
    }
    
    if rightView != nil {
        config.rightViewMode = .unlessEditing
    }
    
    let bar = SHSearchBar(config: config)
    bar.delegate = delegate
    bar.placeholder = NSLocalizedString("Filter Jobs", comment: "")
    bar.updateBackgroundImage(withRadius: 6, corners: [.allCorners], color: UIColor.white)
    bar.layer.shadowColor = UIColor.black.cgColor
    bar.layer.shadowOffset = CGSize(width: 0, height: 3)
    bar.layer.shadowRadius = 5
    bar.layer.shadowOpacity = 0.25
    return bar
}

func defaultSearchBarConfig(_ rasterSize: CGFloat) -> SHSearchBarConfig {
    var config: SHSearchBarConfig = SHSearchBarConfig()
    config.rasterSize = rasterSize
    config.textAttributes = [.foregroundColor : UIColor.gray]
    return config
}

func imageViewWithIcon(_ icon: UIImage, rasterSize: CGFloat) -> UIImageView {
    let imgView = UIImageView(image: icon)
    imgView.frame = CGRect(x: 0, y: 0, width: icon.size.width + rasterSize * 2.0, height: icon.size.height)
    imgView.contentMode = .center
    imgView.tintColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1)
    return imgView
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



