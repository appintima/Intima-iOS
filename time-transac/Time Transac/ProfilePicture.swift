//
//  ProfilePicture.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 12/17/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Pastel
import Firebase
import FirebaseStorage

class ProfilePicture: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var gradientView: PastelView!
    @IBOutlet weak var profilePicture: UIImageView!
    let helper = HelperFunctions()
    var userRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfilePicture.imageTapped(gesture:)))
        userRef = Database.database().reference().child("Users").child(helper.MD5(string: (Auth.auth().currentUser?.email)!))
        self.navigationController?.navigationBar.isHidden = true
        profilePicture.cornerRadius = profilePicture.frame.width/2
        // add it to the image view;
        profilePicture.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        profilePicture.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        gradientView.animationDuration = 3.0
        gradientView.setColors([#colorLiteral(red: 0.3476088047, green: 0.1101973727, blue: 0.08525472134, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)])
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
        
        let storageRef = Storage.storage().reference(forURL: "gs://intima-227c4.appspot.com").child("profile_image").child(helper.MD5(string: (Auth.auth().currentUser?.email)!))
        
        if let profileImg = profilePicture.image, let imageData = UIImageJPEGRepresentation(profileImg, 0.1){
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    return
                }
                
                let profileImgURL = metadata?.downloadURL()?.absoluteString
                let profile = Auth.auth().currentUser?.createProfileChangeRequest()
                profile?.photoURL = URL(string: profileImgURL!)
                profile?.commitChanges(completion: { (err) in
                    if err != nil{
                        return
                    }
                })
                let imgValues = ["photoURL":profileImgURL]
                self.userRef.updateChildValues(imgValues)
            })
        }
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
