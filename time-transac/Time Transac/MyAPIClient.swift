//
//  MyAPIClient.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 12/23/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import Foundation
import Stripe
import Alamofire
import Firebase
import FirebaseDatabase

class MyAPIClient: NSObject, STPEphemeralKeyProvider {
    
    var customer_id: String?
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    static let sharedClient = MyAPIClient()
    var baseURLString: String? = "https://us-central1-intima-227c4.cloudfunctions.net/"
    var baseURL: URL{
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
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
    
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        if customer_id == nil{
            let customerID = Database.database().reference().child("Users").child(MD5(string: (Auth.auth().currentUser?.email)!)).child("customer_id")
            customerID.observeSingleEvent(of: .value) { (snapshot) in
                if let cu_ID = snapshot.value as? String{
                    print(cu_ID,"Customer ID printed")
                    self.customer_id = cu_ID
                    
                }
            }
        }
        
        Alamofire.request(url, method: .post, parameters: [
            "api_version": apiVersion,
            "customerID": customer_id!
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                    
                }
        }
    }
    
    enum CustomerKeyError: Error {
        case missingBaseURL
        case invalidResponse
    }
    
    func completeCharge(amount: Int,
                        completion: @escaping STPErrorBlock) {
        
        if customer_id == nil{
            let customerID = Database.database().reference().child("Users").child(MD5(string: (Auth.auth().currentUser?.email)!)).child("customer_id")
            customerID.observeSingleEvent(of: .value) { (snapshot) in
                if let cu_ID = snapshot.value as? String{
                    print(cu_ID,"Customer ID printed")
                    self.customer_id = cu_ID
                    
                }
            }
        }

        let url = self.baseURL.appendingPathComponent("charges")
        let params: [String: Any] = [
            "customerID": self.customer_id!,
            "amount": amount,
            "currency": "CAD"
        ]
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    func getCurrentCustomer(completion: @escaping STPJSONResponseCompletionBlock) {
        if customer_id == nil{
            let customerID = Database.database().reference().child("Users").child(MD5(string: (Auth.auth().currentUser?.email)!)).child("customer_id")
            customerID.observeSingleEvent(of: .value) { (snapshot) in
                if let cu_ID = snapshot.value as? String{
                    print(cu_ID,"Customer ID printed")
                    self.customer_id = cu_ID
                    
                }
            }
        }
        let url = self.baseURL.appendingPathComponent("getCustomer")
        let params: [String: Any] = [
            "customerID": customer_id!
        ]
        
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                    
                }
        }
    }
    
    func updateCustomerDefaultSource(id source_id: String, completion: @escaping STPErrorBlock) {
        if customer_id == nil{
            let customerID = Database.database().reference().child("Users").child(MD5(string: (Auth.auth().currentUser?.email)!)).child("customer_id")
            customerID.observeSingleEvent(of: .value) { (snapshot) in
                if let cu_ID = snapshot.value as? String{
                    print(cu_ID,"Customer ID printed")
                    self.customer_id = cu_ID
                    
                }
            }
        }
        let url = self.baseURL.appendingPathComponent("updateStripeCustomerDefaultSource")
        let params: [String: Any] = [
            "customerID": customer_id!,
            "source": source_id
        ]
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    func createPaymentSource(cardName: String, cardNumber: String, cardExpMonth: UInt, cardExpYear: UInt, cardCVC: String, completion: @escaping STPSourceCompletionBlock) {
        let cardParams = STPCardParams()
        cardParams.name = cardName
        cardParams.number = cardNumber
        cardParams.expMonth = cardExpMonth
        cardParams.expYear = cardExpYear
        cardParams.cvc = cardCVC
        
        let sourceParams = STPSourceParams.cardParams(withCard: cardParams)
        STPAPIClient.shared().createSource(with: sourceParams, completion: completion)
    }
    
    func addPaymentSource(id source_id: String, completion: @escaping STPErrorBlock) {
        if customer_id == nil{
            let customerID = Database.database().reference().child("Users").child(MD5(string: (Auth.auth().currentUser?.email)!)).child("customer_id")
            customerID.observeSingleEvent(of: .value) { (snapshot) in
                if let cu_ID = snapshot.value as? String{
                    print(cu_ID,"Customer ID printed")
                    self.customer_id = cu_ID
                    
                }
            }
        }
        let url = self.baseURL.appendingPathComponent("addPaymentSource2")
        let params: [String: Any] = [
            "customerID": customer_id!,
            "sourceID": source_id
        ]
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
}
