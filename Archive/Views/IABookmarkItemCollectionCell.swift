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
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func configure(page: Page, type: ItemCollectionButtonType?, completion: ItemCellCompletionBlock?) {
        if type       != nil { buttonType    = type }
        if completion != nil { actionClosure = completion }
        
        if let sortedChapters = page.chapter?.file?.sortedChapters() {
            titleLabel.text = "\(page.chapter!.file!.archiveItem!.title!) \n Page \(Int((page.number?.intValue)!)+1) of chapter number \(sortedChapters.indexOf(page.chapter!)!+1) "
        }
        let url = page.urlOfPage(10)
        mainImageView.af_setImageWithURL(NSURL(string: url)!)
        
        if buttonType == .Bookmark && page.bookmarked {
            actionButton.setImage(UIImage(named: "bookmark_filled"), forState: .Normal)
        }
        pageLabel.text = "Page \((page.number?.intValue)!+1)"
        chapterLabel.text = "\(page.chapter?.name ?? "")"
        self.setNeedsLayout()
    }

}
