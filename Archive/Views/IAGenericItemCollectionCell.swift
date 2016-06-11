//
//  IAGenericItemCollectionCell.swift
//  Archive
//
//  Created by Islam on 5/11/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

public typealias ItemCellCompletionBlock = (() -> ())

class IAGenericItemCollectionCell: UICollectionViewCell {
    
    enum ItemCollectionButtonType: String {
        case None = ""
        case Favorite = "favourite_empty"
        case Download = "3dots"
        case Bookmark = "bookmark_empty"
    }
    
    var buttonType: ItemCollectionButtonType! {
        didSet {
            actionButton.setImage(UIImage(named: buttonType.rawValue), forState: .Normal)
            
            var action: Selector?
            
            switch buttonType! {
            case .None:     action = nil
            case .Favorite: action = .action
            case .Download: action = .action
            case .Bookmark: action = .action
            }
            
            if action != nil {
                actionButton.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
            }
        }
    }
    
    var actionClosure: ItemCellCompletionBlock?
    var secondActionClosure: ItemCellCompletionBlock?
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(item: ArchiveItem, type: ItemCollectionButtonType?, completion: ItemCellCompletionBlock?)->IAGenericItemCollectionCell {
        if type       != nil { buttonType    = type }
        if completion != nil { actionClosure = completion }
        
        titleLabel.text = item.title
        
        if let bookID = item.identifier {
            mainImageView.af_setImageWithURL(Constants.URL.ImageURL(bookID).url)
        }
        
        if buttonType == .Favorite && item.isFavorite {
            actionButton.setImage(UIImage(named: "favourite_filled"), forState: .Normal)
        }
        return self
    }
    
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
    }
    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        actionButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        mainImageView.image = nil
    }
    
    // MARK: - Helpers
    
    func action(sender: UIButton) {
        if actionClosure != nil {
            actionClosure!()
        }
    }
    
    @IBAction func secondAction() {
        if secondActionClosure != nil {
            secondActionClosure!()
        }
    }
}

private extension Selector {
    static let action = #selector(IAGenericItemCollectionCell.action(_:))
}