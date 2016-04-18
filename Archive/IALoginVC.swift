//
//  IALoginVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/17/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IALoginVC: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func login(sender: AnyObject) {
        if let username = usernameField.text,  password =  passwordField.text{
            IALoginManager.login(username, password: password)
        }
    }
}
