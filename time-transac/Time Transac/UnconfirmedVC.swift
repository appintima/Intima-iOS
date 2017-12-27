//
//  UnconfirmedVC.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-10-28.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Firebase

class UnconfirmedVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let service = ServiceCalls()
    
    let cardHeight: CGFloat = 600
    let cardWidth: CGFloat = 300
    var yPosition:CGFloat = 0
    var scrollViewContentSize: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        service.loadUncomfirmedJobs { (unconfirmedJobs) in
            for job in unconfirmedJobs{
                self.loadAndAddCardToScrollView(job: job)
            }
            self.resetCardAttributesValues()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    func resetCardAttributesValues(){
        yPosition = 0
        scrollViewContentSize = 0
    }
    
    func loadAndAddCardToScrollView(job: Job){
        
        var popupCard: PopUpJobViewVC!
        popupCard = Bundle.main.loadNibNamed("PopUpJobView", owner: nil, options: nil)?.first as! PopUpJobViewVC
        
        popupCard.job = job
        
        
        popupCard.fullNameLabel.ApplyCornerRadiusToView()
        popupCard.jobDescriptionLabel.ApplyCornerRadiusToView()
        popupCard.priceLabel.ApplyCornerRadiusToView()
        popupCard.ApplyCornerRadiusToView()
        popupCard.ApplyOuterShadowToView()
        
        
        popupCard.fullNameLabel.text = job.jobOwnerFullName
        popupCard.jobDescriptionLabel.text = job.description
        popupCard.priceLabel.text = ("$"+"\(job.wage_per_hour)"+"/Hour")
        popupCard.acceptButton.isHidden = true
        
        let animation = popupCard.returnHandledAnimation(filename: "5_stars", subView: popupCard.rating, tagNum: 1)
        animation.play()
        
        popupCard.center = self.view.center
        popupCard.frame.origin.y = yPosition
        
        
        self.scrollView.addSubview(popupCard)
        let spacer: CGFloat = 20
        
        yPosition = yPosition + cardHeight + spacer
        scrollViewContentSize = scrollViewContentSize + cardHeight + spacer
        
        self.scrollView.contentSize = CGSize(width: cardWidth, height: scrollViewContentSize)
        
        
    }

}
