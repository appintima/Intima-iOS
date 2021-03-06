//
//  AppDelegate.swift
//  Time Transac
//
//  Created by Gbenga Ayobami on 2017-06-06.
//  Copyright © 2017 Gbenga Ayobami. All rights reserved.
//

import UIKit
import Firebase
import Material
import UserNotifications
import FBSDKCoreKit
import Stripe
import RevealingSplashView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate{
    
    var isLaunched = false
    var window: UIWindow?
    var counter = 60
    static let NOTIFICATION_URL = "https://fcm.googleapis.com/fcm/send"
    static var DEVICEID = String()
    static let SERVERKEY = "AAAAMKQNFt8:APA91bGmSGBZeJMHDwqGOTSIAfYVb0aRxlG_e5Vey5DmFCdbTGYN_POi1CkprPV9mEn8rg7XLCuMUP4YgK-TuepamLbX0TOaGq9LAAWeml0A-4qK4A4WP15jAMgZlLgdf0JPq-kZ_kd3"
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        isLaunched = true
        FirebaseApp.configure()
        STPPaymentConfiguration.shared().publishableKey = "pk_test_K45gbx2IXkVSg4pfmoq9SIa9"
        STPPaymentConfiguration.shared().appleMerchantIdentifier = "merchant.online.intima"
        

        if (Auth.auth().currentUser != nil && (Auth.auth().currentUser?.isEmailVerified)!){
            self.goHome()
        }
        else{
            let providerData = Auth.auth().currentUser?.providerData
            if providerData != nil{
                for userInfo in providerData! {
                    if userInfo.providerID == "facebook.com" {
                        self.goHome()
                    }
                    else{
                        self.setLogoutAsRoot()
                    }
                }
            }
        }
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            let option : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: option, completionHandler: { (bool, error) in
                
            })
        }else{
            let settings : UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        return true
    }
    
    fileprivate func goHome(){
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = AppFABMenuController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rootAfterLogin"))
        window?.makeKeyAndVisible()
    }
    
    func setLogoutAsRoot(){
        
        window = UIWindow(frame: Screen.bounds)
        var options = UIWindow.TransitionOptions()
        options.direction = .toTop
        options.duration = 0.8
        options.style = .easeOut
        window!.setRootViewController((UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rootViewController")), options: options)
        window?.makeKeyAndVisible()
        
    }
    
    func setLoginAsRoot(){
        
        var options = UIWindow.TransitionOptions()
        options.direction = .toBottom
        options.duration = 0.8
        options.style = .easeIn
        self.window = UIWindow(frame: Screen.bounds)
        self.window!.setRootViewController(AppFABMenuController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "rootAfterLogin")), options: options)
        self.window?.makeKeyAndVisible()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
        
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        guard let newToken = InstanceID.instanceID().token() else{return}
        AppDelegate.DEVICEID = newToken
        connectToFCM()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification.request.content.body
        
        print(notification)
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        guard let token = InstanceID.instanceID().token() else{return}
        
        AppDelegate.DEVICEID = token
        connectToFCM()
    }
    
    func connectToFCM(){
        Messaging.messaging().shouldEstablishDirectChannel = true
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
    
}


