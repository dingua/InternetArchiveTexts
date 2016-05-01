//
//  IAReaderChaptersListVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/28/16.{
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
let cellIdentfier = "chapterListCell"
class IAReaderChaptersListVC: UITableViewController {
    var chapters: NSArray? {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    var chapterSelectionHandler : ((chapterIndex: Int)->())?
    var selectedChapterIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 20
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (chapters?.count)!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true) { [weak self]() in
            if let myself = self {
                myself.chapterSelectionHandler!(chapterIndex: indexPath.row)
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentfier)! as! IASortListTableViewCell
        let chapter = chapters![indexPath.row] as! Chapter
        cell.optionLabel?.text = chapter.name
        if indexPath.row == selectedChapterIndex {
            cell.optionImageView?.image = UIImage(named: "checkmark")
        }else {
            cell.optionImageView?.image = nil
        }
        return cell
    }
    
}
