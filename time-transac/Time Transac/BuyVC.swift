//
//  BuyVC02.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-07-19.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import Pastel
import Material

class BuyVC: UIViewController{
    
    var coreLocation = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var isLocationEnabled: Bool!
    

    @IBOutlet weak var jobPriceView: UIView!
    @IBOutlet weak var jobPriceConstraint: NSLayoutConstraint!
    @IBOutlet weak var jobDetailConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientView: PastelView!
    @IBOutlet weak var priceTF: TextField!
    @IBOutlet weak var timeTF: TextField!
    @IBOutlet weak var jobDetailsView: UIView!
    @IBOutlet weak var jobTitleTF: TextField!
    @IBOutlet weak var jobDescriptionTF: TextView!
    fileprivate var undoButton: FlatButton!
    var currentLocation: CLLocation!
    var dbRef: DatabaseReference!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareTabItem()
        prepareUndoButton()
        self.navigationController?.navigationBar.isHidden = false
        self.hideKeyboardWhenTappedAround()
        self.jobPriceView.ApplyCornerRadiusToView()
        self.jobPriceView.ApplyCornerRadiusToView()
        self.jobDetailsView.ApplyOuterShadowToView()
        self.jobDetailsView.ApplyCornerRadiusToView()
        prepareTitleTextField()
        self.navigationController?.navigationBar.isHidden = true
        self.gradientView.setColors([#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1),#colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)])
        self.gradientView.animationDuration = 3.0
        dbRef = Database.database().reference()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        coreLocation.delegate = self
        coreLocation.startUpdatingLocation()
        coreLocation.desiredAccuracy = kCLLocationAccuracyBest
        coreLocation.requestWhenInUseAuthorization()
        coreLocation.requestLocation()
        super.viewDidAppear(animated)
        self.gradientView.startAnimation()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        coreLocation.stopUpdatingLocation()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedNext(_ sender: UIButton) {
        
        if (!jobDescriptionTF.isEmpty && !jobTitleTF.isEmpty ){
            jobDetailConstraint.constant = -800
            UIView.animate(withDuration: 1, animations: {self.view.layoutIfNeeded()})
            jobPriceConstraint.constant = 77
            UIView.animate(withDuration: 2, animations: {self.view.layoutIfNeeded()})
            
        }
    }
    
    
    func resetTextFields(){
        priceTF.text! = ""
        timeTF.text = ""
        jobTitleTF.text = ""
        jobDescriptionTF.text = ""
    }
    
    func prepareTitleTextField(){
        
        self.priceTF.font = UIFont(name: "Century Gothic", size: 17)
        self.priceTF.textColor = Color.white
        self.priceTF.placeholderActiveColor = Color.white
        self.priceTF.detailColor = Color.white
        self.priceTF.placeholderNormalColor = Color.white
        self.timeTF.font = UIFont(name: "Century Gothic", size: 17)
        self.timeTF.textColor = Color.white
        self.timeTF.placeholderActiveColor = Color.white
        self.timeTF.detailColor = Color.white
        self.timeTF.placeholderNormalColor = Color.white
        self.jobTitleTF.placeholderLabel.font = UIFont(name: "Century Gothic", size: 17)
        self.jobDescriptionTF.placeholder = "Job description"
        self.jobDescriptionTF.placeholderColor = Color.white
        self.jobDescriptionTF.font = UIFont(name: "Century Gothic", size: 17)
        self.jobDescriptionTF.textColor = Color.white
        self.jobTitleTF.font = UIFont(name: "Century Gothic", size: 17)
        self.jobTitleTF.textColor = Color.white
        self.jobTitleTF.placeholder = "Job Title"
        self.jobTitleTF.placeholderActiveColor = Color.white
        self.jobTitleTF.detailLabel.text = "A short title for your job"
        self.jobTitleTF.detailColor = Color.white
        self.jobTitleTF.placeholderNormalColor = Color.white
        

    }
    
    
    
    @IBAction func buyTimeButton(_ sender: UIButton) {
        if (CLLocationManager.locationServicesEnabled()){
            if (priceTF.text == "" || timeTF.text == "" || jobTitleTF.text == "" ||
                jobDescriptionTF.text == ""){
            
                ERR_Empty_Fields()
                return
            }
        
            else{   // add job things to firebase
            
//                self.addJobToFirebase()
                
                jobPriceConstraint.constant = 800
                print(jobPriceConstraint.constant)
                UIView.animate(withDuration: 1, animations: {self.view.layoutIfNeeded()})
                self.jobDetailConstraint.constant = 77
                UIView.animate(withDuration: 2, animations: {self.view.layoutIfNeeded()})
                prepareSnackbar()
                animateSnackbar()
            }
            
        }
        else{
            ERR_No_Location()
            return
        }
        resetTextFields()
    }
    

    func MD5(string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }

    
    
    func addJobToFirebase(){
        
        let newJobID = self.dbRef.child("AllJobs").childByAutoId().key
        let jobOwnerEmailHash = MD5(string: (Auth.auth().currentUser?.email)!)
        let latitude = self.currentLocation.coordinate.latitude
        let longitude = self.currentLocation.coordinate.longitude
        
        
        self.dbRef.child("AllJobs").child(newJobID).child("longitude").setValue(longitude)
        self.dbRef.child("AllJobs").child(newJobID).child("latitude").setValue(latitude)
        self.dbRef.child("AllJobs").child(newJobID).child("JobOwner").setValue(jobOwnerEmailHash)
        self.dbRef.child("AllJobs").child(newJobID).child("JobTitle").setValue(jobTitleTF.text!)
        self.dbRef.child("AllJobs").child(newJobID).child("JobDescription").setValue(jobDescriptionTF.text!)
        self.dbRef.child("AllJobs").child(newJobID).child("Price").setValue("\(priceTF.text!)")
        self.dbRef.child("AllJobs").child(newJobID).child("Time").setValue("\(timeTF.text!)")
        self.dbRef.child("AllJobs").child(newJobID).child("isOccupied").setValue(false)
        self.dbRef.child("AllJobs").child(newJobID).child("isCompleted").setValue(false)
        self.dbRef.child("AllJobs").child(newJobID).child("Full Name").setValue((Auth.auth().currentUser?.displayName)!)
        
    }
    
    
    
    
    func ERR_Empty_Fields(){
        
        let alert = UIAlertController(title: "Empty Fields", message: "Fill In Required Fields", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func ERR_No_Location(){
        
        let alert = UIAlertController(title: "Turn On Location", message: "Go and Allow Locations", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension BuyVC {
    fileprivate func prepareUndoButton() {
        undoButton = FlatButton(title: "Undo", titleColor: Color.yellow.base)
        undoButton.pulseAnimation = .backing
        undoButton.titleLabel?.font = snackbarController?.snackbar.textLabel.font
    }
    
    fileprivate func prepareSnackbar() {
        guard let snackbar = snackbarController?.snackbar else {
            return
        }
        
        snackbar.text = "Your job has been successfully posted."
        snackbar.rightViews = [undoButton]
    }
    
    fileprivate func scheduleAnimation() {
        Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(animateSnackbar), userInfo: nil, repeats: false)
    }
}

extension BuyVC {
    @objc
    fileprivate func animateSnackbar() {
        guard let sc = snackbarController else {
            return
        }
        
        _ = sc.animate(snackbar: .visible, delay: 1)
        _ = sc.animate(snackbar: .hidden, delay: 4)
    }
}

extension BuyVC {
    fileprivate func prepareTabItem() {
        if tabItem.isSelected {
            tabItem.title = "Post Job"
            tabItem.image = nil
        }
        else{
            tabItem.title = nil
            tabItem.image = Icon.pen
        }

    }
}

extension BuyVC: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.first
        print(self.currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            self.coreLocation.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
