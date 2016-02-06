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
//    lazy var activityIndicatorView = UIView()

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
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: self.activityIndicatorView  , attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item:  self.activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem:self.view , attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    func removeLoadingView() {
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.removeFromSuperview()
    }
    
    //MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
        
        }
    }
}
