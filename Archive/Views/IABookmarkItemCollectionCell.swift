//
//  IABookmarkItemCollectionCell.swift
//  Archive
//
//  Created by Mejdi Lassidi on 7/11/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IABookmarkItemCollectionCell: IAGenericItemCollectionCell {

    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var chapterLabel: UILabel!
    
    func configure(page: Page, type: ItemCollectionButtonType?, completion: ItemCellCompletionBlock?) {
        if type       != nil { buttonType    = type }
        if completion != nil { actionClosure = completion }
        
        titleLabel.text = "\(page.chapter!.file!.archiveItem!.title!)"
        let url = page.urlOfPage(10)
        mainImageView.af_setImageWithURL(NSURL(string: url)!)
        
        if buttonType == .Bookmark && page.bookmarked {
            actionButton.setImage(UIImage(named: "bookmark_filled"), forState: .Normal)
        }
        pageLabel.text = "Page \((page.number?.intValue)!+1)"
        chapterLabel.text = "\(page.chapter?.name ?? "")"
        
    }

}
