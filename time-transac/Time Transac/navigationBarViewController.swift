//
//  navigationBarViewController.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 9/12/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import IBAnimatable

class navigationBarViewController: AnimatableNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the background of the navigation bar to be transperant.
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.backItem?.title = "Back"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}
