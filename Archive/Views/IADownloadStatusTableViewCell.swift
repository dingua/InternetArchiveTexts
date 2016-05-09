//
//  IADownloadStatusTableViewCell.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/8/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IADownloadStatusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chapterNameLabel: UILabel!
    @IBOutlet weak var downloadStatusImageView: UIImageView!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(chapter: Chapter) {
        configure(chapter, progress: 0.0)
    }
    
    func configure(chapter: Chapter, progress: Double) {
        chapterNameLabel.text = chapter.name
        if progress == 0.0 {
            downloadProgressView.hidden = true
            downloadStatusImageView.hidden = false
            if (chapter.isDownloaded?.boolValue)! {
                downloadStatusImageView.image = UIImage(named: "done_btn")
                
            }else {
                downloadStatusImageView.image = UIImage(named: "download_button")
            }
        }else {
            downloadProgressView.hidden = false
            downloadStatusImageView.hidden = true
            downloadProgressView.progress = Float(progress)
        }
    }
}
