//
//  navigationBarViewController.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 9/12/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import IBAnimatable
import RevealingSplashView

class navigationBarViewController: AnimatableNavigationController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the background of the navigation bar to be transperant.
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.backItem?.title = "Back"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if appDelegate.isLaunched {
            prepareSplash()
        }
        else{
            if let splashView = self.view.viewWithTag(10) {
                splashView.removeFromSuperview()
            }
        }
    }
    
    func prepareSplash(){
        
        let splash = RevealingSplashView(iconImage: UIImage(named: "Clock")!, iconInitialSize: CGSize(width: 112, height: 100), backgroundColor: #colorLiteral(red: 0.3476088047, green: 0.1101973727, blue: 0.08525472134, alpha: 1))
        splash.animationType = SplashAnimationType.squeezeAndZoomOut
        splash.tag = 10
        self.view.addSubview(splash)
        splash.startAnimation() {
            print("Splash Screen complete")
            self.appDelegate.isLaunched = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}
