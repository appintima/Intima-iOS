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
    private let userRef: DatabaseReference!
    var availableJobs: [Job] = []
    
    init() {
        fireBaseRef = Database.database().reference()
        jobsRef = fireBaseRef.child("AllJobs")
        userRef = fireBaseRef.child("Users")
    }
    
    
    func addJobToFirebase(jobTitle: String, jobDetails: String, pricePerHour: String, numberOfHours: String, locationCoord: CLLocationCoordinate2D){
        
        let user = Auth.auth().currentUser
        let newJobID = self.jobsRef.childByAutoId().key
        let jobOwnerEmailHash = self.MD5(string: (Auth.auth().currentUser?.email)!)
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
        
        let jobDict: [String:Any] = ["latitude":latitude, "longitude":longitude, "JobOwner":jobOwnerEmailHash, "JobTitle":jobTitle, "JobDescription":jobDetails, "Price":pricePerHour, "Time":numberOfHours, "isOccupied":false, "isCompleted":false, "Full Name":(user?.displayName)!]
        self.jobsRef.child(newJobID).updateChildValues(jobDict)
        
        // adding job to the user who posted list of posted jobs
        let userPostedRef = self.userRef.child(self.MD5(string: (user?.email)!)).child("PostedJobs")
        userPostedRef.child(newJobID).updateChildValues(jobDict)
        
        //add charges to user reference
        let userChargesRef = self.userRef.child(self.MD5(string: (user?.email)!)).child("Charges")
        let keyByDate = "Charge-\(fullDate)"
        userChargesRef.child(keyByDate).child("Time").setValue(fullDate)
        userChargesRef.child(keyByDate).child(newJobID).updateChildValues(jobDict)
        
    }
    
    
    
    func getJobFromFirebase(completion: @escaping ([Job],[MGLPointAnnotation])->()){

        var newJobs : [Job] = []
        var annotations = [MGLPointAnnotation]()
        jobsRef.observe(.childAdded, with: { (snapshot) in
            
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
                
                completion(newJobs, annotations)
            })
            
        })

    }
    
    
    func acceptPressed(job: Job, user: User, completion: @escaping (String)->()){
        let userAcceptedRef = self.userRef.child(self.MD5(string: user.email!)).child("AcceptedJobs")

        
        let jobDict: [String:Any] = ["latitude":job.latitude, "longitude":job.longitude, "JobOwner":job.jobOwnerEmailHash, "JobTitle":job.title, "JobDescription":job.description, "Price":job.wage_per_hour, "Time":job.maxTime, "isOccupied":false, "isCompleted":false,
                                     "Full Name":(job.jobOwnerFullName)!]

        userAcceptedRef.child(job.jobID).updateChildValues(jobDict)
        
        let jobOwnerEmailHash = job.jobOwnerEmailHash!
        userRef.observe(.value, with: { (snapshot) in
            let userValues = snapshot.value as! [String : AnyObject]
            
            // add the job to job poster's reference in database
            self.userRef.child(jobOwnerEmailHash).child("UnconfirmedJobs").child(job.jobID)
            .updateChildValues(jobDict)
        self.userRef.child(jobOwnerEmailHash).child("UnconfirmedJobs").child(job.jobID).child("Applicants").child(user.uid).setValue((user.displayName)!)
            
            guard let deviceToken = userValues[jobOwnerEmailHash]!["currentDevice"]! as? String else{return}
            completion(deviceToken)
            self.userRef.removeAllObservers()
        })
        
    }
    
    
//    func loadUncomfirmedJobs(completion: @escaping ([Job])->()) {
//        needConfirmRef.observe(.value, with: { (snapshot) in
//            var uncomfirmedJobs: [Job] = []
//            for item in snapshot.children{
//                let job = Job(snapshot: item as! DataSnapshot)
//                if job.jobOwnerEmailHash == self.MD5(string: (Auth.auth().currentUser?.email)!){
//                    uncomfirmedJobs.append(job)
//                }
//
//            }
//
//            completion(uncomfirmedJobs)
//            self.needConfirmRef.removeAllObservers()
//        })
//    }
    
    
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









