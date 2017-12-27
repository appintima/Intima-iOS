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
    
    let description: String
    var title: String
    var wage_per_hour: Double
    var maxTime: Double
    var jobOwner: User!
    var jobTaker: User!
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
    
    func setJobTaker(user: User){
        
    }
    







//    init(title: String, description: String, wage_per_hour: Float, maxTime: Int) {
//        self.description = description
//        self.title = title
//        self.wage_per_hour = wage_per_hour
//        self.maxTime = maxTime
//        self.jobOwner = nil
//        self.occupied = false
//        self.completed = false
//        self.jobTaker = nil
//        self.jobID = nil
//        self.location = nil
//        
//    }
//    
//    func setLocation(location: CLLocation){
//        self.location = location
//    }
//    
//    func getLocation()->CLLocation{
//        return self.location
//    }
//    
//    func setJobID(){
//        self.jobID = generateID()
//    }
//    
//    func getJobID()->String{
//        return self.jobID
//    }
//    
//    func setJobTaker(jobTaker: User){
//        self.jobTaker = jobTaker
//    }
//    
//    func getJobTaker()-> User!{
//        return self.jobTaker
//    }
//    
//    
//    func getDescription()-> String{
//        return self.description
//    }
//    
//    func getWage()->Float{
//        return self.wage_per_hour
//    }
//    
//    func getMaxTime()->Int{
//        return self.maxTime
//    }
//    
//    func getJobOwner() -> User {
//        return self.jobOwner
//    }
//    
//    func setJobOwner(poster: User){
//        self.jobOwner = poster
//    }
//    
//    func setOccupied(){
//        self.occupied = true
//    }
//    
//    func setNotOccupied(){
//        self.occupied = false
//        self.completed = false
//        self.jobTaker = nil
//    }
//    
//    func isOccupied() -> Bool {
//        return self.occupied
//    }
//    
//    func setCompleted(){
//        self.completed = true
//    }
//    
//    func setTitle(title: String){
//        self.title = title
//    }
//    
//    func getTitle()-> String{
//        return self.title
//    }
//    

//
//
//
//
//
//
//func ==(lhs: Job, rhs: Job) -> Bool {
//    return lhs.getJobID() == rhs.getJobID()
//}

}









