//
//  IACollectionsExploreVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 1/24/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

private let reuseIdentifier = "collectionExploreCell"

class IACollectionsExploreVC: UICollectionViewController {
    
    var searchManager = IAItemsManager()
    var collections = NSMutableArray()
    var selectedCollection: ArchiveItemData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCollections()
        addLoginButton()
    }
    
    //MARK: - Helpers
    
    func searchCollections() {
        searchManager.searchCollections("texts", hidden: true, count: 50, page: 0) { [weak self] collections  in
            if let mySelf = self {
                let allTextsDictionary = [
                    "identifier": "texts",
                    "title": "All Texts"
                ]
                mySelf.collections.addObject(ArchiveItemData(dictionary: allTextsDictionary))
                mySelf.collections.addObjectsFromArray(collections as! [ArchiveItemData])
                mySelf.collectionView!.reloadData()
            }
        }
    }
    
    
    func addLoginButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: #selector(IACollectionsExploreVC.pushLoginScreen))
    }
    
    func pushLoginScreen() {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC")
        self.navigationController?.pushViewController(loginVC!, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return Utils.isiPad() ? CGSizeMake(240, 300) : CGSizeMake(self.view.frame.size.width/2-10, 250)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! IACollectionsExploreViewCell
        cell.configureWithItem(collections[indexPath.row] as! ArchiveItemData)
        return cell
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCollectionItems" {
            let selectedIndex = self.collectionView?.indexPathForCell(sender as! IACollectionsExploreViewCell)
            let vc  = segue.destinationViewController as! IAItemsListVC
            let collectionData = collections[selectedIndex!.row] as! ArchiveItemData
            vc.loadList(collectionData.identifier!, type: .Collection)
            vc.title = collectionData.title
        }
    }
}