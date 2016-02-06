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
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
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
    
    //MARK: IBACTION
    
    
    @IBAction func scrollViewDoubleTapped(sender: AnyObject) {
        let recognizer = sender as! UIGestureRecognizer

        if let scrollV = self.scrollView {
            if (scrollV.zoomScale > scrollV.minimumZoomScale) {
                scrollV.setZoomScale(scrollV.minimumZoomScale, animated: true)
            }
            else {
                //(I divide by 3.0 since I don't wan't to zoom to the max upon the double tap)
                let zoomRect = self.zoomRectForScale(2.0, center: recognizer.locationInView(recognizer.view))
                self.scrollView?.zoomToRect(zoomRect, animated: true)
            }
        }
    }
    
    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
        var zoomRect = CGRectZero
        if let imageV = self.imageView {
            zoomRect.size.height = imageV.frame.size.height / scale;
            zoomRect.size.width  = imageV.frame.size.width  / scale;
            let newCenter = imageV.convertPoint(center, fromView: self.scrollView)
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
        }
        return zoomRect;
    }
}
