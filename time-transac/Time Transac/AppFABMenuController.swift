
import UIKit
import Material
import Firebase
import FBSDKLoginKit
import Stripe
import PopupDialog

class AppFABMenuController: FABMenuController, STPPaymentContextDelegate{
    fileprivate let fabMenuSize = CGSize(width: 40, height: 40)
    fileprivate let bottomInset: CGFloat = 50
    fileprivate let rightInset: CGFloat = 20
    
    fileprivate var fabButton: FABButton!
    fileprivate var logoutItem: FABMenuItem!
    fileprivate var unconfirmedItem: FABMenuItem!
    fileprivate var paymentMethodsItem: FABMenuItem!
    var paymentContext: STPPaymentContext? = nil
    
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print(error)
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        let source = paymentResult.source.stripeID
        MyAPIClient.sharedClient.addPaymentSource(id: source, completion: { (error) in })
    }
    
    
    open override func prepare() {
        super.prepare()
        view.backgroundColor = .white
        
        prepareFABButton()
        prepareLogoutFabMenuItem()
        prepareUnconfirmedFabMenuItem()
        preparePaymentMethodsItem()
        prepareFABMenu()
    }
}

extension AppFABMenuController {
    fileprivate func prepareFABButton() {
        fabButton = FABButton(image: Icon.cm.menu, tintColor: .white)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = Color.red.base
    }
    
    fileprivate func prepareLogoutFabMenuItem() {
        logoutItem = FABMenuItem()
        logoutItem.title = "Logout"
        logoutItem.fabButton.image = Icon.cm.clear
        logoutItem.fabButton.tintColor = .white
        logoutItem.fabButton.pulseColor = .white
        logoutItem.fabButton.backgroundColor = Color.blue.base
        logoutItem.fabButton.addTarget(self, action: #selector(handleLogout(button:)), for: .touchUpInside)
    }
    
    fileprivate func prepareUnconfirmedFabMenuItem() {
        unconfirmedItem = FABMenuItem()
        unconfirmedItem.title = "Unconfirmed Jobs"
        unconfirmedItem.fabButton.image = Icon.cm.bell
        unconfirmedItem.fabButton.tintColor = .white
        unconfirmedItem.fabButton.pulseColor = .white
        unconfirmedItem.fabButton.backgroundColor = Color.blue.base
        unconfirmedItem.fabButton.addTarget(self, action: #selector(handleUnconfirmed(button:)), for: .touchUpInside)
    }
    
    fileprivate func preparePaymentMethodsItem() {
        paymentMethodsItem = FABMenuItem()
        paymentMethodsItem.title = "Payment Methods"
        paymentMethodsItem.fabButton.image = Icon.cm.settings
        paymentMethodsItem.fabButton.tintColor = .white
        paymentMethodsItem.fabButton.pulseColor = .white
        paymentMethodsItem.fabButton.backgroundColor = Color.blue.base
        paymentMethodsItem.fabButton.addTarget(self, action: #selector(handlePaymentMethods(button:)), for: .touchUpInside)
    }
    
    
    fileprivate func prepareFABMenu() {
        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItems = [logoutItem, unconfirmedItem, paymentMethodsItem]
        fabMenuBacking = .none
        fabMenu.fabMenuDirection = .down
        
        view.layout(fabMenu)
            .top(bottomInset)
            .right(rightInset)
            .size(fabMenuSize)
    }
}

extension AppFABMenuController {
    @objc
    fileprivate func handleLogout(button: UIButton) {
        
        fabMenu.close()
        fabMenu.fabButton?.animate(.rotate(0))
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let facebookLoginManager = FBSDKLoginManager()
            facebookLoginManager.logOut()
            print("Logged out")
            self.navigationController?.popToRootViewController(animated: true)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setLogoutAsRoot()
            
        } catch let signOutError as NSError {
            let signOutErrorPopup = PopupDialog(title: "Error", message: "Error signing you out, try again later" + signOutError.localizedDescription )
            self.present(signOutErrorPopup, animated: true, completion: nil)
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @objc
    fileprivate func handleUnconfirmed(button: UIButton) {
        
        self.transition(to: UnconfirmedVC())
        fabMenu.fabButton?.animate(.rotate(0))
    }
    
    @objc
    fileprivate func handlePaymentMethods(button: UIButton) {
        self.paymentContext = STPPaymentContext(apiAdapter: CustomAPIAdapter())
        self.paymentContext!.delegate = self
        self.paymentContext!.hostViewController = self
        self.paymentContext!.presentPaymentMethodsViewController()
    }
}

extension AppFABMenuController {
    @objc
    open func fabMenuWillOpen(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(0))
        
        print("fabMenuWillOpen")
    }
    
    @objc
    open func fabMenuDidOpen(fabMenu: FABMenu) {
        print("fabMenuDidOpen")
    }
    
    @objc
    open func fabMenuWillClose(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(0))
        
        print("fabMenuWillClose")
    }
    
    @objc
    open func fabMenuDidClose(fabMenu: FABMenu) {
        print("fabMenuDidClose")
    }
    
}

