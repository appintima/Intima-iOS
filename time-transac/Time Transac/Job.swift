//
//  Job.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-06-14.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase


class Job {
    
    var jobOwnerPhotoURL: URL?
    let description: String
    var title: String
    var wage_per_hour: Double
    var maxTime: Double
    var jobOwner: User!
    var jobApplicant: User!
    var occupied: Bool!
    var completed: Bool!
    var jobID: String!
    var location: CLLocation!
//    static var jobIDarray = [String]()
    var jobTakerID: String!
    var jobOwnerEmailHash: String!
    var jobOwnerFullName: String!
    var jobOwnerRating: Float!
    var ref: DatabaseReference!
    let latitude: Double!
    let longitude: Double!
    




    init(snapshot: DataSnapshot) {
        self.jobID = snapshot.key
        let jobValues = snapshot.value as! [String: AnyObject]
        self.ref = snapshot.ref
        latitude = jobValues["latitude"] as! Double
        longitude = jobValues["longitude"] as! Double
        
        self.title = jobValues["JobTitle"] as! String
        self.description = jobValues["JobDescription"] as! String
        self.jobOwnerEmailHash = jobValues["JobOwner"] as! String
        self.jobOwnerFullName = jobValues["Full Name"] as! String
        self.wage_per_hour = Double(jobValues["Price"] as! String)!
        self.maxTime = Double(jobValues["Time"] as! String)!
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        
        
        
        
    }
    

    func setOccupied(){
        ref.updateChildValues(["isOccupied" : true])
    }
    
    func setNotOccupied(){
        ref.updateChildValues(["isOccupied" : false])
    }
    
    func setCompleted(){
        ref.updateChildValues(["isCompleted" : true])
    }
    
    func setNotCompleted(){
        ref.updateChildValues(["isCompleted" : false])
    }
    
    func setJobApplicant(user: User){
        
    }

}











