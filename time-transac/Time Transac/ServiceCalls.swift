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

//Singleton
class ServiceCalls{

    private var fireBaseRef: DatabaseReference!
    private let jobsRef: DatabaseReference!
    private let needConfirmRef: DatabaseReference!
    private let userRef: DatabaseReference!
    var availableJobs: [Job] = []
    
    init() {
        fireBaseRef = Database.database().reference()
        jobsRef = fireBaseRef.child("AllJobs")
        userRef = fireBaseRef.child("Users")
        needConfirmRef = fireBaseRef.child("NeedConfirmationJobs")
        
        
    }
    
    
    func addJobToFirebase(jobTitle: String, jobDetails: String, pricePerHour: String, numberOfHours: String, locationCoord: CLLocationCoordinate2D){
        
        let user = Auth.auth().currentUser
        let newJobID = self.jobsRef.childByAutoId().key
        let jobOwnerEmailHash = self.MD5(string: (Auth.auth().currentUser?.email)!)
        let latitude = locationCoord.latitude
        let longitude = locationCoord.longitude
        
        let jobDict: [String:Any] = ["latitude":latitude, "longitude":longitude, "JobOwner":jobOwnerEmailHash, "JobTitle":jobTitle, "JobDescription":jobDetails, "Price":pricePerHour, "Time":numberOfHours, "isOccupied":false, "isCompleted":false, "Full Name":(user?.displayName)!]
        self.jobsRef.child(newJobID).updateChildValues(jobDict)
        
        
        
        // adding job to the user who posted list of posted jobs
        let userPostedRef = self.userRef.child(self.MD5(string: (user?.email)!)).child("PostedJobs")
        userPostedRef.child(newJobID).updateChildValues(jobDict)
        
    }
    
    
    
    func getJobFromFirebase(completion: @escaping ([Job],[MGLPointAnnotation])->()){

//        jobsRef.observe(.childAdded, with: { (snapshot) in
//            let job = Job(snapshot: snapshot as! DataSnapshot)
//            print(job.jobOwnerEmailHash)
//        })
//
        jobsRef.observe(.childAdded, with: { (snapshot) in

            print(snapshot)
            var newJobs : [Job] = []
            var annotations = [MGLPointAnnotation]()

            let job = Job(snapshot: snapshot)
            self.userRef.observe(.value, with: { (snapshot2) in
                let userIDs = snapshot2.value as! [String : AnyObject]
                job.jobOwnerRating = userIDs[job.jobOwnerEmailHash]!["Rating"] as! Float
                if job.jobOwnerEmailHash != self.MD5(string: (Auth.auth().currentUser?.email)!){
                    newJobs.append(job)
                    let point = MGLPointAnnotation()
                    point.coordinate = job.location.coordinate
                    point.title = job.title
                    point.subtitle = ("$"+"\(job.wage_per_hour)"+"/Hour")
                    annotations.append(point)
                }

                completion(newJobs,annotations)
                self.userRef.removeAllObservers()
                self.jobsRef.removeAllObservers()
            })

        })
    }
    
    
    func acceptPressed(job: Job, user: User, completion: @escaping (String)->()){
        let applicantRef = self.needConfirmRef.child(job.jobID!).child("Applicants")
        applicantRef.child(self.MD5(string: user.email!)).setValue(user.displayName)

        self.needConfirmRef.child(job.jobID).child("JobTitle").setValue(job.title)
        self.needConfirmRef.child(job.jobID).child("JobDescription").setValue(job.description)
        self.needConfirmRef.child(job.jobID).child("JobOwner").setValue(job.jobOwnerEmailHash)
        self.needConfirmRef.child(job.jobID).child("Full Name").setValue(job.jobOwnerFullName)
        self.needConfirmRef.child(job.jobID).child("Price").setValue("\(job.wage_per_hour)")
        self.needConfirmRef.child(job.jobID).child("Time").setValue("\(job.maxTime)")
        self.needConfirmRef.child(job.jobID).child("latitude").setValue(job.latitude)
        self.needConfirmRef.child(job.jobID).child("longitude").setValue(job.longitude)
        self.needConfirmRef.child(job.jobID).child("isCompleted").setValue(false)
        self.needConfirmRef.child(job.jobID).child("isOccupied").setValue(false)
        applicantRef.child(self.MD5(string: user.email!)).setValue(user.displayName)
        
        
        
        let userAcceptedRef = self.userRef.child(self.MD5(string: user.email!)).child("AcceptedJobs")
        userAcceptedRef.child(job.jobID).child("JobTitle").setValue(job.title)
        userAcceptedRef.child(job.jobID).child("JobDescription").setValue(job.description)
        userAcceptedRef.child(job.jobID).child("JobOwner").setValue(job.jobOwnerEmailHash)
        userAcceptedRef.child(job.jobID).child("Full Name").setValue(job.jobOwnerFullName)
        userAcceptedRef.child(job.jobID).child("Price").setValue("\(job.wage_per_hour)")
        userAcceptedRef.child(job.jobID).child("Time").setValue("\(job.maxTime)")
        userAcceptedRef.child(job.jobID).child("latitude").setValue(job.latitude)
        userAcceptedRef.child(job.jobID).child("longitude").setValue(job.longitude)
        userAcceptedRef.child(job.jobID).child("isCompleted").setValue(false)
        userAcceptedRef.child(job.jobID).child("isOccupied").setValue(false)
        
        let jobOwnerEmailHash = job.jobOwnerEmailHash!
        userRef.observe(.value, with: { (snapshot) in
            let userValues = snapshot.value as! [String : AnyObject]
            guard let deviceToken = userValues[jobOwnerEmailHash]!["currentDevice"]! as? String else{return}
            completion(deviceToken)
            self.userRef.removeAllObservers()
        })
        
    }
    
    
    func loadUncomfirmedJobs(completion: @escaping ([Job])->()) {
        needConfirmRef.observe(.value, with: { (snapshot) in
            var uncomfirmedJobs: [Job] = []
            for item in snapshot.children{
                let job = Job(snapshot: item as! DataSnapshot)
                if job.jobOwnerEmailHash == self.MD5(string: (Auth.auth().currentUser?.email)!){
                    uncomfirmedJobs.append(job)
                }
                
            }
            
            completion(uncomfirmedJobs)
            self.needConfirmRef.removeAllObservers()
        })
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
    
}









