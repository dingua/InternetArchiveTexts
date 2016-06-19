//
//  IABookmarksListVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/15/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData
typealias BookmarkSelectionHandler = (Page) -> ()

class IABookmarksListVC: UITableViewController, NSFetchedResultsControllerDelegate {
    var item: IAArchiveItem?
    var selectionHandler: BookmarkSelectionHandler?
    
    lazy var fetchRequest: NSFetchRequest = {
        let fetchRequest = NSFetchRequest(entityName: "Page")
        fetchRequest.predicate = NSPredicate(format: "self.chapter.file.archiveItem.identifier like %@ AND isBookmarked == YES", "\(self.item!.identifier!)")
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }()
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchController =  NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: CoreDataStackManager.sharedManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchController.delegate = self
        return fetchController
    }()

    func configure(item: IAArchiveItem, andSelectionHandler selectionHandler: BookmarkSelectionHandler) {
        self.item = item
        self.selectionHandler = selectionHandler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = item {
            performFetch()
        }
    }
    
    
    //MARK: - Private
    
    private func performFetch() {
        do {
            try fetchedResultController.performFetch()
        }catch{}
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (fetchedResultController.sections?.count)!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fetchedResultController.sections![section].numberOfObjects
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bookmarkCell", forIndexPath: indexPath)
        let bookmark = fetchedResultController.objectAtIndexPath(indexPath) as! Page
        cell.textLabel!.text = "Page \(Int((bookmark.number?.intValue)!)+1), chapter \(bookmark.chapter!.name!)"
            return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let bookmark = fetchedResultController.objectAtIndexPath(indexPath) as! Page
        selectionHandler!(bookmark)
    }

}
