//
//  IAReaderVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/11/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

class IAReaderVC: UIViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource {
    //MARK: Variables Declaration
    
    var pageController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
    var bookIdentifier : String!
    var file : File? //Book Details
    var numberOfPages = 0 //Will be calculated Later after getting book details
    
    var pageNumber = 0 {
        didSet {
            pageNumberLabel.text = "\(pageNumber+1)"
            let percentage = Float(self.pageNumber)/Float(self.numberOfPages) as Float?
            progressSlider.value = percentage!
        }
    }
    
    lazy var activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
    
    //IBOutlets
    @IBOutlet weak var bottomMenu: UIView!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBOutlet weak var chaptersButton: UIButton!
    
    var imagesDownloader: IABookImagesManager?
    let archiveItemsManager = IAItemsManager()
    
    var updatePageAfterSeekTimer :NSTimer?
    let secondsToLoadMore = 1.0
    
    //MARK: -INIT
    
    init(identifier: String){
        self.bookIdentifier = identifier
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.bookIdentifier = ""
        super.init(coder: aDecoder)!
    }
    
    //MARK: UI Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLoadingView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "dismiss", style: .Plain, target: self, action: "dismissViewController")
        
        //Get File Details from MetaData WS
        archiveItemsManager.getFileDetails(bookIdentifier) { (file) -> () in
            self.removeLoadingView()
            if file.identifier == "" {
                let alert = UIAlertController(title: "Error", message: "Can not preview this file!", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    self.dismissViewControllerAnimated(false, completion: nil)
                }
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true, completion:nil)
                
                return
            }
            self.file = file
            if file.chapters?.count>0 {
                self.setupReaderToChapter(0)
            }
            self.chaptersButton.hidden = file.chapters?.count <= 1
            
        }
    }
    
    func setupReaderToChapter(chapterIndex: Int) {
        if let file = self.file {
            let chapter = file.chapters![chapterIndex]
            let subdirectory = chapter.zipFile?.substringToIndex((chapter.zipFile?.rangeOfString("_\((chapter.type?.rawValue.lowercaseString)!).zip")?.startIndex)!)
            self.imagesDownloader = IABookImagesManager(identifier:file.identifier,server: file.server! ,directory: file.directory!,subdirectory: subdirectory!, scandata: chapter.scandata!,type: (chapter.type?.rawValue.lowercaseString)!)
            if  let nbrPages = self.imagesDownloader!.getNumberPages() {
                self.numberOfPages = Int(nbrPages)!
            }
            self.pageNumber = 0
            self.updatePages()
            self.addPageController()
        }
        
    }
    
    
    func addPageController() {
        self.pageController.removeFromParentViewController()
        self.pageController.didMoveToParentViewController(nil)
        self.pageController.view.removeFromSuperview()
        self.pageController.view.frame = self.view.bounds
        
        self.pageController.setViewControllers(Array(arrayLiteral: self.pageVCWithNumber(self.pageNumber)) , direction: .Forward, animated: true, completion: nil)
        self.pageController.delegate = self
        self.pageController.dataSource = self
        
        self.view.addSubview(self.pageController.view)
        self.view.bringSubviewToFront(self.bottomMenu)
        
        self.addChildViewController(self.pageController)
        self.pageController.didMoveToParentViewController(self)
        
    }
    
    
    func pageVCWithNumber(number: Int)->IAReaderPageVC {
        let pageVC = self.storyboard?.instantiateViewControllerWithIdentifier("pageVC") as! IAReaderPageVC
        pageVC.pageNumber = number
        pageVC.imagesDownloader = self.imagesDownloader
        return pageVC
    }
    
    func updatePageVCWithNumber(number: Int, image: UIImage) {
        let viewControllers = self.pageController.viewControllers as! [IAReaderPageVC]
        for vc in viewControllers {
            if vc.pageNumber == number {
                vc.removeLoadingView()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    vc.updateImage(image)
                })

            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UIPageViewControllerDelegate
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        let vc = pendingViewControllers.first as! IAReaderPageVC
        self.pageNumber = vc.pageNumber!
        self.downloadMore()
        
    }
    //MARK: UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let pageNumber = (viewController as! IAReaderPageVC).pageNumber
        
        if pageNumber <= 0 {
            return nil
        }
        
        let beforeVC =  self.storyboard?.instantiateViewControllerWithIdentifier("pageVC") as! IAReaderPageVC
        beforeVC.pageNumber = pageNumber!-1
        beforeVC.imagesDownloader = self.imagesDownloader
        return beforeVC
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        let pageNumber = (viewController as! IAReaderPageVC).pageNumber
        
        if pageNumber >= self.numberOfPages-1 {
            return nil
        }
        
        let afterVC = self.storyboard?.instantiateViewControllerWithIdentifier("pageVC") as! IAReaderPageVC
        afterVC.pageNumber = pageNumber!+1
        afterVC.imagesDownloader = self.imagesDownloader
        return afterVC
    }
    
    //MARK: IBACTION
    
    @IBAction func progressSliderChangedValue(sender: AnyObject) {
        let slider = sender as! UISlider
        let number = Float(self.numberOfPages-1) * slider.value
        self.pageNumber = Int(number)
        self.imagesDownloader!.cancelAllRequests()
        if let timer = self.updatePageAfterSeekTimer {
            timer.invalidate()
        }
        self.updatePageAfterSeekTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateUIAfterPageSeek", userInfo: nil, repeats: false)
    }
    
    @IBAction func chaptersButtonPressed(sender: AnyObject) {
        let chaptersListVC = IAReaderChaptersListVC()
        chaptersListVC.chapters = file?.chapters
        chaptersListVC.chapterSelectionHandler = { chapterIndex in
            self.setupReaderToChapter(chapterIndex)
        }
        
        
        let button = sender as! UIButton
        chaptersListVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = chaptersListVC.popoverPresentationController
        chaptersListVC.preferredContentSize = CGSizeMake(500,600)
        popover!.sourceView = self.view
        popover!.sourceRect =  self.bottomMenu.convertRect(button.frame, toView: self.view)
        
        self.presentViewController(chaptersListVC, animated: true, completion: nil)
        
    }
    
    func updateUIAfterPageSeek() {
        let pageVC = self.pageVCWithNumber(self.pageNumber) 
        self.pageController.setViewControllers(Array(arrayLiteral: pageVC) , direction: .Forward, animated: true, completion: nil)
        self.updatePages()
    }
    
    func goNextPage() {
        self.pageNumber++
        updateUIAfterPageSeek()
    }
    
    func goPreviousPage() {
        self.pageNumber--
        updateUIAfterPageSeek()
    }
    
    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
            self.bottomMenu.hidden = !self.bottomMenu.hidden
    }
    
    //MARK: Model calls
    
    func updatePage() {
        self.imagesDownloader!.imageOfPage(self.pageNumber){(image: UIImage, page: Int)->() in
            if page == self.pageNumber {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updatePageVCWithNumber(page,image: image)
                })
            }
        }
    }
    
    func updatePage(completion:()->()) {
        self.imagesDownloader!.imageOfPage(self.pageNumber){(image: UIImage, page: Int)->() in
            completion()
            if page == self.pageNumber {
                    self.updatePageVCWithNumber(page,image: image)
            }
        }
    }
    
    func updatePages() {
        self.updatePage(){()->() in
            self.downloadMore()
        }
    }
    
    func downloadMore () {
        self.imagesDownloader!.getImages(pageNumber-2, count: 5,
            updatedImage:{ (page: Int, image: UIImage)->() in
                if self.pageNumber == page {
                    self.updatePageVCWithNumber(page,image: image)
                }
            }){ ()->() in
        }
    }
    
    
    //GestureRecognizer Delegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentCollection" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let vc = navigationController.topViewController as! IAReaderCollectionViewController
            vc.imagesDownloader = self.imagesDownloader
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
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        print("called here")
    }
}
