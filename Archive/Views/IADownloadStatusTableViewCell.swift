//
//  IADownloadStatusTableViewCell.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/8/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
typealias DownloadChapterActionHandler = (chapter: Chapter)->()

class IAChapterTableViewCell: UITableViewCell {
    
    /**
     Properties
     */
    
    //UI
    @IBOutlet weak var chapterNameLabel: UILabel!
    @IBOutlet weak var downloadStatusButton: UIButton!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    //Attributes
    var downloadSelectionHandler: DownloadChapterActionHandler?
    var chapter: Chapter?
    
    //MARK: - Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(chapter: Chapter, withProgress progress: Double = 0.0, isSelected selected: Bool = false,downloadActionHandler: DownloadChapterActionHandler?) {
        self.chapter = chapter
        chapterNameLabel.text = chapter.name
        if progress == 0.0 {
            downloadProgressView.hidden = true
            downloadStatusButton.hidden = false
            if (chapter.isDownloaded?.boolValue)! {
                downloadStatusButton.setImage(UIImage(named: "done_btn"), forState: .Normal)
                
            }else {
                downloadStatusButton.setImage(UIImage(named: "download_button"), forState: .Normal)
            }
        }else {
            downloadProgressView.hidden = false
            downloadStatusButton.hidden = true
            downloadProgressView.progress = Float(progress)
        }
        if selected {
            chapterNameLabel.font = UIFont.boldSystemFontOfSize(14)
        }else {
            chapterNameLabel.font = UIFont.systemFontOfSize(14)

        }
        self.downloadSelectionHandler = downloadActionHandler
    }
    
    @IBAction func downloadButtonAction() {
        if let chapter = chapter {
            downloadSelectionHandler!(chapter: chapter)
        }
    }
}
