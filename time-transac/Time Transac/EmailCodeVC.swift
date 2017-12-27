//
//  EmailCodeVC.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 8/6/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Pastel
import Firebase

class EmailCodeVC: UIViewController {

    
   
    @IBOutlet weak var gradientView: PastelView!
    @IBOutlet weak var continueAnimation: UIView!
    @IBOutlet weak var continueButton: UIButton!
    var firstName: String!
    var lastName:String!
    var email: String!
    var password: String!
    let service: ServiceCalls = ServiceCalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.gradientView.animationDuration = 3.0
        gradientView.setColors([#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)])
        
//        let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
//    @objc func timerAction(timer: Timer){
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        Auth.auth().currentUser?.reload(completion: { (error) in
//            if error == nil{
//                if appDelegate.counter > 0 && (Auth.auth().currentUser?.isEmailVerified)!{
//                    timer.invalidate()
//                    self.addNewUserToDBJson()
//                    print("VERIFIED!")
//                }
//                // if timer runs out delete account
//                else if appDelegate.counter <= 0 && !(Auth.auth().currentUser?.isEmailVerified)!{
//                    timer.invalidate()
//                    appDelegate.setLogoutAsRoot()
//                    Auth.auth().currentUser?.delete(completion: { (error) in
//                        if let error = error{
//                            print(error.localizedDescription)
//                        }else{
//                            print("account deleted")
//                        }
//                    })
//                }
//                else{
//                    print("STILL COUNTING")
//                    appDelegate.counter -= 1
//                }
//            }
//            else{
//                print(error?.localizedDescription)
//            }
//        })
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.gradientView.startAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.gradientView.startAnimation()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueClicked(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if(error != nil){
                
                let errorAnim = self.view.returnHandledAnimation(filename: "error", subView: self.continueAnimation, tagNum: 2)
                self.continueButton.isHidden = true
                errorAnim.play()
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    self.continueAnimation.makeAnimationDissapear(tag: 2)
                    self.continueButton.isHidden = false
                }
                return
            }
                
            else if !((user?.isEmailVerified)!){
                let errorAnim = self.view.returnHandledAnimation(filename: "error", subView: self.continueAnimation, tagNum: 2)
                self.continueButton.isHidden = true
                errorAnim.play()
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    self.continueAnimation.makeAnimationDissapear(tag: 2)
                    self.continueButton.isHidden = false
                }
                return
            }
            else{
                
                let check = self.view.returnHandledAnimation(filename: "check", subView: self.continueAnimation, tagNum: 1)
                self.continueButton.isHidden = true
                check.play()
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    self.performSegue(withIdentifier: "goToAllSet", sender: nil)
                }
            }
        }
        
    }
    
    

    
//    //TO-DO: store every info in the database and verify
//    func addNewUserToDBJson(){
//        let dbRef = Database.database().reference()
//        let rating: Float = 5.0
//
////        let newUserUID = Auth.auth().currentUser?.uid
//        let emailHash = service.MD5(string: (Auth.auth().currentUser?.email)!)
//
//        //dbRef.child("Users").child(emailHash).child("uid").setValue(newUserUID)
////        dbRef.child("Users").child(emailHash).child("uid").setValue(newUserUID)
//
//        dbRef.child("Users").child(emailHash).child("Name").setValue(Auth.auth().currentUser?.displayName)
//        dbRef.child("Users").child(emailHash).child("Email").setValue(Auth.auth().currentUser?.email)
//        dbRef.child("Users").child(emailHash).child("Rating").setValue(rating)
//        dbRef.child("Users").child(emailHash).child("Ratings Sum").setValue(0)
//        dbRef.child("Users").child(emailHash).child("currentDevice").setValue(AppDelegate.DEVICEID)
//    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */

}
