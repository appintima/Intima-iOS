//
//  ConfirmPageVC.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 9/23/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//


import UIKit
import Firebase
import Lottie
import Pastel
import Kingfisher

class ConfirmProfilePageVC: UIViewController {
    
    var applicantInfo: [String:AnyObject]!
    @IBOutlet weak var gradientView: PastelView!
    @IBOutlet weak var scrollForReviews: UIScrollView!
    @IBOutlet weak var ratingAnimationView: UIView!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var totalJobs: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    let ratingAnimation = LOTAnimationView(name: "5_stars")
    var picURL: URL?
    var job: Job!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        prepareInformation()
        self.gradientView.animationDuration = 3.0
        gradientView.setColors([#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 0.7605337501, green: 0.7767006755, blue: 0.7612826824, alpha: 1)])
        profilePic.cornerRadius = profilePic.frame.height/2
        picURL = URL(string: (applicantInfo["photoURL"] as! String))
        //// PARTIALLY DONE/////
        profilePic.kf.setImage(with: picURL!)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.gradientView.startAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.gradientView.startAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareInformation() {
        self.fullNameLabel.text = (applicantInfo["Name"] as! String)
        self.ratingAnimationView.handledAnimation(Animation: ratingAnimation)
        ratingAnimation.play(toProgress: CGFloat((applicantInfo["Rating"] as! Float)/5), withCompletion: nil)
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
