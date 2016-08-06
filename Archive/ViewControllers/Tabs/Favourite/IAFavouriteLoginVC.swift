//
//  IAFavouriteLoginVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/26/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import DGActivityIndicatorView
class IAFavouriteLoginVC: UIViewController,  IALoadingViewProtocol{
    var sortPresentationDelegate =  IASortPresentationDelgate()
    var activityIndicatorView : DGActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(IAFavouriteLoginVC.userDidLogin),
                                                         name: Constants.Notification.UserDidLogin.name,
                                                         object: nil)

        activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func presentLoginscreen(sender: AnyObject) {
        let loginVC = storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! IALoginVC
        loginVC.transitioningDelegate = sortPresentationDelegate
        loginVC.modalPresentationStyle = .Custom
        loginVC.dismissCompletion = {
            self.addLoadingView()
        }
        loginVC.loadingHandler = { loading in
            self.sortPresentationDelegate.noDismissOnTapWhileLoading = loading
        }
        presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
    //MARK: Login Notification
    
    func userDidLogin() {
        removeLoadingView()
    }
    
    
    //MARK: IALoadingViewProtocol
    
    func addLoadingView() {
        if let activityIndicatorView = activityIndicatorView {
            view.addSubview(activityIndicatorView)
            
            activityIndicatorView.startAnimating()
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            
            let constraintOne = NSLayoutConstraint(item: activityIndicatorView,
                                                   attribute: .CenterX,
                                                   relatedBy: .Equal,
                                                   toItem:view,
                                                   attribute: .CenterX,
                                                   multiplier: 1.0,
                                                   constant: 0)
            
            let constraintTwo = NSLayoutConstraint(item: activityIndicatorView,
                                                   attribute: .CenterY,
                                                   relatedBy: .Equal,
                                                   toItem:view,
                                                   attribute: .CenterY,
                                                   multiplier: 1.0,
                                                   constant: 50)
            
            view.addConstraints([constraintOne, constraintTwo])
        }
    }
}
