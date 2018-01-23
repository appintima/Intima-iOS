//
//  DataBase.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-06-22.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation
import Firebase
import Mapbox

class ServiceCalls{

    private var fireBaseRef: DatabaseReference!
    let jobsRef: DatabaseReference!
    let userRef: DatabaseReference!
    var availableJobs: [Job] = []
    let helper = HelperFunctions()
    let emailHash = HelperFunctions().MD5(string: (Auth.auth().currentUser?.email)!)
    var jobsRefHandle:UInt!
    var userRefHandle: UInt!
    
    static var counter = 0
    
    init() {
        fireBaseRef = Database.database().reference()
        jobsRef = fireBaseRef.child("AllJobs")
        userRef = fireBaseRef.child("Users")
        
    }
    
/**
     Add a job to Firebase Database
 */
    
    func addJobToFirebase(jobTitle: String, jobDetails: String, pricePerHour: String, numberOfHours: String, locationCoord: CLLocationCoordinate2D, chargeID: String){
        
        let user = Auth.auth().currentUser
        let newJobID = self.jobsRef.childByAutoId().key
        let latitude = locationCoord.latitude
        let longitude = locationCoord.longitude
        
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let fullDate = "\(day)-\(month)-\(year) \(hour):\(minute):\(second)"
        
        let jobDict: [String:Any] = ["latitude":latitude, "longitude":longitude, "JobOwner":self.emailHash, "JobTitle":jobTitle, "JobDescription":jobDetails, "Price":pricePerHour, "Time":numberOfHours, "isOccupied":false, "isCompleted":false, "Full Name":(user?.displayName)!]
        
        
        // adding job to the user who posted list of last post
        let lastPostedRef = self.userRef.child(self.emailHash).child("LastPost")
        
        self.jobsRef.child(newJobID).updateChildValues(jobDict)
        lastPostedRef.child(newJobID).updateChildValues(jobDict)
        
        //add charges to user reference
        let userChargesRef = self.userRef.child(self.emailHash).child("Charges")
        let keyByDate = chargeID
        userChargesRef.child(keyByDate).child("Time").setValue(fullDate)
        userChargesRef.child(keyByDate).child(newJobID).updateChildValues(jobDict)
        
    }
    
/**
 
 */
//    func removedJobFromFirebase(completion: @escaping (Job)->()){
//
//        jobsRefHandle = jobsRef.observe(.childRemoved, with: { (snapshot) in
//            let job = Job(snapshot: snapshot)
//            completion(job)
//        })
//
//    }
    
/**
     
*/

    func removeAcceptedJobsFromMap(completion: @escaping (Job?)->()){

        jobsRefHandle = jobsRef.observe(.childChanged, with: { (snapshot) in
            let job = Job(snapshot: snapshot)
            
            // if the task is accepted but not completed put the job in completion to be removed when called
            if ((job?.occupied)! && !((job?.completed)!)){
                print("INSide")
                completion(job)
            }
        })
        
    }
    
/**
     doesn't load tasks whose occupied is true as part of completion dictionary
 */
    
    func getJobsFromFirebase(MapView:MGLMapView , completion: @escaping ([String:CustomMGLAnnotation])->()){

//        var newJobs : [Job] = []
        var annotationDict: [String:CustomMGLAnnotation] = [:]
        
        jobsRefHandle = jobsRef.observe(.childAdded, with: { (snapshot) in
            let job = Job(snapshot: snapshot)
            // check if the curr job snap is not curr user's and also if the job is not accepted
            if (job?.jobOwnerEmailHash != self.emailHash && !(job?.occupied)!){
                
                let jobPosterRef = self.userRef.child((job?.jobOwnerEmailHash)!)
                jobPosterRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let userVal = snapshot.value as? [String:AnyObject]
                    job?.jobOwnerRating = userVal!["Rating"] as? Float
                    job?.jobOwnerPhotoURL = URL(string: (userVal!["photoURL"] as? String)!)
                    
                    let point = CustomMGLAnnotation()
                    point.job = job
                    point.coordinate = (job?.location.coordinate)!
                    point.title = job?.title
                    point.subtitle = ("$"+"\((job?.wage_per_hour)!)"+"/Hour")
                    MapView.addAnnotation(point)
                    annotationDict[(job?.jobID)!] = point
                    print(job?.jobID)
                    completion(annotationDict)
                })
            }
        })

    }
    
/**
    When you accept a job, a device token is stored for notification.
     
     - parameter job: The job being accepted.
     - parameter user: The user who accepted the job.
     - parameter completion: The completion block where device token is stored.
     - returns: Void
*/
    func acceptPressed(job: Job, user: User, completion: @escaping (String)->()){
        let userAcceptedRef = self.userRef.child(self.emailHash).child("AcceptedJobs")

        
        let jobDict: [String:Any] = ["latitude":job.latitude, "longitude":job.longitude, "JobOwner":job.jobOwnerEmailHash, "JobTitle":job.title, "JobDescription":job.description, "Price":"\(job.wage_per_hour)", "Time":"\(job.maxTime)", "isOccupied":job.occupied!, "isCompleted":job.completed!,
                                     "Full Name":(job.jobOwnerFullName)!]

        userAcceptedRef.child(job.jobID).updateChildValues(jobDict)
        
        jobsRef.child(job.jobID).updateChildValues(["isOccupied":true])
        
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let userValues = snapshot.value as! [String : AnyObject]
            
            // add the job to job poster's "LatestPostAccepted" reference in database
            self.userRef.child(job.jobOwnerEmailHash).child("LatestPostAccepted").child(job.jobID)
                .updateChildValues(jobDict)
            self.userRef.child(job.jobOwnerEmailHash).child("LatestPostAccepted").child(job.jobID).child("Applicant").child(self.helper.MD5(string: user.email!)).setValue((user.displayName)!)
            
            //add to the "uAccepted" ref for current user
            self.userRef.child(self.helper.MD5(string: user.email!)).child("uAccepted").updateChildValues(jobDict)
            
//            self.userRef.child(job.jobOwnerEmailHash).child("PostHistory").child(job.jobID).updateChildValues(jobDict)
            //remove the job poster's last post so they can post another
            let ref = self.userRef.child(job.jobOwnerEmailHash).child("LastPost")
            ref.setValue(nil)
            guard let deviceToken = userValues[job.jobOwnerEmailHash]!["currentDevice"]! as? String else{return}
            completion(deviceToken)
        })
    }
    
/**
 
 */
    
    func getCustomerID(completion: @escaping (String) -> ()){
        
        userRef.observe(.value, with: { (snapshot) in
            let userDict = snapshot.value as! [String: AnyObject]
            let customer = userDict[self.emailHash]!["customer_id"]! as! String
            completion(customer)
            self.userRef.removeAllObservers()
        })
    }
    
    
    
/**
     check if the current user needs make actions on tasks
 */
    func checkUncompletedJobs(completion: @escaping (Int?)->()){
        
        userRef.child(emailHash).observeSingleEvent(of: .value) { (snapshot) in
            if let userVal = snapshot.value as? [String:AnyObject]{
                if userVal["uAccepted"] != nil{// priority
                    completion(1)// code 1 for "you need to complete a task"
                }
                else if userVal["LatestPostAccepted"] != nil{
                    completion(2)// code 2 for "you need to start so the applicant can begin"
                }else{
                    completion(0)// code 0 for "you are good"
                }
            }
        }
    }
    
    
    
    
    
/**
     gets the accepted task and the email hash and name of the user who took the task as a dictionary
 */
//    func getUserLatestAccepted(completion: @escaping (Job?, String?)->()){
//        let latestPostAcceptedRef = userRef.child(emailHash).child("LatestPostAccepted")
//
//        latestPostAcceptedRef.observeSingleEvent(of: .childAdded, with: { (snapshot) in
//            if snapshot.hasChildren(){
//                let job = Job(snapshot: snapshot)
//                let dict = snapshot.value as! [String:AnyObject]
//                let applicantInfo = dict["Applicant"] as! [String:String]
//                let eHash = Array(applicantInfo.keys)[0]
//                completion(job, eHash)
//                latestPostAcceptedRef.removeAllObservers()
//            }
//        })
//
//    }
    
/**
     
*/
//    func getApplicants(job: Job, completion: @escaping ([String:String])->()){
//        let jobApplicantsRef = userRef.child(emailHash).child("LatestPostAccepted").child(job.jobID).child("Applicant")
//        var applicantsDict:[String:String] = [:]
//
//        jobApplicantsRef.observe(.value, with: { (snapshot) in
//            applicantsDict = snapshot.value as! [String:String]
//            completion(applicantsDict)
//            jobApplicantsRef.removeAllObservers()
//        })
//
//    }
    
/**
     check if the path "LatestPostAccepted" exists in the current users reference
*/
//    func checkLatestPostAcceptedExist(completion: @escaping (Bool)->()){
//        let latestPostAcceptedRef = userRef.child(emailHash).child("LatestPostAccepted")
//        latestPostAcceptedRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            if snapshot.hasChildren(){
//                completion(true)
//            }else{
//                completion(false)
//            }
//            latestPostAcceptedRef.removeAllObservers()
//        })
//    }
    

    
/**
     
*/
//    func getUserFullName(Emailhash: String, completion: @escaping (String)->()){
//        userRef.child(Emailhash).observe(.value, with: { (snapshot) in
//            let dict = snapshot.value as! [String:AnyObject]
//            let name = dict["Name"] as! String
//            completion(name)
//            self.userRef.child(Emailhash).removeAllObservers()
//        })
//    }
    
    
/**
 
 */
//    func checkUserLastPost(completion: @escaping (Bool)->()){
//
//        let lastPostedRef = self.userRef.child(self.emailHash).child("LastPost")
//        lastPostedRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            if !(snapshot.hasChildren()){
//                completion(false)
//            }else{// if there is a child
//                completion(true)
//            }
//            lastPostedRef.removeAllObservers()
//        })
//    }
    
    
/**
     
 */
//    func getApplicantProfile(emailHash: String?, completion: @escaping ([String:AnyObject]?)->()){
//        if emailHash != nil{
//            userRef.observe(.value, with: { (snapshot) in
//                let allInfo = snapshot.value as! [String:AnyObject]
//                let applicantInfo = allInfo[emailHash!] as! [String: AnyObject]
//                completion(applicantInfo)
//                self.userRef.removeAllObservers()
//            })
//        }else{  // no email Hash available
//            print("No One Has Accepted Your Task")
//            completion(nil)
//        }
//    }
    
}









