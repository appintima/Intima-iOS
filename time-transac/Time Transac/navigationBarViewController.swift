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

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSplashScreen()
        // Sets the background of the navigation bar to be transperant.
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.backItem?.title = "Back"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
    }
    
    func prepareSplashScreen(){
        let splash = RevealingSplashView(iconImage: UIImage(named: "Clock")!, iconInitialSize: CGSize(width: 112, height: 100), backgroundColor: #colorLiteral(red: 0.3476088047, green: 0.1101973727, blue: 0.08525472134, alpha: 1))
        self.view.addSubview(splash)
        splash.animationType = SplashAnimationType.squeezeAndZoomOut
        splash.startAnimation(){
            print("Splash Complete")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}
