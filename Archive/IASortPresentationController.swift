//
//  IASortPresentationController.swift
//  Archive
//
//  Created by Mejdi Lassidi on 2/7/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IASortPresentationController: UIPresentationController {
    var chromeView : UIView?
    var centerX: NSLayoutConstraint?
    var centerY: NSLayoutConstraint?
    
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        self.chromeView = UIView()
        self.chromeView!.backgroundColor = UIColor(white: 0, alpha: 0.4)
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
  
  }
    
    override func containerViewWillLayoutSubviews () {
        UIView.animateWithDuration(0.25){ ()->() in
            self.presentedView()!.translatesAutoresizingMaskIntoConstraints = false

            self.presentedView()!.addConstraint(NSLayoutConstraint(item: self.presentedView()!  , attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: 300))
            self.presentedView()!.addConstraint(NSLayoutConstraint(item: self.presentedView()!  , attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: 300))
            

        }
    }

    
    func chromeviewTapped(gesture: UIGestureRecognizer) {
        if (gesture.state == .Ended) {
            self.presentedViewController.dismissViewControllerAnimated(true) { ()->() in
                self.chromeView!.alpha = 0.0;
            }
        }
    }
    
    override func presentationTransitionWillBegin() {
        
        
        self.containerView!.insertSubview(self.chromeView! ,atIndex:0)
        self.chromeView!.translatesAutoresizingMaskIntoConstraints = false

        self.containerView!.addConstraint(NSLayoutConstraint(item: self.chromeView!  , attribute: .Width, relatedBy: .Equal, toItem: self.containerView, attribute: .Width, multiplier: 1.0, constant: 0))
        self.containerView!.addConstraint(NSLayoutConstraint(item: self.chromeView!  , attribute: .Height, relatedBy: .Equal, toItem: self.containerView, attribute: .Height, multiplier: 1.0, constant: 0))
               self.chromeView!.alpha = 0.0


        let tap = UITapGestureRecognizer(target:self ,action: "chromeviewTapped:")
        self.chromeView!.addGestureRecognizer(tap)

        self.presentedViewController.transitionCoordinator()!.animateAlongsideTransition({(UIViewControllerTransitionCoordinatorContext) -> () in
            self.chromeView!.alpha = 1.0
            self.containerView!.addSubview(self.presentedView()!)
            self.centerX = NSLayoutConstraint(item: self.presentedView()!  , attribute: .CenterX, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterX, multiplier: 1.0, constant: 0)
            self.centerY = NSLayoutConstraint(item: self.presentedView()!  , attribute: .CenterY, relatedBy: .Equal, toItem: self.containerView, attribute: .CenterY, multiplier: 1.0, constant: 0)
            self.containerView!.addConstraints([self.centerX!, self.centerY!])

            }, completion:{(Bool)->() in
                
        })
    }

    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator()!.animateAlongsideTransition({(UIViewControllerTransitionCoordinatorContext) -> () in
            self.chromeView!.alpha = 0.0
            if let presentedView = self.presentedView(){
                presentedView.transform = CGAffineTransformMakeTranslation(0, (self.containerView?.frame.size.height)!/2)
            }
            }, completion:{(Bool)->() in
                self.presentedView()!.removeFromSuperview()
                
        })
    }

    override func dismissalTransitionDidEnd(completed: Bool) {
    }

    override func adaptivePresentationStyle()->UIModalPresentationStyle {
        return .Custom
    }

    override func shouldPresentInFullscreen()->Bool {
        return false
    }

}
