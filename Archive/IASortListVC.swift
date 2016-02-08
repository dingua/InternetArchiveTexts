//
//  IASortListVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 2/7/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

protocol IASortListDelegate {
    func sortListDidSelectSortOption(option: IASortOption)
}

enum IASortOption: String {
    case Downloads = "Views"
    case Title = "Title"
    case ArchivedDate = "Archived Date"
    case PublishedDate = "Published Date"
    case ReviewedDate = "Reviewed Date"
}

let optionCellIdentifier = "optionCellIdentifier"

class IASortListVC: UITableViewController {
    var sortOptions: [IASortOption]?
    var delegate: IASortListDelegate?
    var selectedOption: IASortOption?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortOptions = [.Downloads,.Title,.ArchivedDate,.PublishedDate,.ReviewedDate]
        self.view.layer.cornerRadius = 20
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortOptions!.count
    }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(optionCellIdentifier, forIndexPath: indexPath) as! IASortListTableViewCell
       let option = sortOptions![indexPath.row]
        cell.optionLabel!.text = option.rawValue
            if option == selectedOption {
                cell.optionImageView?.image = UIImage(named: "checkmark")
            }else {
                cell.optionImageView?.image = nil
            }
        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate where self.selectedOption != sortOptions![indexPath.row] {
            delegate.sortListDidSelectSortOption(sortOptions![indexPath.row])
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
