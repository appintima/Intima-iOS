//
//  ScrollViewController.swift
//  ISHPullUpSample
//
//  Created by Felix Lamouroux on 25.06.16.
//  Copyright © 2016 iosphere GmbH. All rights reserved.
//

import UIKit
import ISHPullUp

class BottomVC: UIViewController, ISHPullUpSizingDelegate, ISHPullUpStateDelegate {
    
    @IBOutlet private weak var rootView: UIView!
    
    
    
    private var firstAppearanceCompleted = false
    weak var pullUpController: ISHPullUpViewController!
    private var pullupWasClosed = true
    
    // we allow the pullUp to snap to the half way point
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAppearanceCompleted = true;
    }
    
    
    
    
    // MARK: ISHPullUpSizingDelegate
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, maximumHeightForBottomViewController bottomVC: UIViewController, maximumAvailableHeight: CGFloat) -> CGFloat {
        
        let totalHeight = rootView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        // we allow the pullUp to snap to the half way point
        // we "calculate" the cached value here
        // and perform the snapping in ..targetHeightForBottomViewController..
        return totalHeight
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, minimumHeightForBottomViewController bottomVC: UIViewController) -> CGFloat {
        return 100
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, targetHeightForBottomViewController bottomVC: UIViewController, fromCurrentHeight height: CGFloat) -> CGFloat {
        
        if pullupWasClosed{
            return self.rootView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        }
            
        else{
            return 100
        }
        
    }
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, update edgeInsets: UIEdgeInsets, forBottomViewController bottomVC: UIViewController) {
        // we update the scroll view's content inset
        // to properly support scrolling in the intermediate states
        //        scrollView.contentInset = edgeInsets;
    }
    
    // MARK: ISHPullUpStateDelegate
    
    func pullUpViewController(_ pullUpViewController: ISHPullUpViewController, didChangeTo state: ISHPullUpState) {
        
        if state == .collapsed{
            self.pullupWasClosed = true
        }
        
        if state == .expanded{
            self.pullupWasClosed = false
        }
        //        // Hide the scrollview in the collapsed state to avoid collision
        //        // with the soft home button on iPhone X
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.rootView.alpha = (state == .collapsed) ? 0.25 : 1;
        }
    }
    
}

