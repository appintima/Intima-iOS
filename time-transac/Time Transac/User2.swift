//
//  File.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-06-13.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//
import Foundation
import UIKit
import Firebase


class User2: Hashable {
    
    var firstName, lastName, username, email, password: String!
    var available_JobsToComplete: Array<Job>!
    var user_PostedJobs: Array<Job>!
    var average_Rating: Float!
    var skillSets: Array<Skill>!
    var skillsString: Array<String>!
    var unconfirmedJobs: Array<Job>!
    var allCompletedJobs: Array<Job>!
    var profilePic: UIImage!
    var uid: String!
    var hashValue: Int{
        return self.getEmail().hashValue
    }
    
    
    init(authData: User) {
        self.uid = authData.uid
        self.email = authData.email
        
    }
    
    
    init() {
        self.firstName = nil
        self.lastName = nil
        self.username = nil
        self.email = nil
        self.password = nil
        self.available_JobsToComplete = Array()
        self.user_PostedJobs = Array()
        self.average_Rating = 5
        self.skillSets = Array()
        self.allCompletedJobs = Array()
        self.skillsString = Array()
        self.unconfirmedJobs = Array()
        self.profilePic = nil
    }
    
    func setProfilePic(image: UIImage){
        self.profilePic = image
    }
    
    func getProfilePic()->UIImage{
        return self.profilePic
    }
    
    func setUsername(username: String){
        self.username = username
    }
    
    func getUsername()-> String{
        return self.username
    }
    
    func getSkillsString()->Array<String>{
        
        for skill in skillSets{
            if !(self.skillsString.contains(skill.getSkillName())){
                self.skillsString.append(skill.getSkillName())
            }
        }
        return self.skillsString
    }
    
    
    func addToUncomfirmedJobs(job: Job){
        self.unconfirmedJobs.append(job)
    }
    
    func getUnconfirmedJobs() -> Array<Job>{
        return self.unconfirmedJobs
    }
    
    //returns all jobs in user's TO BE COMPLETED jobs ***
    func getAvailable_JobsToComplete()->Array<Job>{
        return self.available_JobsToComplete
    }
    
    //returns all the task a user has posted from time ***
    func getUser_Posted_Jobs()-> Array<Job>!{
        return self.user_PostedJobs
    }
    
    //post a task for the world ***
    //    func post_a_job(job: Job, interface: AllJobs){
    //        job.setJobOwner(poster: self)
    //        interface.addJob_to_GlobalList(job: job)
    //        self.user_PostedJobs.append(job)
    //    }
    
    //add a skill to list of skills ***
    func addSkill(skill: Skill){
        if !(self.skillSets.contains(skill)){
            self.skillSets.append(skill)
        }
    }
    
    
    //return the list of skills ***
    func getSkillSets()->Array<Skill>{
        return self.skillSets
    }
    
    
    func getRandSkill()->Skill{
        let ind: Int = Int(arc4random_uniform(UInt32(self.skillSets.count)))
        return self.skillSets[ind]
        
    }
    
    //***
    func getFirstName() -> String {
        return self.firstName
    }
    
    //***
    func setFirstName(name: String){
        self.firstName = name
    }
    
    //***
    func getLastName() -> String {
        return self.lastName
    }
    
    //***
    func setLastName(name: String) {
        self.lastName = name
    }
    
    //***
    func getEmail() -> String {
        return self.email.lowercased()
    }
    
    //***
    func setEmail(email: String) {
        self.email = email
    }
    
    //***
    func getPassword() -> String {
        return self.password
    }
    
    //***
    func setPassword(password: String) {
        self.password = password
    }
    
    
    //accept an available job or task ***
    //    func acceptJob(job: Job, interface: AllJobs){
    //        if !job.isOccupied() {
    //            self.available_JobsToComplete.append(job)
    //            job.setOccupied()
    //            interface.remove_Job_from_GlobalList(job: job)
    //        }else{
    //            return
    //        }
    //
    //    }
    
    /*
     reduce the user's average_Rating if they cancel an accepted job ***
     */
    //    func cancelJob(job: Job)-> Job!{
    //        if !self.available_JobsToComplete.isEmpty {
    //            job.setNotOccupied()
    //            let job_index = self.available_JobsToComplete.index(of: job)
    //            self.available_JobsToComplete.remove(at: job_index!)
    //            self.average_Rating = self.average_Rating/1.005
    //            return job
    //        }else{
    //            return nil
    //        }
    //    }
    
    func getAverageRating()->Int{
        
        return Int(self.average_Rating)
    }
    
    func setAverageRating(){
        //TO DO
    }
    
    
    /////////// LOOK BACK TO ////////////////
    //    func rateUser(user: User, num: Int){
    //        //TO DO
    //    }
    
    func addToCompletedJobs(job: Job){
        self.allCompletedJobs.append(job)
    }
    
    func getAllCompletedJobs()->Array<Job>{
        return self.allCompletedJobs
    }
    
    
}



//func ==(lhs: User, rhs: User) -> Bool {
//    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
//}
func ==(lhs: User2, rhs: User2) ->Bool {
    return lhs.getEmail() == rhs.getEmail()
}
