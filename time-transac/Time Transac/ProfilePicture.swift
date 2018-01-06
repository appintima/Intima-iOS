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
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionPopup = UIAlertController(title: "Photo Source", message: "Choose Image", preferredStyle: .actionSheet)
        
        actionPopup.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionPopup.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionPopup.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionPopup, animated: true, completion: nil)
        
        // if the tapped view is a UIImageView then set it to imageview
//        if (gesture.view as? UIImageView) != nil {
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                let imagePicker = UIImagePickerController()
//                imagePicker.delegate = self
//                imagePicker.sourceType = .camera;
//                imagePicker.allowsEditing = false
//                self.present(imagePicker, animated: true, completion: nil)
//            }
//            //Here you can initiate your new ViewController
//
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func continuePressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "endSignUp", sender: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        profilePicture.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
