//
//  EmailVerifyVC.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 8/6/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Lottie
import Pastel
import Firebase
import Material

class EmailVerifyVC: UIViewController {

    @IBOutlet weak var gradientView: PastelView!
    @IBOutlet weak var emailTF: TextField!
    @IBOutlet weak var passwordTF: TextField!
    @IBOutlet weak var continueButtonEmail: UIButton!
    @IBOutlet weak var emailCheckAnimation: UIView!
    var firstName : String!
    var lastName: String!
    var dbRef : DatabaseReference!
    var newUserUID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidAppear(true)
        dbRef = Database.database().reference()
        self.prepareTitleTextField()
        self.navigationController?.navigationBar.isHidden = false
        gradientView.animationDuration = 3.0
        gradientView.setColors([#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)])
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.gradientView.startAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.continueButtonEmail.makeButtonAppear()
        self.gradientView.startAnimation()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueButtonEmail(_ sender: UIButton) {
        
        
        if (emailTF?.text?.isEmpty != true && passwordTF?.text?.isEmpty != true){

            let checkEmail = self.view.returnHandledAnimation(filename: "check", subView: emailCheckAnimation, tagNum: 1)
            let loadingAnimation = self.view.returnHandledAnimation(filename: "loading", subView: emailCheckAnimation, tagNum: 2)
            self.continueButtonEmail.makeButtonDissapear()
            loadingAnimation.play()
            loadingAnimation.loopAnimation = true
            Auth.auth().createUser(withEmail: emailTF.text!, password: passwordTF.text!, completion: { (user, error) in
                if (error != nil){
                    
                    self.emailCheckAnimation.makeAnimationDissapear(tag: 2)
                    let errorEmail = self.view.returnHandledAnimation(filename: "error", subView: self.emailCheckAnimation, tagNum: 3)
                    errorEmail.play()
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when){
                        self.emailCheckAnimation.makeAnimationDissapear(tag: 3)
                        self.continueButtonEmail.makeButtonAppear()
                    }
                    print(error as Any)
                    return
                }
                else{
                    self.emailCheckAnimation.makeAnimationDissapear(tag: 2)
                    self.addNewUserToDBJson()
                    user?.sendEmailVerification()
                    let profile = user?.createProfileChangeRequest()
                    profile?.displayName = "\(self.firstName!) \(self.lastName!)"
                    profile?.commitChanges(completion: { (error2) in
                        if (error2 != nil){
                            let errorEmail = self.view.returnHandledAnimation(filename: "error", subView: self.emailCheckAnimation, tagNum: 3)
                            errorEmail.play()
                            let when = DispatchTime.now() + 2
                            DispatchQueue.main.asyncAfter(deadline: when){
                                self.emailCheckAnimation.makeAnimationDissapear(tag: 3)
                                self.continueButtonEmail.makeButtonAppear()
                            }
                            print(error as Any)
                            return
                        }
                        else{
                            self.emailCheckAnimation.handledAnimation(Animation: checkEmail)
                            self.continueButtonEmail.makeButtonDissapear()
                            checkEmail.play()
                            let when = DispatchTime.now() + 2
                            DispatchQueue.main.asyncAfter(deadline: when){
                                checkEmail.stop()
                                self.performSegue(withIdentifier: "ToEmailCodeVC", sender: self)
                                
                            }
                        }
                    })
                }
            })
        }
        else{
            let errorEmail = self.view.returnHandledAnimation(filename: "error", subView: emailCheckAnimation, tagNum: 3)
            self.continueButtonEmail.isHidden = true
            errorEmail.play()
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                self.emailCheckAnimation.makeAnimationDissapear(tag: 3)
                self.continueButtonEmail.isHidden = false
                
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToEmailCodeVC"){
            if let destination = segue.destination as? EmailCodeVC{
                destination.firstName = firstName
                destination.lastName = lastName
                destination.email = emailTF.text
                destination.password = passwordTF.text
            }
        }
    }
    
    func prepareTitleTextField(){
        
        self.emailTF.placeholderLabel.font = UIFont(name: "Century Gothic", size: 17)
        self.emailTF.font = UIFont(name: "Century Gothic", size: 17)
        self.emailTF.textColor = Color.white
        self.emailTF.placeholder = "Email"
        self.emailTF.placeholderActiveColor = Color.white
        self.emailTF.placeholderNormalColor = Color.white
        self.passwordTF.placeholderLabel.font = UIFont(name: "Century Gothic", size: 17)
        self.passwordTF.font = UIFont(name: "Century Gothic", size: 17)
        self.passwordTF.textColor = Color.white
        self.passwordTF.placeholder = "Password"
        self.passwordTF.placeholderActiveColor = Color.white
        self.passwordTF.placeholderNormalColor = Color.white
        
        
    }
    
    func MD5(string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    

    func addNewUserToDBJson(){

        let rating: Float = 5.0

        self.newUserUID = Auth.auth().currentUser?.uid
        let emailHash = MD5(string: self.emailTF.text!)

        self.dbRef.child("Users").child(emailHash).child("uid").setValue(self.newUserUID)
        self.dbRef.child("Users").child(emailHash).child("Name").setValue("\(firstName!) \(lastName!)")
        self.dbRef.child("Users").child(emailHash).child("Email").setValue(emailTF.text)
        self.dbRef.child("Users").child(emailHash).child("Rating").setValue(rating)
        self.dbRef.child("Users").child(emailHash).child("Ratings Sum").setValue(0)
        self.dbRef.child("Users").child(emailHash).child("currentDevice").setValue(AppDelegate.DEVICEID)
    }



}
