//
//  IATabBarController.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/3/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import MBProgressHUD

class IATabBarController: UITabBarController {
    static let sharedInstance = (UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("iaTabbarVC") as! IATabBarController)
    var progressView : UIProgressView?
    var downloadProgress: Float {
        get {
            return progressView!.progress
        }
        set {
            dispatch_async(dispatch_get_main_queue()) {
                self.progressView?.progress = newValue
                if newValue > 0.0 {
                    self.progressView?.hidden = false
                    self.view.bringSubviewToFront(self.progressView!)
                }else {
                    self.progressView?.hidden = true
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        addProgressView()
        let downloadsToResume =  IADownloadsManager.sharedInstance.getChaptersInDownloadState()
        if downloadsToResume?.count > 0 {
            let alertView = UIAlertController(title: "Resume Download", message: "There are chapters where downloads are not accomplished yet, do you want to resume the downloads ?", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (_) in
                IADownloadsManager.sharedInstance.resumeDownloads()
            }))
            alertView.addAction(UIAlertAction(title: "No", style: .Cancel, handler: {_ in}))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    func addProgressView() {
        let window = UIApplication.sharedApplication().keyWindow!
        progressView = UIProgressView(progressViewStyle: .Default)
        progressView?.hidden = true
        window.addSubview(progressView!)
        progressView!.translatesAutoresizingMaskIntoConstraints = false
        
        window.addConstraint(NSLayoutConstraint(item: progressView!  , attribute: .Leading, relatedBy: .Equal, toItem: window, attribute: .Leading, multiplier: 1.0, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: progressView!  , attribute: .Trailing , relatedBy: .Equal, toItem: window, attribute: .Trailing, multiplier: 1.0, constant: 0))
        window.addConstraint(NSLayoutConstraint(item: progressView!  , attribute: .Top , relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1.0, constant: 64))
    }
    
    func downloadDone() {
        let window = UIApplication.sharedApplication().keyWindow!
        let doneView = MBProgressHUD.showHUDAddedTo(window, animated: true)
        doneView.mode = .CustomView
        doneView.labelText = "Done"
        doneView.customView = UIImageView(image: UIImage(named: "done_btn"))
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue(),{
            MBProgressHUD.hideHUDForView(window ,animated:true)
        })
    }
}
