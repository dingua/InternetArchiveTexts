//
//  IADownloadsManager.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/3/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import Foundation
import Alamofire
import SSZipArchive

class IADownloadsManager {
    static let sharedInstance = IADownloadsManager()
    
    struct FileDownloadStatus {
        var file: FileData?
        var chapter: ChapterData?
        var totalBytesRead: Int64?
        var totalBytesExpectedToRead: Int64?
    }
    
    private var filesQueue : Array<FileDownloadStatus>? = []
    
    private var totalProgress: Double? {
        get {
            var totalBytesRead: Int64 = 0
            var totalBytesExpectedToRead: Int64 = 0
            for file in filesQueue! {
                totalBytesRead += file.totalBytesRead!
                totalBytesExpectedToRead += file.totalBytesExpectedToRead!
            }
            return Double(Float(totalBytesRead)/Float(totalBytesExpectedToRead))
        }
    }
    
    
    func download(chapter: ChapterData, file: FileData) {
        let fileStatus = FileDownloadStatus(file: file, chapter: chapter, totalBytesRead: 0, totalBytesExpectedToRead: 0)
        filesQueue?.append(fileStatus)
        let destination = Alamofire.Request.suggestedDownloadDestination(
            directory: .CachesDirectory,
            domain: .UserDomainMask
        )
        let type = chapter.type?.rawValue.lowercaseString
        self.saveStoredFile(file)
        Chapter.markChapterDownloadingState(chapter.name!, itemId: file.identifier!)
        Alamofire.download(.GET, "https://\(file.server!)\(file.directory!)/\(chapter.subdirectory!)_\(type!).zip", destination: destination)
            .response { request, response, _, error in
                let unzipSucceed = (SSZipArchive.unzipFileAtPath((destination(NSURL(string: "")!, response!).absoluteString as NSString).substringFromIndex(7), toDestination: "\(self.docuementsDirectory())"))
                if unzipSucceed {
                    self.filesQueue?.indexOf({$0.file?.identifier == file.identifier && $0.chapter?.name == chapter.name}).map({
                        if let file = self.filesQueue![$0].file {
                            Chapter.markChapterDownloaded(chapter.name!, itemId: file.identifier!)
                        }
                        self.filesQueue!.removeAtIndex($0)
                        if self.filesQueue?.count == 0 {IATabBarController.sharedInstance.downloadProgress = 0}
                        IATabBarController.sharedInstance.downloadDone()
                        NSNotificationCenter.defaultCenter().postNotificationName("\(chapter.name!)_finished", object:  nil)
                        
                    })
                }
            }.progress{ bytesRead, totalBytesRead, totalBytesExpectedToRead in
                self.filesQueue?.indexOf({$0.file?.identifier == file.identifier && $0.chapter?.name == chapter.name}).map({
                    self.filesQueue![$0].totalBytesRead = totalBytesRead
                    self.filesQueue![$0].totalBytesExpectedToRead = totalBytesExpectedToRead
                    IATabBarController.sharedInstance.downloadProgress = Float(self.totalProgress!)
                    NSNotificationCenter.defaultCenter().postNotificationName("\(chapter.name!)_progress", object:  Double(Float(totalBytesRead)/Float(totalBytesExpectedToRead)))
                    }
                )
        }
        
    }
    
    private func saveStoredFile(file : FileData!) {
        File.createFileWithData(file)
    }
    
    func getDownloadedChapters()->NSArray? {
        return Chapter.getDownloadedChapters()
    }
    
    func getChaptersInDownloadState() -> NSArray? {
       return  Chapter.getChaptersInDownloadState()
    }
    
    func getDownloadQueue()->[FileDownloadStatus]? {
        return filesQueue
    }
    
    func resumeDownloads() {
        print("cache = \(NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])")
        let chaptersInDownloadState = self.getChaptersInDownloadState()
        for chapter in chaptersInDownloadState as! [Chapter] {
            self.download(ChapterData(chapter: chapter), file: FileData(file: chapter.file!))
        }
    }
    
    //MARK: - Helpers
    
    func docuementsDirectory()->String {
        let paths =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func pathInDownloadChapter(chapter: Chapter) -> String?{
        let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        return "\(cacheDirectoryPath)/\(chapter.name!)"
    }
    
    func isChapterStored(chapter: ChapterData)->Bool {
        let type = chapter.type?.rawValue.lowercaseString
        return NSUserDefaults.standardUserDefaults().boolForKey("\(chapter.subdirectory!)_\(type!)")
    }
}