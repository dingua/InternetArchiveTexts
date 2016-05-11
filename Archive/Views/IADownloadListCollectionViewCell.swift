//
//  IADownloadListCollectionViewCell.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/6/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IADownloadListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadLabel: UILabel!
    var downloadSelectionCompletion: (()->())?

    func configureCell(book: ArchiveItem, downloadCompletion: (()->())? ) {
        downloadSelectionCompletion = downloadCompletion
        downloadLabel.text = book.identifier
        if let url = NSURL(string: "\(imageBaseURL)\(book.identifier!)") {
            self.imageView.af_setImageWithURL(url)
        }
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func urlFirstChapterPage(chapter: Chapter)->String {
        let type =  chapter.type
        return "\(Utils.docuementsDirectory())/\(chapter.subdirectory!)_\(type!)/\(chapter.subdirectory!)_\(String(format: "%04d", 0)).\(type!)"
    }
    @IBAction func downloadButtonPressed() {
        if let downloadCompletion = downloadSelectionCompletion {
            downloadCompletion()
        }
    }
}
