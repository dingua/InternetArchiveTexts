//
//  IADownloadedChaptersListVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/8/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IAChaptersListVC: UITableViewController {
    var selectedChapterIndex = -1
    var chapterSelectionHandler : ChapterSelectionHandler?
    var chapters: [IAChapter]? {
        didSet {
            self.tableView.reloadData()
            for chapter  in chapters! {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAChaptersListVC.updateDownloadProgress), name: "\(chapter.name!)_progress", object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAChaptersListVC.downloadFinished), name: "\(chapter.name!)_finished", object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAChaptersListVC.chapterDeleted), name: "\(chapter.name!)_deleted", object: nil)
            }
        }
    }
    
    var downloadProgress = [String:Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateDownloadProgress(notification: NSNotification) {
        reloadChapter(notification,statusStr: "_progress")
    }
    
    func downloadFinished(notification: NSNotification) {
        reloadChapter(notification,statusStr: "_finished")
    }
    
    func chapterDeleted(notification: NSNotification) {
        reloadChapter(notification,statusStr: "_deleted")
    }
    
    func reloadChapter(notification: NSNotification, statusStr: String) {
        let name = notification.name.substringToIndex((notification.name.rangeOfString(statusStr)?.startIndex)!)
        let filteredChapters = chapters?.filter({$0.name == name})
        let chapter = filteredChapters?.first
        if let chapter = chapter {
            dispatch_async(dispatch_get_main_queue(), {
                if let progress = notification.object  as? Double {
                    self.downloadProgress[chapter.name!] = progress
                } else {
                    self.downloadProgress[chapter.name!] = nil
                }
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: (self.chapters?.indexOf({$0.name == chapter.name}))!, inSection: 0)], withRowAnimation: .None)
            })
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let chapters = chapters {
            return chapters.count
        }else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("downloadStatusCell", forIndexPath: indexPath) as! IAChapterTableViewCell
        let chapter = chapters![indexPath.row]
        if let progress = downloadProgress[chapter.name!] {
            cell.configure(chapter, withProgress : progress,
                           isSelected: indexPath.row == selectedChapterIndex,
                           downloadActionHandler:  {chapter in
                            self.triggerDownload(chapter)
            }){chapter in
                self.cancelDownload(chapter)
            }
        }else {
            cell.configure(chapter, isSelected: indexPath.row == selectedChapterIndex, downloadActionHandler: {chapter in
            self.triggerDownload(chapter)
            })
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        chapterSelectionHandler!(chapterIndex: indexPath.row)
    }
    
    //MARK: Handle Download Actions
    
    func triggerDownload(chapter: IAChapter) {
        showConfirmationAlertForHandler(chapter.isDownloaded() ? "Do you want to delete this chapter ? " : "Do you want to download this chapter ?", handler: {
            IADownloadsManager.sharedInstance.downloadTrigger(chapter)
        })
    }
    
    func cancelDownload(chapter: IAChapter) {
        showConfirmationAlertForHandler("Do you want to cancel this download ?", handler: {
            IADownloadsManager.sharedInstance.cancelDownload(chapter)
        })
    }

    //MARK: Helper
    
    func showConfirmationAlertForHandler(message: String, handler: ()->()) {
        let alertView = UIAlertController(title: "Download", message: message, preferredStyle: .Alert)
        
        alertView.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { _ in
            handler()
        }))
        
        alertView.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
}
