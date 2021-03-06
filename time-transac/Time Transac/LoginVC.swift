//
//  LoginVC.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-06-22.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Lottie
import Firebase
import Pastel
import Material


class LoginVC: UIViewController {

    @IBOutlet weak var gradientViewLogin: PastelView!
    @IBOutlet weak var emailTF: TextField!
    @IBOutlet weak var passwordTF: TextField!
    @IBOutlet weak var passwordanim: UIView!
    @IBOutlet weak var usernameanim: UIView!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var loginButtonView: UIButton!
    @IBOutlet weak var forgetPassword: UIButton!
    let animationView = LOTAnimationView(name: "outline_user")
    let animationViewTwo = LOTAnimationView(name: "simple_outline_lock_")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        super.viewDidAppear(true)
        prepareTitleTextField()
        self.navigationController?.navigationBar.isHidden = false
        gradientViewLogin.animationDuration = 3.0
        gradientViewLogin.setColors([#colorLiteral(red: 0.3476088047, green: 0.1101973727, blue: 0.08525472134, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)])
        self.hideKeyboardWhenTappedAround()
        self.usernameanim.handledAnimation(Animation: animationView)
        self.passwordanim.handledAnimation(Animation: animationViewTwo)
        animationView.play()
        animationViewTwo.play()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.loginButtonView.makeButtonAppear()
        self.forgetPassword.makeButtonAppear()
        gradientViewLogin.startAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        gradientViewLogin.startAnimation()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goPressed(_ sender: Any) {
        
        // check if fields are not empty
        self.dismissKeyboard()
        self.loginButtonView.makeButtonDissapear()
        self.forgetPassword.makeButtonDissapear()
        self.subview.isHidden = false
        
        if (emailTF.text?.isEmpty == true || passwordTF.text?.isEmpty == true){
            self.view.returnHandledAnimation(filename: "error", subView: subview, tagNum: 1).play()
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.loginButtonView.makeButtonAppear()
                self.forgetPassword.makeButtonAppear()
                self.subview.makeAnimationDissapear(tag: 1)
                return
            }
        }
            
            // check if email is in database and password are correct
            
        else{
            
            let loadingAnim = self.view.returnHandledAnimation(filename: "loading", subView: subview, tagNum: 3)
            loadingAnim.play()
            loadingAnim.loopAnimation = true
            Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!, completion: { (user, error) in
                // do some error checking
                if (error != nil || !(user?.isEmailVerified)!){
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                        loadingAnim.stop()
                        self.subview.makeAnimationDissapear(tag: 3)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        self.view.returnHandledAnimation(filename: "error", subView: self.subview, tagNum: 2).play()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5){
                        self.loginButtonView.makeButtonAppear()
                        self.forgetPassword.makeButtonAppear()
                        self.subview.makeAnimationDissapear(tag: 2)
                    }
                    return
                }
                    
                else if (error == nil && (user?.isEmailVerified)!){
                    
                    // else perform segue
                    
                    let ref = Database.database().reference().child("Users").child(self.MD5(string: (user?.email)!))
                    let token = ["currentDevice": AppDelegate.DEVICEID]
                    ref.updateChildValues(token)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                        loadingAnim.stop()
                        self.subview.makeAnimationDissapear(tag: 3)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        self.view.returnHandledAnimation(filename: "check", subView: self.subview, tagNum: 1).play()
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: {
                        self.subview.makeAnimationDissapear(tag: 1)
                        self.subview.makeAnimationDissapear(tag: 2)
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.isLaunched = false
                        print(appDelegate.isLaunched)
                        appDelegate.setLoginAsRoot()
                        
                        
                    })
                }
            })
        }
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        // check if fields are not empty
        
        self.loginButtonView.makeButtonDissapear()
        self.forgetPassword.makeButtonDissapear()
        self.subview.isHidden = false
        
        if (emailTF.text?.isEmpty == true || passwordTF.text?.isEmpty == true){
            self.view.returnHandledAnimation(filename: "error", subView: subview, tagNum: 1).play()
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.loginButtonView.makeButtonAppear()
                self.forgetPassword.makeButtonAppear()
                self.subview.makeAnimationDissapear(tag: 1)
                return
            }
        }
        
        // check if email is in database and password are correct

        else{
            
            let loadingAnim = self.view.returnHandledAnimation(filename: "loading", subView: subview, tagNum: 3)
            loadingAnim.play()
            loadingAnim.loopAnimation = true
            Auth.auth().signIn(withEmail: emailTF.text!, password: passwordTF.text!, completion: { (user, error) in
                // do some error checking
                if (error != nil || !(user?.isEmailVerified)!){
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                        loadingAnim.stop()
                        self.subview.makeAnimationDissapear(tag: 3)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        self.view.returnHandledAnimation(filename: "error", subView: self.subview, tagNum: 2).play()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5){
                        self.loginButtonView.makeButtonAppear()
                        self.forgetPassword.makeButtonAppear()
                        self.subview.makeAnimationDissapear(tag: 2)
                    }
                    return
                }
                    
                else if (error == nil && (user?.isEmailVerified)!){
                    
                    // else perform segue
                    
                    let ref = Database.database().reference().child("Users").child(self.MD5(string: (user?.email)!))
                    let token = ["currentDevice": AppDelegate.DEVICEID]
                    ref.updateChildValues(token)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                        loadingAnim.stop()
                        self.subview.makeAnimationDissapear(tag: 3)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        self.view.returnHandledAnimation(filename: "check", subView: self.subview, tagNum: 1).play()

                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: {
                        self.subview.makeAnimationDissapear(tag: 1)
                        self.subview.makeAnimationDissapear(tag: 2)
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.isLaunched = false
                        print(appDelegate.isLaunched)
                        appDelegate.setLoginAsRoot()
                        
                        
                    })
                }
            })
        }
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
    
    
    func ERR_User_Info_Wrong(){
        
        //Load and play error animation
        
        let animationViewFour = LOTAnimationView(name: "x_pop")
        self.subview.addSubview(animationViewFour)
        animationViewFour.frame = CGRect(x: 0, y: 0, width: 88, height: 63)
        animationViewFour.contentMode = .scaleAspectFill
        animationViewFour.play()
    }
    
    
    func ERR_Empty_Fields(){
        
        //Load and play error animation
        
        let animationViewFour = LOTAnimationView(name: "x_pop")
        self.subview.addSubview(animationViewFour)
        animationViewFour.frame = CGRect(x: 0, y: 0, width: 88, height: 63)
        animationViewFour.contentMode = .scaleAspectFill
        animationViewFour.play()
    }
    

}
