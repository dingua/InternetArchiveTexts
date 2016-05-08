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
    
    func configureCell(chapter: Chapter) {
        if let name = chapter.name , title = chapter.file?.archiveItem?.title {
            let backgroundYellowAttirbute = [ NSBackgroundColorAttributeName: UIColor.yellowColor() ]

            let boldAttirbute = [ NSFontAttributeName: UIFont(name: "Helvetica-Bold", size: 18.0)! ]

            let attributedString = NSMutableAttributedString(string: "Chapter ")
            attributedString.appendAttributedString(NSAttributedString(string: "\(name)", attributes: backgroundYellowAttirbute))
            attributedString.appendAttributedString(NSAttributedString(string: " of \(title)", attributes: boldAttirbute))
            downloadLabel.attributedText = attributedString
            imageView.image = UIImage(contentsOfFile: urlFirstChapterPage(chapter))
        }
    }
    
    func urlFirstChapterPage(chapter: Chapter)->String {
       let type =  FileType(rawValue: chapter.type!)
        return "\(Utils.docuementsDirectory())/\(chapter.subdirectory!)_\(type!)/\(chapter.subdirectory!)_\(String(format: "%04d", 0)).\(type!)"
    }
}
