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
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    var image: UIImage?
    var pageNumber : Int?
    var imagesDownloader : IABookImagesManager!
    lazy var activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
    
    //Pan Gesture Variables
    var panStartPosition: CGPoint?
    var panPositionProgress: CGFloat?
    var zoomScale: CGFloat?
    var zoomOffset: CGPoint?
    var zoomed = false
    var appeared = false
    var scaled = false // variable to check wether we did first scaling of the scrollview, once done we don't do again (except device rotation)
    
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        panGestureRecognizer.enabled = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let reader = parentViewController?.parentViewController where reader.isKindOfClass(IAReaderVC) {
            (reader as! IAReaderVC).pageControllerPanGestureEnabled(true)
        }
        appeared = true
        if image == nil {
            updatePage()
        }else {
            rescaleScrollView()
            panGestureRecognizer.enabled = true
            if let reader = parentViewController?.parentViewController where reader.isKindOfClass(IAReaderVC) {
                (reader as! IAReaderVC).pageControllerPanGestureEnabled(false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updatePage() {
       addLoadingView()
       imagesDownloader!.imageOfPage(pageNumber!){ [weak self](page: Int, image: UIImage)->() in
            if let mySelf = self {
                mySelf.removeLoadingView()
                if page == mySelf.pageNumber {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        mySelf.updateImage(image)
                        mySelf.panGestureRecognizer.enabled = true
                        if let reader = mySelf.parentViewController?.parentViewController where reader.isKindOfClass(IAReaderVC) {
                            (reader as! IAReaderVC).pageControllerPanGestureEnabled(false)
                        }
                    })
                }
            }
            
        }
    }
    
    func goNextPage() {
        if let reader = parentViewController?.parentViewController where reader.isKindOfClass(IAReaderVC) {
                panGestureRecognizer.enabled = false
                (reader as! IAReaderVC).goNextPage()
        }
    }
    
    
    func goPreviousPage() {
        if let reader = parentViewController?.parentViewController where reader.isKindOfClass(IAReaderVC) {
            panGestureRecognizer.enabled = false
            (reader as! IAReaderVC).goPreviousPage()
        }
    }
    
    //MARK: Helpers
    
    func addLoadingView() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: activityIndicatorView  , attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: view , attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    func removeLoadingView() {
       activityIndicatorView.stopAnimating()
       activityIndicatorView.removeFromSuperview()
    }
    
    func rescaleScrollView(image: UIImage) {
        let imageRect = AVMakeRectWithAspectRatioInsideRect(image.size, imageView!.frame)
        let scale = view.frame.size.width/imageRect.width
        let zoomRect = zoomRectForScale(scale, center: scrollView.center)
       scrollView?.zoomToRect(zoomRect, animated: false)
       scrollView.scrollRectToVisible(CGRectMake(scrollView.contentOffset.x, 0, zoomRect.width, zoomRect.height), animated: false)
       zoomScale = scale
       zoomOffset = scrollView.contentOffset
       zoomed = true
       imageView?.hidden = false
    }
    
    func rescaleScrollView() {
        if let image = image {
            if !scaled {
                rescaleScrollView(image)
                scaled = true
            }
        }
    }
    
    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
        var zoomRect = CGRectZero
        if let imageV = imageView {
            zoomRect.size.height = imageV.frame.size.height / scale;
            zoomRect.size.width  = imageV.frame.size.width  / scale;
            let newCenter = imageV.convertPoint(center, fromView: scrollView)
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
        }
        return zoomRect;
    }

    
    //MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let  scale = zoomScale , zoomOffset = zoomOffset{
            if (scrollView.contentOffset.x != 0 && scrollView.zoomScale == scale && zoomed) {
                var offset = scrollView.contentOffset
                offset.x = zoomOffset.x
                scrollView.contentOffset = offset
            }
        }
    }
    
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        zoomed = false
    }
    
    //MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if otherGestureRecognizer.isKindOfClass(UIPinchGestureRecognizer) {
            return false
        }else {
            return true
        }
    }

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
            if let reader = parentViewController?.parentViewController where reader.isKindOfClass(IAReaderVC) {
                return !(reader as! IAReaderVC).pageVCisAnimating
            }
        return true
    }
    
    //MARK: IBACTION

    @IBAction func scrollViewDoubleTapped(sender: AnyObject) {
        let recognizer = sender as! UIGestureRecognizer
        if let scrollView = scrollView where scrollView.zoomScale > scrollView.minimumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }else if let image = image, imageView = imageView {
            let imageRect = AVMakeRectWithAspectRatioInsideRect(image.size, imageView.frame)
            let scale = view.frame.size.width/imageRect.width
            let zoomRect = zoomRectForScale(scale, center: CGPointMake(view.center.x , recognizer.locationInView(recognizer.view).y) )
            scrollView?.zoomToRect(zoomRect, animated: true)
            zoomScale = scale
            zoomOffset = scrollView.contentOffset
            zoomed = true
        }
    }
    
    @IBAction func scrollViewPangestureHandler(sender: AnyObject) {
        let pangesture = sender as! UIPanGestureRecognizer
        
        if pangesture.state == .Changed {
        }else if pangesture.state == .Began {
            panStartPosition = pangesture.locationInView(pangesture.view)
        } else if pangesture.state == .Ended {
            if zoomed && abs(pangesture.velocityInView(pangesture.view).x) > abs(pangesture.velocityInView(pangesture.view).y){
                    if pangesture.velocityInView(pangesture.view).x > 200 {
                        goPreviousPage()
                    }else if pangesture.velocityInView(pangesture.view).x < -200 {
                        goNextPage()
                    }
            }else {
                if pangesture.locationInView(pangesture.view).x - panStartPosition!.x > 100 && scrollView.contentOffset.x < 10 {
                    goPreviousPage()
                } else if pangesture.locationInView(pangesture.view).x - panStartPosition!.x < 100 && scrollView.contentOffset.x + scrollView.frame.size.width >  scrollView.contentSize.width - 10 {
                    goNextPage()
                }
           
            }
         }
        
    }
    
    //MARK: Setter
    
    func updateImage(image: UIImage) {
        updateImage(image, hidden: false)
    }
    
    func updateImage(image: UIImage, hidden: Bool) {
        guard self.image == nil else {return}
        self.image = image
        imageView?.image = image
        imageView?.hidden = hidden
        if appeared {
            rescaleScrollView()
        }
    }
       
    //MARK: Device orientation
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        scaled = false
        rescaleScrollView()
    }   
}
