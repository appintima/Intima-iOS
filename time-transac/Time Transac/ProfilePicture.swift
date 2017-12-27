//
//  ProfilePicture.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 12/17/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Pastel

class ProfilePicture: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var gradientView: PastelView!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfilePicture.imageTapped(gesture:)))
        
        // add it to the image view;
        profilePicture.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        profilePicture.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        gradientView.animationDuration = 3.0
        gradientView.setColors([#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gradientView.startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gradientView.startAnimation()
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            //Here you can initiate your new ViewController
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
