//
//  IAChapterBookmarkExploreVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/15/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAChapterBookmarkExploreVC: UIViewController {
    /**
     Properties
     */
    @IBOutlet weak var favoButton: UIButton!
    @IBOutlet weak var chaptersContainerView: UIView!
    @IBOutlet weak var bookmarksContainerView: UIView!
    @IBOutlet weak var segementControl: UISegmentedControl!
    
    var item: IAArchiveItem?
    var selectedChapterIndex = -1
    var chapterSelectionHandler : ChapterSelectionHandler?
    var bookmarkSelectionHandler: BookmarkSelectionHandler?
    var sortPresentationDelegate =  IASortPresentationDelgate()

    //MARK: - Initializer
    func update(item: IAArchiveItem, selectedIndex: Int) {
        self.item = item
        self.selectedChapterIndex = selectedIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = item {
            favoButton.setImage(item.isFavourite ? UIImage(named: "favourite_filled") : UIImage(named: "favourite_empty"), forState: .Normal)
        }
        chaptersContainerView.hidden = false
        bookmarksContainerView.hidden = true
        self.view.layer.cornerRadius = 20.0
        self.segementControl.tintColor = UIColor.blackColor()
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chapters" {
            if let item = item {
                let chaptersListVC = segue.destinationViewController as! IAChaptersListVC
                chaptersListVC.chapterSelectionHandler = {chapterIndex in
                    self.dismissViewControllerAnimated(true, completion: {
                        self.chapterSelectionHandler!(chapterIndex: chapterIndex)
                    })
                }
                
                if let chapters = item.file?.chapters { // Temporary Item has chapters set already
                    chaptersListVC.chapters = chapters.sort({ $0.name < $1.name})
                } else { // Otherwise check the item in the database
                    let itemDB = ArchiveItem.createArchiveItem(item, managedObjectContext: CoreDataStackManager.sharedManager.managedObjectContext)
                    if let chapters = itemDB?.file?.chapters {
                        chaptersListVC.chapters = chapters.sort({ $0.name < $1.name}).map({IAChapter(chapter: $0 as! Chapter)})
                    }
                }
                chaptersListVC.selectedChapterIndex = selectedChapterIndex
            }
            
        }else if segue.identifier == "bookmarks" {
            if let item = item, selectionHandler = bookmarkSelectionHandler {
                let bookmarksListVC = segue.destinationViewController as! IABookmarksListVC
                bookmarksListVC.configure(item, andSelectionHandler: {page in
                    self.dismissViewControllerAnimated(true, completion: {
                        selectionHandler(page)
                    })
                })
            }
        }
    }
    //MARK: - IBAction
    
    
    @IBAction func favoButtonPressed(sender: AnyObject) {
        if !Utils.isLoggedIn() {
            presentLoginscreen()
            return
        }
        triggerFavorite(item)
    }
    
    @IBAction func segmentControlDidChangeValue(sender: AnyObject) {
        let segmentControl = sender as! UISegmentedControl
        switch segmentControl.selectedSegmentIndex {
        case 0:
            chaptersContainerView.hidden = false
            bookmarksContainerView.hidden = true
            break
        case 1:
            chaptersContainerView.hidden = true
            bookmarksContainerView.hidden = false
            break
        default:
            break
        }
    }
    
    //MARK: Helpers
    
    func presentLoginscreen() {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! IALoginVC
        loginVC.transitioningDelegate = sortPresentationDelegate
        loginVC.modalPresentationStyle = .Custom
        loginVC.dismissCompletion = {
            self.triggerFavorite(self.item)
        }
        self.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    func triggerFavorite(item: IAArchiveItem?) {
        if let item = item {
            IAFavouriteManager.sharedInstance.triggerFavorite(item) {_ in
                self.favoButton.imageView?.image = (item.isFavourite) ? UIImage(named: "favourite_filled") : UIImage(named: "favourite_empty")
            }
        }
    }
    
}