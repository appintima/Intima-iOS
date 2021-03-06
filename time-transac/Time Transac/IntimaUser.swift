//
//  IntimaUser.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2018-01-27.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Firebase

class IntimaUser {
    var userEmailHash:String?
    var email:String?
    var name: String?
    var rating: Double?
    var currentDevice: String?
    var customerID: String?
    var photoURL: URL?
    var uid: String?
    
    var ref:DatabaseReference!
    
    init?(snapshot: DataSnapshot){
        guard !snapshot.key.isEmpty,
            let userValues = snapshot.value as? [String:AnyObject],
            let email = userValues["Email"] as? String,
            let name = userValues["Name"] as? String,
            let rating = userValues["Rating"] as? Double,
            let currentDevice = userValues["currentDevice"] as? String,
            let customerID = userValues["customer_id"] as? String,
            let photoURL = userValues["photoURL"] as? String,
            let uid = userValues["uid"] as? String
        else{return nil}
        
        self.ref = snapshot.ref
        self.userEmailHash = snapshot.key
        self.email = email
        self.name = name
        self.rating = rating
        self.currentDevice = currentDevice
        self.customerID = customerID
        self.photoURL = URL(string: photoURL)
        self.uid = uid
    }
}
