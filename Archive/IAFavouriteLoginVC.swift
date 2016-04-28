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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAFavouriteLoginVC.userDidLogin), name: notificationUserDidLogin, object: nil)

        activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func presentLoginscreen(sender: AnyObject) {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! IALoginVC
        loginVC.transitioningDelegate = sortPresentationDelegate
        loginVC.modalPresentationStyle = .Custom
        loginVC.dismissCompletion = {
            self.addLoadingView()
        }
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
    //MARK: Login Notification
    
    func userDidLogin() {
        removeLoadingView()
    }
    
    
    //MARK: IALoadingViewProtocol
    
    func addLoadingView() {
        if let activityIndicatorView = activityIndicatorView {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addConstraint(NSLayoutConstraint(item: activityIndicatorView  , attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
            
            self.view.addConstraint(NSLayoutConstraint(item:  activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem:self.view , attribute: .CenterY, multiplier: 1.0, constant: 50))
        }
    }
}
