//
//  IAReaderVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/11/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import DGActivityIndicatorView
import MBProgressHUD

class IAReaderVC: UIViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource {
    
    //MARK: Variables Declaration
    var item: IAArchiveItem?
    
    var bookIdentifier : String!
    var bookTitle: String!

    var chapters : [IAChapter]? {
        get{
            return self.item?.file?.chapters.sort({ $0.name < $1.name})
        }
    }
    var pagesViewControllers = [Int:IAReaderPageVC]()
    let bottomMarginReaderPage = 50.0
    var pageController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
    var numberOfPages = 0 {
        didSet {
            //As soon as page number is set we update page number label
            updateProgressUI()
        }
    } //Will be calculated Later after getting book details
    
    var pageNumber = 0 {
        didSet {
            //As soon as page number is set we update page number label
            updateProgressUI()
            updateBookmarkButton()
        }
    }
    var selectedChapterIndex = 0
    lazy var activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
    
    var presentationDelegate =  IASortPresentationDelgate()
    
    var imagesDownloader: IABookImagesManager?
    let archiveItemsManager = IAItemsManager()
    
    var updatePageAfterSeekTimer :NSTimer?
    let secondsToLoadMore = 1.0
    
    var  didGetFileDetailsCompletion: (()->())?
    
    var pageVCisAnimating = false
    
    //IBOutlets
    @IBOutlet weak var bottomMenu: UIView!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    //MARK: -INIT
    
    init(identifier: String, title: String){
        self.bookIdentifier = identifier
        self.bookTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.bookIdentifier = ""
        super.init(coder: aDecoder)!
    }
    
    //MARK: UI Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "close_reader"), style: .Plain, target: self, action: #selector(IAReaderVC.dismissViewController))
        progressSlider.setThumbImage(UIImage(named: "roundSliderThumb")  ,forState: .Normal)
        progressSlider.userInteractionEnabled = false
        //Get File Details from MetaData Web Service
        getFileDetails()
        title = item?.title ?? ""
        pageVCisAnimating = false
    }
    
    var startDate: NSDate?
    
    func getFileDetails() {
        addLoadingView()
        startDate = NSDate()
        archiveItemsManager.getFileDetails(item!) { (file) -> () in
            self.removeLoadingView()
            self.item!.file = file
            if file.chapters.count > 0 {
                if let completion = self.didGetFileDetailsCompletion {
                    completion()
                }else {
                    self.setupReaderToChapter(0)
                }
            }else {
                self.showCanNotPreviewAlert()
                return
            }
            self.progressSlider.userInteractionEnabled = true
        }
    }
    
    func addBookmarkButton() {
        let button = UIBarButtonItem(image: UIImage(named: "bookmark_empty"), style: .Plain, target: self, action: #selector(IAReaderVC.triggerBookmark))
        navigationItem.rightBarButtonItem = button
    }
    
    func updateBookmarkButton() {
        if let page = imagesDownloader?.pageAtIndex(pageNumber), let rightBarButtonItem = navigationItem.rightBarButtonItem {
            let bookmarked = Page.isPageBookmarked(page)
            rightBarButtonItem.image = bookmarked ? UIImage(named: "bookmark_filled") : UIImage(named: "bookmark_empty")
            page.isBookmarked = bookmarked
        }
    }
    
    func addChaptersButton() {
        let button = UIBarButtonItem(image: UIImage(named: "3dots"), style: .Plain, target: self, action: #selector(IAReaderVC.chaptersButtonPressed(_:)))
        if let _ = navigationItem.rightBarButtonItems {
            navigationItem.rightBarButtonItems?.append(button)
        }else {
            navigationItem.rightBarButtonItem = button
        }
    }
    
    func addNavigationItems() {
        if navigationItem.rightBarButtonItems == nil {
            addBookmarkButton()
            addChaptersButton()
        }
    }
    
    func setupReaderToChapter(chapterIndex: Int, completion: ()->() = {}) {
        if let file = item!.file {
            removePageController()
            addLoadingView()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                self.selectedChapterIndex = chapterIndex
                if let oldImagesDownloader = self.imagesDownloader{
                    oldImagesDownloader.cancelAllRequests()
                }
                self.imagesDownloader = IABookImagesManager(file: file, chapterIndex: self.selectedChapterIndex)
                
                let chapter = file.chapters.sort({$0.name < $1.name})[chapterIndex]
                
                self.pageNumber = 0
                self.imagesDownloader!.getPages{pages in
                    if pages.count == 0 {
                        self.showCanNotPreviewAlert()
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.numberOfPages = Int(pages.count)
                        chapter.numberOfPages = self.numberOfPages
                        self.removeLoadingView()
                        self.addPageController() {
                            completion()
                        }
                        self.updatePages()
                        self.addNavigationItems()
                        self.updateBookmarkButton()
                    })
                }
                
            })
        }
    }
    
    func removePageController() {
        pageController.removeFromParentViewController()
        pageController.didMoveToParentViewController(nil)
        pageController.view.removeFromSuperview()
    }
    
    func addPageController(completion: ()->() = {}) {
        pageController.removeFromParentViewController()
        pageController.didMoveToParentViewController(nil)
        pageController.view.removeFromSuperview()
        pageController.setViewControllers(Array(arrayLiteral: pageVCWithNumber(pageNumber)) , direction: .Forward, animated: false, completion: nil)
        pageController.view.backgroundColor = UIColor.whiteColor()
        pageController.delegate = self
        pageController.dataSource = self
        
        view.addSubview(pageController.view)
        view.bringSubviewToFront(bottomMenu)
        
        addChildViewController(pageController)
        pageController.didMoveToParentViewController(self)
        
        //Apply constraints
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: topLayoutGuide   , attribute: .Bottom, relatedBy: .Equal, toItem: pageController.view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: pageController.view  , attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: pageController.view  , attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bottomLayoutGuide  , attribute: .Top, relatedBy: .Equal, toItem:pageController.view, attribute: .Bottom, multiplier: 1.0, constant: CGFloat(bottomMarginReaderPage)))
        
        view.bringSubviewToFront(downloadProgressView)
        completion()
    }
    
    func pageVCWithNumber(number: Int)->IAReaderPageVC {
        if let page = pagesViewControllers[number]{
            return page
        }else {
            let page = storyboard?.instantiateViewControllerWithIdentifier("pageVC") as! IAReaderPageVC
            page.pageNumber = number
            page.imagesDownloader = imagesDownloader
            pagesViewControllers[number] = page
            return page
        }
    }
    
    func updatePageVCWithNumber(number: Int, image: UIImage) {
        let viewControllers = pageController.viewControllers as! [IAReaderPageVC]
        for vc in viewControllers {
            if vc.pageNumber == number {
                vc.removeLoadingView()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    vc.updateImage(image,hidden: true)
                })
            }
        }
    }
    
    func showCanNotPreviewAlert() {
        let alert = UIAlertController(title: "Error", message: "Can not preview this file!", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        pagesViewControllers.removeAll()
    }
    
    //MARK: UIPageViewControllerDelegate
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pageVCisAnimating = true
        let vc = pendingViewControllers.first as! IAReaderPageVC
        pageNumber = vc.pageNumber!
        downloadMore()
        
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                                               previousViewControllers: [UIViewController],
                                               transitionCompleted completed: Bool) {
        if (completed || finished) {
            pageVCisAnimating = false
        }
    }
    
    //MARK: UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if pageVCisAnimating {
            return nil
        }
        let pageNumber = (viewController as! IAReaderPageVC).pageNumber
        
        if pageNumber <= 0 {
            return nil
        }
        updateBookmarkIfNecessary(false)
        return pageVCWithNumber(pageNumber!-1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        if pageVCisAnimating {
            return nil
        }
        let pageNumber = (viewController as! IAReaderPageVC).pageNumber
        
        if pageNumber >= numberOfPages-1 {
            return nil
        }
        updateBookmarkIfNecessary(true)
        return pageVCWithNumber(pageNumber!+1)
    }
    
    //MARK: IBACTION
    
    @IBAction func progressSliderChangedValue(sender: AnyObject) {
        let slider = sender as! UISlider
        let number = Float(numberOfPages-1) * slider.value
        pageNumber = Int(number)
        imagesDownloader!.cancelAllRequests()
        if let timer = updatePageAfterSeekTimer {
            timer.invalidate()
        }
        updatePageAfterSeekTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(IAReaderVC.updateUIAfterPageSeek(_:)), userInfo: true, repeats: false)
    }
    
    @IBAction func chaptersButtonPressed(sender: AnyObject) {
        let chaptersListVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("IAChapterBookmarkExploreVC") as! IAChapterBookmarkExploreVC
        chaptersListVC.transitioningDelegate = presentationDelegate
       
        chaptersListVC.item = item!
        chaptersListVC.chapterSelectionHandler = { chapterIndex in
            if self.selectedChapterIndex != chapterIndex {
                self.setupReaderToChapter(chapterIndex)
            }
        }
        chaptersListVC.bookmarkSelectionHandler = { page in
            let page = IAPage(page: page)
            if let chapters = self.chapters {
                self.setupReaderToChapter(chapters.indexOf({ (chapter) -> Bool in chapter.name == page.chapter?.name})! ) {
                    self.pageNumber = page.number!
                    self.updateUIAfterPageSeek(true)
                }
            }
        }
        chaptersListVC.selectedChapterIndex = selectedChapterIndex
        chaptersListVC.modalPresentationStyle = .Custom
        presentViewController(chaptersListVC, animated: true, completion: nil)
    }
    
    func triggerBookmark() {
        if let page = self.imagesDownloader?.pageAtIndex(self.pageNumber) {
            IABookmarkManager.sharedInstance.triggerBookmark(page)
            self.updateBookmarkButton()
        }
    }
    
    func startDownloading() {
        if let chapter = self.imagesDownloader?.chapter {
            IADownloadsManager.sharedInstance.downloadTrigger(chapter)
        }
    }
    
    //MARK: - Show Chapters
    
    func showChaptersList() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chaptersListVC = storyboard.instantiateViewControllerWithIdentifier("IADownloadedChaptersListVC") as! IAChaptersListVC
        chaptersListVC.transitioningDelegate = presentationDelegate;
        chaptersListVC.chapters = item?.file?.chapters.sort({ $0.name < $1.name})
        chaptersListVC.modalPresentationStyle = .Custom
        presentViewController(chaptersListVC, animated: true, completion: nil)
    }
    
    
    func updateUIAfterPageSeek(toNextPage: Bool) {
        let pageVC = self.pageVCWithNumber(self.pageNumber)
        self.pageController.setViewControllers(Array(arrayLiteral: pageVC) , direction: toNextPage ? .Forward : .Reverse, animated: true, completion: nil)
        self.updatePages()
        pageController.gestureRecognizers.filter({$0 is UIPanGestureRecognizer}).first?.enabled = true
    }
    
    func goNextPage() {
        if pageNumber < numberOfPages-1 {
            updateBookmarkIfNecessary(true)
            pageController.gestureRecognizers.filter({$0 is UIPanGestureRecognizer}).first?.enabled = false
            pageNumber += 1
            updateUIAfterPageSeek(true)
            

        }
    }
    
    func goPreviousPage() {
        if pageNumber > 0 {
            
            updateBookmarkIfNecessary(false)
            
            pageController.gestureRecognizers.filter({$0 is UIPanGestureRecognizer}).first?.enabled = false
            pageNumber -= 1
            updateUIAfterPageSeek(false)
        }
    }
    
    func dismissViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Model calls
    
    func updatePage() {
        imagesDownloader!.imageOfPage(pageNumber){(page: Int, image: UIImage)->() in
            if page == self.pageNumber {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updatePageVCWithNumber(page,image: image)
                })
            }
        }
    }
    
    func updatePage(completion:()->()) {
        imagesDownloader!.imageOfPage(pageNumber){(page: Int, image: UIImage)->() in
            completion()
            if page == self.pageNumber {
                self.updatePageVCWithNumber(page,image: image)
            }
        }
    }
    
    func updatePages() {
        updatePage(){()->() in
            self.downloadMore()
        }
    }
    
    func downloadMore () {
        imagesDownloader!.getImages(pageNumber-2, count: 5,
                                         updateImage:{ (page: Int, image: UIImage)->() in
                                            if self.pageNumber == page {
                                                self.updatePageVCWithNumber(page,image: image)
                                            }
        }){ ()->() in
        }
    }
    
    //MARK: GestureRecognizer Delegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !pageVCisAnimating
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentCollection" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let vc = navigationController.topViewController as! IAReaderCollectionViewController
            vc.imagesDownloader = imagesDownloader
        }
    }
    
    //MARK: Helpers
    
    func addLoadingView() {
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: activityIndicatorView  , attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: view , attribute: .CenterY, multiplier: 1.0, constant: 0))
    }
    
    func removeLoadingView() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
    
    func updateProgressUI() {
        dispatch_async(dispatch_get_main_queue()) {
            guard self.numberOfPages>1 else {
                self.pageNumberLabel.hidden = true
                self.progressSlider.hidden = true
                return
            }
            self.pageNumberLabel.text = "\(self.pageNumber+1)/\(self.numberOfPages)"
            let percentage = Float(self.pageNumber)/Float(self.numberOfPages-1) as Float?
            self.progressSlider.value = percentage!
            self.pageNumberLabel.hidden = false
            self.progressSlider.hidden = false
        }
    }
    
    
    func isFavourite()->Bool {
        return item?.isFavourite ?? false
    }
    
    func updateBookmarkIfNecessary(forNextPage: Bool) {
        if let currentPage = imagesDownloader?.pageAtIndex(pageNumber) where currentPage.isBookmarked {
            IABookmarkManager.sharedInstance.triggerBookmark(currentPage)
            
            if let nextPage = imagesDownloader?.pageAtIndex(forNextPage ? pageNumber+1 : pageNumber-1) where !nextPage.isBookmarked {
                IABookmarkManager.sharedInstance.triggerBookmark(nextPage)
            }
        }
    }
    
    //MARK: Device orientation
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        pagesViewControllers.forEach {$1.scaled = false}
    }
    
    func pageControllerPanGestureEnabled(enabled: Bool) {
        pageController.gestureRecognizers.filter({$0 is UIPanGestureRecognizer}).first?.enabled = enabled
    }
}
