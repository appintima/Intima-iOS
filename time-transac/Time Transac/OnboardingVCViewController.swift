//
//  OnboardingVCViewController.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 2018-01-08.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Lottie

class OnboardingVCViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var serviceAnimationView: UIView!

    let serviceAnimation = LOTAnimationView(name: "servishero_loading")
    let serviceArray = ["Post jobs on Intima, and set your own fair price. Whether its a handyman, a grocer, or a tutor","Cleaning services? No problem!","Repairs? Go ahead!","Need a personal chaffeur for the night?  Hire one!","How about a freelance photographer?","Deliveries to and from custom locations"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        prepareAnimation()
        setupScrollView()
        pageControl.numberOfPages = 6
    }
    
    func setupScrollView(){
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: self.view.frame.size.width * 6, height: scrollView.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        
        for stage in 0...5{
    
            let label = UILabel(frame: CGRect(x: scrollView.center.x + CGFloat(stage) * self.view.frame.size.width - 125 , y: 0, width: 250, height: self.scrollView.frame.size.height))
            label.font = UIFont(name: "CenturyGothic", size: 20)
            label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            label.textAlignment = .center
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.text = serviceArray[stage]
            scrollView.addSubview(label)
        }
        
    }
    
    @IBAction func GoToLGSU(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goToLGSU", sender: self)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let progress = (scrollView.contentOffset.x + 120) / scrollView.contentSize.width
        serviceAnimation.animationProgress = progress
    }
    

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func prepareAnimation(){
        
        serviceAnimationView.handledAnimation(Animation: serviceAnimation)
        serviceAnimation.animationSpeed = 100
        serviceAnimation.play(fromProgress: 0, toProgress: 0.1, withCompletion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
