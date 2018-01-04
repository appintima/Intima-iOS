//
//  ConfirmPageVC.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 9/23/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//


import UIKit
import Firebase

class ConfirmProfilePageVC: UIViewController {
    
    var applicantInfo: [String:AnyObject]!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    let profilePicture = Auth.auth().currentUser?.photoURL
    var job: Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fullNameLabel.text = (applicantInfo["Name"] as! String)
        self.ratingsLabel.text = "\((applicantInfo["Rating"] as! Double))"
        let session = URLSession(configuration: .default)
        
        //creating a dataTask
        let getImageFromUrl = session.dataTask(with: profilePicture!) { (data, response, error) in
            
            //if there is any error
            if let e = error {
                //displaying the message
                print("Error Occurred: \(e)")
                
            } else {
                //in case of now error, checking wheather the response is nil or not
                if (response as? HTTPURLResponse) != nil {
                    
                    //checking if the response contains an image
                    if let imageData = data {
                        
                        //getting the image
                        let image = UIImage(data: imageData)
                        
                        //displaying the image
                        self.profilePic.image = image
                        
                    } else {
                        print("Image file is currupted")
                    }
                } else {
                    print("No response from server")
                }
            }
        
        //        self.usernameLabel.text = "@" + self.job.getJobTaker().getUsername()
        //        self.fullNameLabel.text = self.job.getJobTaker().getFirstName() + " " + self.job.getJobTaker().getLastName()
        //        self.ratingsLabel.text = "\(self.job.getJobTaker().getAverageRating())"
        // Do any additional setup after loading the view.
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func confirmclicked(_ sender: UIButton) {
    }
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
