//
//  IABookDetailsPresentationDelgate.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/27/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IABookDetailsPresentationDelgate: NSObject , UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimatedTransitioning = IASortPresentationAnimatedTransitioning()
        presentationAnimatedTransitioning.isPresentation = true
        return presentationAnimatedTransitioning
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimatedTransitioning = IASortPresentationAnimatedTransitioning()
        presentationAnimatedTransitioning.isPresentation = false
        return presentationAnimatedTransitioning
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentatioController = IABookDetailsPresentationController(presentedViewController: presented, presentingViewController: presenting)
        return presentatioController
        
    }
    
}
