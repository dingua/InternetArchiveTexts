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
    var item: ArchiveItem?
    let bottomMarginReaderPage = 50.0
    var pageController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
    var bookIdentifier : String!
    var bookTitle: String!
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
        }
    }
    var selectedChapterIndex = 0
    lazy var activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
    
    var presentationDelegate =  IASortPresentationDelgate()
    //IBOutlets
    @IBOutlet weak var bottomMenu: UIView!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    var imagesDownloader: IABookImagesManager?
    let archiveItemsManager = IAItemsManager()
    
    var updatePageAfterSeekTimer :NSTimer?
    let secondsToLoadMore = 1.0
    
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "close_reader"), style: .Plain, target: self, action: #selector(IAReaderVC.dismissViewController))
        progressSlider.setThumbImage(UIImage(named: "roundSliderThumb")  ,forState: .Normal)
        progressSlider.userInteractionEnabled = false
        //Get File Details from MetaData WS
        getFileDetails()
    }
    
    func getFileDetails() {
        self.addLoadingView()
        archiveItemsManager.getFileDetails(item!) { (file) -> () in
            self.removeLoadingView()
            self.item!.file = file
            self.addDownloadButton()
            if (file.chapters?.count)! > 0 {
                self.setupReaderToChapter(0)
            }
            if (file.chapters?.count)! > 1 {
                self.addChaptersButton()
            }
            self.progressSlider.userInteractionEnabled = true
        }
    }
    
    func addDownloadButton() {
        let button = UIBarButtonItem(image: UIImage(named: "download_button"), style: .Plain, target: self, action: #selector(IAReaderVC.downloadChapterFiles))
        self.navigationItem.rightBarButtonItem = button
    }
 
    func addChaptersButton() {
        let button = UIBarButtonItem(image: UIImage(named: "sort"), style: .Plain, target: self, action: #selector(IAReaderVC.chaptersButtonPressed(_:)))
        if let _ = self.navigationItem.rightBarButtonItems {
            self.navigationItem.rightBarButtonItems?.append(button)
        }else {
            self.navigationItem.rightBarButtonItem = button
        }
    }
    
    func setupReaderToChapter(chapterIndex: Int) {
        if let file = item!.file {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                self.selectedChapterIndex = chapterIndex
                if let oldImagesDownloader = self.imagesDownloader{
                    oldImagesDownloader.cancelAllRequests()
                }
                self.imagesDownloader = IABookImagesManager(file: file, chapterIndex: self.selectedChapterIndex)
              
                let chapter = file.chapters!.sort({$0.name < $1.name})[chapterIndex] as! Chapter
                
                if  let nbrPages = self.imagesDownloader!.numberOfPages {
                    self.numberOfPages = Int(nbrPages)
                    chapter.numberOfPages = NSNumber(integer: self.numberOfPages)
                }
                
                self.pageNumber = 0
                self.imagesDownloader!.getPages(){_ in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.addPageController()
                        self.updatePages()
                    })
                }

            })
        }
    }
    
    func addPageController() {
        self.pageController.removeFromParentViewController()
        self.pageController.didMoveToParentViewController(nil)
        self.pageController.view.removeFromSuperview()

        self.pageController.setViewControllers(Array(arrayLiteral: self.pageVCWithNumber(self.pageNumber)) , direction: .Forward, animated: true, completion: nil)
        self.pageController.view.backgroundColor = UIColor.redColor()
        self.pageController.delegate = self
        self.pageController.dataSource = self
        
        self.view.addSubview(self.pageController.view)
        self.view.bringSubviewToFront(self.bottomMenu)
        
        self.addChildViewController(self.pageController)
        self.pageController.didMoveToParentViewController(self)

        //Apply constraints
        self.pageController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: self.topLayoutGuide   , attribute: .Bottom, relatedBy: .Equal, toItem: self.pageController.view, attribute: .Top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pageController.view  , attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pageController.view  , attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.bottomLayoutGuide  , attribute: .Top, relatedBy: .Equal, toItem:self.pageController.view, attribute: .Bottom, multiplier: 1.0, constant: CGFloat(bottomMarginReaderPage)))

        self.view.bringSubviewToFront(self.downloadProgressView)
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
                    vc.updateImage(image,hidden: true)
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
        self.updatePageAfterSeekTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(IAReaderVC.updateUIAfterPageSeek(_:)), userInfo: true, repeats: false)
    }
    
    @IBAction func chaptersButtonPressed(sender: AnyObject) {
        let chaptersListVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("chaptersListVC") as! IAReaderChaptersListVC
        chaptersListVC.transitioningDelegate = presentationDelegate
        chaptersListVC.chapters = (item!.file?.chapters!.allObjects as! [Chapter]?)?.sort({$0.name < $1.name})
        chaptersListVC.chapterSelectionHandler = { chapterIndex in
            self.setupReaderToChapter(chapterIndex)
        }
        chaptersListVC.selectedChapterIndex = self.selectedChapterIndex
        chaptersListVC.modalPresentationStyle = .Custom
        self.presentViewController(chaptersListVC, animated: true, completion: nil)
    }
    
    func downloadChapterFiles() {
        showChaptersList()
    }
    
    func startDownloading() {
        if let chapter = self.imagesDownloader?.chapter , file = item!.file {
            IADownloadsManager.sharedInstance.download(chapter, file: file)
        }
    }
    
    //MARK: - Show Chapters
    
    func showChaptersList() {
        let chaptersListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("IADownloadedChaptersListVC") as! IADownloadedChaptersListVC
        chaptersListVC.transitioningDelegate = presentationDelegate;
        chaptersListVC.chapters = item?.file?.chapters?.sort({ $0.name < $1.name})
        chaptersListVC.modalPresentationStyle = .Custom
        self.presentViewController(chaptersListVC, animated: true, completion: nil)
    }

    
    func updateUIAfterPageSeek(toNextPage: Bool) {
        let pageVC = self.pageVCWithNumber(self.pageNumber)
        self.pageController.setViewControllers(Array(arrayLiteral: pageVC) , direction: toNextPage ? .Forward : .Reverse, animated: true, completion: nil)
        self.updatePages()
    }
    
    func goNextPage() {
        if self.pageNumber < self.numberOfPages-1 {
            self.pageNumber += 1
            updateUIAfterPageSeek(true)
        }
    }
    
    func goPreviousPage() {
        if self.pageNumber > 0 {
            self.pageNumber -= 1
            updateUIAfterPageSeek(false)
        }
    }
    
    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Model calls
    
    func updatePage() {
        self.imagesDownloader!.imageOfPage(self.pageNumber){(page: Int, image: UIImage)->() in
            if page == self.pageNumber {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updatePageVCWithNumber(page,image: image)
                })
            }
        }
    }
    
    func updatePage(completion:()->()) {
        self.imagesDownloader!.imageOfPage(self.pageNumber){(page: Int, image: UIImage)->() in
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
            updateImage:{ (page: Int, image: UIImage)->() in
                if self.pageNumber == page {
                    self.updatePageVCWithNumber(page,image: image)
                }
            }){ ()->() in
        }
    }
    
    //MARK: GestureRecognizer Delegate
    
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
        return (item?.isFavourite?.boolValue)!
    }
}
