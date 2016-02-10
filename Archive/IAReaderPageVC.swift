//
//  IAReaderPageVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/11/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import DGActivityIndicatorView
import AVFoundation

class IAReaderPageVC: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var imageView: UIImageView?
    var image: UIImage?
    var pageNumber : Int?
    var imagesDownloader : IABookImagesManager!
    lazy var activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
    
    //Pan Gesture Variables
    var panStartPosition: CGFloat?
    var panPositionProgress: CGFloat?
    var zoomScale: CGFloat?
    var zoomOffset: CGPoint?
    var zoomed = false
    
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
                        mySelf.updateImage(image)
                    })
                }
            }
            
        }
    }
    
    
    func goNextPage() {
        if let reader = self.parentViewController?.parentViewController where reader.isKindOfClass(IAReaderVC) {
                (reader as! IAReaderVC).goNextPage()
        }else if let readerVC = self.parentViewController where readerVC.isKindOfClass(IAReaderVC) {
            (readerVC as! IAReaderVC).goNextPage()
        }else {
            print("reader is kind of \(self.parentViewController)")
        }
    }
    
    
    func goPreviousPage() {
        if let reader = self.parentViewController?.parentViewController where reader.isKindOfClass(IAReaderVC) {
            (reader as! IAReaderVC).goPreviousPage()
        }else if let readerVC = self.parentViewController where readerVC.isKindOfClass(IAReaderVC) {
            (readerVC as! IAReaderVC).goPreviousPage()
        }else {
            print("reader is kind of \(self.parentViewController)")
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
        if let  scale = self.zoomScale , zoomOffset =  self.zoomOffset{
            if (scrollView.contentOffset.x != 0 && scrollView.zoomScale == scale && self.zoomed) {
                var offset = scrollView.contentOffset
                offset.x = zoomOffset.x
                scrollView.contentOffset = offset
            }
            
        }
        
    }
    
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.zoomed = false
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
        
        }
    }
    
    
    //MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.isKindOfClass(UIPinchGestureRecognizer) {
            return false
        }else {
            return true
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
                if let image = self.image, imageView = self.imageView {
                    let imageRect = AVMakeRectWithAspectRatioInsideRect(image.size, imageView.frame)
                    let scale = self.view.frame.size.width/imageRect.width
                    let zoomRect = self.zoomRectForScale(scale, center: CGPointMake(self.view.center.x , recognizer.locationInView(recognizer.view).y) )
                    self.scrollView?.zoomToRect(zoomRect, animated: true)
                    self.zoomScale = scale
                    self.zoomOffset = self.scrollView.contentOffset
                    self.zoomed = true
                }
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
    
    @IBAction func scrollViewPangestureHandler(sender: AnyObject) {
        let pangesture = sender as! UIPanGestureRecognizer
        
        if pangesture.state == .Changed {
        }else if pangesture.state == .Began {
            self.panStartPosition = pangesture.translationInView(pangesture.view).x
        } else if pangesture.state == .Ended {
            if pangesture.translationInView(pangesture.view).x - self.panStartPosition! > 100 && (self.scrollView.contentOffset.x<10 || self.zoomed ) {
                self.goPreviousPage()
            } else if pangesture.translationInView(pangesture.view).x - self.panStartPosition! < 100 && (self.scrollView.contentOffset.x + self.scrollView.frame.size.width >  self.scrollView.contentSize.width - 10 || self.zoomed){
                self.goNextPage()
            }
        }
        
    }
    //MARK: Setter
    
    func updateImage(image: UIImage) {
        self.image = image
        self.imageView?.image = image
        self.reScaleScrollView(image)
    }
    
    func reScaleScrollView(image: UIImage) { 
        let imageRect = AVMakeRectWithAspectRatioInsideRect(image.size, imageView!.frame)
        let scale = self.view.frame.size.width/imageRect.width
        let zoomRect = self.zoomRectForScale(scale, center: self.scrollView.center)
        self.scrollView?.zoomToRect(zoomRect, animated: false)
        self.scrollView.scrollRectToVisible(CGRectMake(self.scrollView.contentOffset.x, 0, zoomRect.width, zoomRect.height), animated: false)
        self.zoomScale = scale
        self.zoomOffset = self.scrollView.contentOffset
        self.zoomed = true
    }
    
    //MARK: Device orientation
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        reScaleScrollView()
    }
    
    func reScaleScrollView() {
        if let image = self.image {
            self.reScaleScrollView(image)
        }
    }
}
