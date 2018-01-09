//
//  OnboardingVCViewController.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 2018-01-08.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Lottie
import Pastel
import CHIPageControl

class OnboardingVCViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var gradientView: PastelView!
    @IBOutlet weak var pageControl: CHIPageControlFresno!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var serviceAnimationView: UIView!

    let serviceAnimation = LOTAnimationView(name: "servishero_loading")
    let serviceArray = ["Post jobs on Intima, and set your own fair price. Whether its a handyman, a grocer, or a tutor","Cleaning services? No problem!","Repairs? Go ahead!","Need a personal chaffeur for the night?  Hire one!","How about a freelance photographer?","Deliveries to and from custom locations"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        gradientView.animationDuration = 3.0
        gradientView.setColors([#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)])
        self.navigationController?.navigationBar.isHidden = true
        prepareAnimation()
        setupScrollView()
        pageControl.numberOfPages = 6
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gradientView.startAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gradientView.startAnimation()
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

        
        let progress = (scrollView.contentOffset.x + 125) / scrollView.contentSize.width
        serviceAnimation.animationProgress = progress
        print(scrollView.contentOffset.x)
        let pageProgress = scrollView.contentOffset.x / 375
        pageControl.progress = Double(pageProgress)
    }
    

//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
//        pageControl.currentPage = Int(pageNumber)
//    }
    
    func prepareAnimation(){
        
        serviceAnimationView.handledAnimation(Animation: serviceAnimation)
        serviceAnimation.animationSpeed = 10000
        serviceAnimation.play(fromProgress: 0, toProgress: 0.1, withCompletion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
