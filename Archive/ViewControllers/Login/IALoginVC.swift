//
//  IALoginVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/17/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import DGActivityIndicatorView


class IALoginVC: UIViewController, UIWebViewDelegate, IALoadingViewProtocol {
    var activityIndicatorView : DGActivityIndicatorView?
    var dismissCompletion: (()->())?
    let loginURL = "https://archive.org/account/login.php"
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "https://archive.org/account/login.php")!))
        webView.delegate = self
        self.view.layer.cornerRadius = 20
        webView.hidden = true
        activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        addLoadingView()
        webView.hidden = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let
            _ = webView.request?.allHTTPHeaderFields ,
            _ = webView.request?.URL
        {
            let availableCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: loginURL)!)
            var loggedIn = false
            var username : String?
            for cookie in availableCookies! {
                if cookie.name == "logged-in-sig" {
                    loggedIn = true
                    if let _ = username {
                        break
                    }
                    
                }else if cookie.name == "logged-in-user" {
                    username = cookie.value
                    if loggedIn {
                        break
                    }
                }
            }
            if loggedIn{
                self.dismissViewControllerAnimated(true, completion: {
                    if let dismissCompletion = self.dismissCompletion {
                        dismissCompletion()
                    }
                })
                IALoginManager.login(username!)
            }else if webView.scrollView.contentOffset.y == 0 {
                removeLoadingView()
                webView.stringByEvaluatingJavaScriptFromString("document.getElementById('navwrap1').style.display = 'none'")
                webView.hidden = false
            }
        }
    }
}
