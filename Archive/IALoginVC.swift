//
//  IALoginVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/17/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IALoginVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "https://archive.org/account/login.php")!))
        webView.delegate = self
        self.view.layer.cornerRadius = 20
//        webView.layer.cornerRadius = 20
        webView.hidden = true

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let
            headerFields = webView.request?.allHTTPHeaderFields ,
            URL = webView.request?.URL
        {
            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: NSURL(string: "https://archive.org/account/login.php")!)
            let availableCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: "https://archive.org/account/login.php")!)
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
                self.dismissViewControllerAnimated(true, completion: nil)
                IALoginManager.login(username!)
            }else if webView.scrollView.contentOffset.y == 0 {
                webView.stringByEvaluatingJavaScriptFromString("document.getElementById('navwrap1').style.display = 'none'")
                webView.hidden = false
            }
            print(availableCookies)
        }
        
//        let availableCookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: "https://archive.org/account/login.php")!)

    }
}
