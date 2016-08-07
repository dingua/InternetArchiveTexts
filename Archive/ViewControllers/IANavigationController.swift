//
//  IANavigationController.swift
//  Archive
//
//  Created by Mejdi Lassidi on 8/7/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IANavigationController: UINavigationController {
 
    var progressView: UIProgressView?
    
    //MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addProgressView()
        IADownloadsManager.sharedInstance.addObserver(self, forKeyPath: "downloadProgress", options: .New, context: nil)
    }
    
    deinit {
        IADownloadsManager.sharedInstance.removeObserver(self, forKeyPath: "downloadProgress")
    }
    
    //MARK: - ProgressView UI
    
    func addProgressView() {
        progressView = UIProgressView(progressViewStyle: .Default)
        progressView?.hidden = true
        progressView?.tintColor = UIColor.blackColor()
        view.addSubview(progressView!)
        progressView!.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: progressView!  , attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: progressView!  , attribute: .Trailing , relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: progressView!  , attribute: .Top , relatedBy: .Equal, toItem: navigationBar, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    //MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "downloadProgress" {
            dispatch_async(dispatch_get_main_queue()) {
                let newValue = Float(change!["new"] as! Double)
                self.progressView?.progress = Float(change!["new"] as! Double)
                if newValue > 0.0 {
                    self.progressView?.hidden = false
                    self.view.bringSubviewToFront(self.progressView!)
                }else {
                    self.progressView?.hidden = true
                }
            }
        }
    }
}