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
    var chapters: NSArray? {
        didSet {
            self.tableView.reloadData()
            for chapter  in (chapters as? [Chapter])! {
                if !((chapter.isDownloaded?.boolValue)!) {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAChaptersListVC.updateDownloadProgress), name: "\(chapter.name!)_progress", object: nil)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IAChaptersListVC.downloadFinished), name: "\(chapter.name!)_finished", object: nil)
                }
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
        let filteredChapters = chapters?.filteredArrayUsingPredicate(NSPredicate(format: "name like %@", notification.name.substringToIndex((notification.name.rangeOfString("_progress")?.startIndex)!)))
        let chapter = (filteredChapters?.first)!
        dispatch_async(dispatch_get_main_queue(), {
            self.downloadProgress[chapter.name!] = notification.object! as? Double
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: (self.chapters?.indexOfObject(chapter))!, inSection: 0)], withRowAnimation: .None)
        })
    }
    
    func downloadFinished(notification: NSNotification) {
        let filteredChapters = chapters?.filteredArrayUsingPredicate(NSPredicate(format: "name like %@", notification.name.substringToIndex((notification.name.rangeOfString("_finished")?.startIndex)!)))
        let chapter = (filteredChapters?.first)!
        dispatch_async(dispatch_get_main_queue(), {
            self.downloadProgress[chapter.name!] = nil
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: (self.chapters?.indexOfObject(chapter))!, inSection: 0)], withRowAnimation: .None)
        })
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
        let chapter = (chapters![indexPath.row] as! Chapter)
        if let progress = downloadProgress[chapter.name!] {
            cell.configure(chapter, withProgress : progress, isSelected: indexPath.row == selectedChapterIndex) {chapter in
                IADownloadsManager.sharedInstance.downloadTrigger(chapter)
            }
        }else {
            cell.configure(chapter, isSelected: indexPath.row == selectedChapterIndex) {chapter in
                IADownloadsManager.sharedInstance.downloadTrigger(chapter)
            }
        }
        return cell
    }
 

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        chapterSelectionHandler!(chapterIndex: indexPath.row)
    }


}
