//
//  ConfirmPageVC.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 9/23/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//


import UIKit

class ConfirmPageVC: UIViewController {
    
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    
    var job: Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        self.usernameLabel.text = "@" + self.job.getJobTaker().getUsername()
        //        self.fullNameLabel.text = self.job.getJobTaker().getFirstName() + " " + self.job.getJobTaker().getLastName()
        //        self.ratingsLabel.text = "\(self.job.getJobTaker().getAverageRating())"
        // Do any additional setup after loading the view.
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
