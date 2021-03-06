//
//  Lgsupage.swift
//  Time Transac
//
//  Created by Srikanth Srinivas on 7/29/17.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import AVFoundation
import Lottie
import FBSDKLoginKit
import FBSDKCoreKit
import Material
import Firebase
import RevealingSplashView


class Lgsupage: UIViewController {
    @IBOutlet weak var facebookLoginButton: RaisedButton!
    
    var Player: AVPlayer!
    var PlayerLayer: AVPlayerLayer!
    var contentlist = ["Welcome to Intima, the worlds first market place for time.","Buy or sell free time from other Intima users.", "Whether it's Moving boxes, babysitting or running errands, monetize your idle time.", "Make your day more efficient, buying time from others for tasks that drain your productivity.","Get started today"]
    

    @IBOutlet var IntimaLogo: UIView!
    @IBOutlet var IntimaLabel: UILabel!
    @IBOutlet var LoginButton: UIButton!
    @IBOutlet var SignUpButton: UIButton!

    var dbRef: DatabaseReference!
    let logoAnimation = LOTAnimationView(name: "clock")
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Player.play()
        
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.dbRef = Database.database().reference()
        self.navigationController?.navigationBar.isHidden = true
        IntimaLabel.adjustsFontSizeToFitWidth = true
        IntimaLogo.handledAnimation(Animation: logoAnimation)
        logoAnimation.play()
        //Load video background
        
        let URL = Bundle.main.url(forResource: "lgsu", withExtension: "mp4")
        
        Player = AVPlayer.init(url: URL!)
        Player.allowsExternalPlayback = true
        Player.isMuted = true
        PlayerLayer = AVPlayerLayer(player: Player)
        PlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        PlayerLayer.frame = view.layer.frame
        
        Player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
        Player.play()
 
        view.layer.insertSublayer(PlayerLayer, at: 0)
        NotificationCenter.default.addObserver(self,selector: #selector(appWillEnterForegroundNotification),name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: Player.currentItem)
        
        
    }
    
    
    
    //Handle the swipes
    
    
    @IBAction func loginWithFacebookClicked(_ sender: Any) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    @objc func appWillEnterForegroundNotification() {
        
        Player.play()
    }

    @objc func playerItemReachEnd(notification:NSNotification){
        
        Player.seek(to:kCMTimeZero)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works
                    
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Auth.auth().signIn(with: credential) { (user, error) in
                        if error != nil {
                            print(error as Any)
                            return
                        }
                        
                        print("Signed in with Facebook")
                        let data = result as! [String: AnyObject]
                        let FBid = data["id"] as? String
                        let url = URL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                        let profile = user?.createProfileChangeRequest()
                        profile?.photoURL = url
                        profile?.commitChanges(completion: { (err) in
                            if err != nil{
                                print(err?.localizedDescription ?? "")
                            }else{
                                let emailHash = self.MD5(string: (user?.email)!)
                                self.dbRef.child("Users").child(emailHash).child("photoURL").setValue(url?.absoluteString)
                            }
                        })
                        
                        self.addNewUserToDBJson(user: user!)
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.setLoginAsRoot()
                    }
                }
                else{
                    print(error?.localizedDescription ?? "")
                    return
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
    
    func addNewUserToDBJson(user: User){
        
        let rating: Float = 5.0
        let emailHash = MD5(string: user.email!)
        let token = ["currentDevice" : AppDelegate.DEVICEID]
        dbRef.child("Users").child(emailHash).child("uid").setValue(user.uid)
        dbRef.child("Users").child(emailHash).child("Name").setValue("\(user.displayName!)")
        dbRef.child("Users").child(emailHash).child("Email").setValue(user.email)
        dbRef.child("Users").child(emailHash).child("Rating").setValue(rating)
        dbRef.child("Users").child(emailHash).child("Ratings Sum").setValue(0)
        dbRef.child("Users").child(emailHash).updateChildValues(token)
    }
    
}



