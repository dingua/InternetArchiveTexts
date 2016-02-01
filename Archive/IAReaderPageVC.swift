//
//  IAReaderPageVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/11/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

class IAReaderPageVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView?
    var pageNumber : Int?
    var imagesDownloader : IABookImagesManager!
    lazy var activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updatePage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updatePage() {
        self.addLoadingView()
        self.imagesDownloader!.imageOfPage(self.pageNumber!){ [weak self](image: UIImage, page: Int)->() in
            if let mySelf = self {
                mySelf.removeLoadingView()
                if page == mySelf.pageNumber {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        mySelf.imageView!.image = image
                    })
                }
            }
            
        }
    }
    
    //MARK: Helpers
    
    func addLoadingView() {
        self.activityIndicatorView.frame = CGRectMake(self.view.center.x - 25, self.view.center.y - 25, 50, 50)
        self.view.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
    }
    
    func removeLoadingView() {
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.removeFromSuperview()
    }

}
