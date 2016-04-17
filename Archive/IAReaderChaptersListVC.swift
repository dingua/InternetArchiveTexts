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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentfier)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentfier)! as UITableViewCell
        let chapter = chapters![indexPath.row] as! Chapter
        cell.textLabel?.text = chapter.name
        return cell
    }
    
}
