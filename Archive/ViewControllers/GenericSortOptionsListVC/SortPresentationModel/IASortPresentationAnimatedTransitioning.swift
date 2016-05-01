//
//  IASortPresentationAnimatedTransitioning.swift
//  Archive
//
//  Created by Mejdi Lassidi on 2/7/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IASortPresentationAnimatedTransitioning: NSObject,UIViewControllerAnimatedTransitioning {
    var isPresentation: Bool?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if (self.isPresentation!) {
            
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            toView!.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height, toView!.frame.size.width, toView!.frame.size.height);
            UIView.animateWithDuration(0.25 ,animations:{()->() in
                toView!.frame = CGRectMake(0, 0, toView!.frame.size.width, toView!.frame.size.height);
                },completion:{ (Bool)->()  in
                    transitionContext.completeTransition(true)
            })
        }else
        {
            UIView.animateWithDuration(0.25 ,animations:{()->() in
                },completion:{ (Bool)->()  in
                    transitionContext.completeTransition(true)
            })
        }
        
    }
}
