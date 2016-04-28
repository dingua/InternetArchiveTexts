//
//  IAFavouriteLoginVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 4/26/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAFavouriteLoginVC: UIViewController {
    var sortPresentationDelegate =  IASortPresentationDelgate()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func presentLoginscreen(sender: AnyObject) {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC")
        loginVC?.transitioningDelegate = sortPresentationDelegate
        loginVC?.modalPresentationStyle = .Custom
        self.presentViewController(loginVC!, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
