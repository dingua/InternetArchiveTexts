//
//  IADownloadStatusTableViewCell.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/8/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
typealias DownloadChapterActionHandler = (chapter: IAChapter)->()

class IAChapterTableViewCell: UITableViewCell {
    
    /**
     Properties
     */
    
    //UI
    @IBOutlet weak var chapterNameLabel: UILabel!
    @IBOutlet weak var downloadStatusButton: UIButton!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    //Attributes
    var downloadSelectionHandler: DownloadChapterActionHandler?
    var cancelActionHandler: DownloadChapterActionHandler?
    var chapter: IAChapter?
    
    //MARK: - Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(chapter: IAChapter, withProgress progress: Double = 0.0, isSelected selected: Bool = false,downloadActionHandler: DownloadChapterActionHandler?, cancelActionHandler: DownloadChapterActionHandler? = nil) {
        self.chapter = chapter
        chapterNameLabel.text = chapter.name
        if progress == 0.0 {
            downloadProgressView.hidden = true
            cancelBtn.hidden = true
            downloadStatusButton.hidden = false
            let downloadedStatus = Chapter.chapterDownloadStatus(chapter.name!, itemIdentifier: chapter.file?.archiveItem?.identifier ?? "")
            if downloadedStatus.isDownloaded {
                downloadStatusButton.setImage(UIImage(named: "done_btn"), forState: .Normal)
            }else {
                downloadStatusButton.setImage(UIImage(named: "download_button"), forState: .Normal)
            }
        }else {
            downloadProgressView.hidden = false
            cancelBtn.hidden = false
            downloadStatusButton.hidden = true
            downloadProgressView.progress = Float(progress)
        }
        if selected {
            chapterNameLabel.font = UIFont.boldSystemFontOfSize(14)
        }else {
            chapterNameLabel.font = UIFont.systemFontOfSize(14)

        }
        self.downloadSelectionHandler = downloadActionHandler
        self.cancelActionHandler = cancelActionHandler
    }
    
    @IBAction func downloadButtonAction() {
        if let chapter = chapter, downloadSelectionHandler = downloadSelectionHandler {
            downloadSelectionHandler(chapter: chapter)
        }
    }
    
    @IBAction func cancelDownload() {
        if let cancelActionHandler = cancelActionHandler, chapter = chapter {
            cancelActionHandler(chapter: chapter)
        }
    }
    
}
