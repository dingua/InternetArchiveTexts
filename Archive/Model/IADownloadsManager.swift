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
    
    var filesQueue : Array<FileDownloadStatus>? = []
    
    var totalProgress: Double? {
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
        
        Alamofire.download(.GET, "https://\(file.server!)\(file.directory!)/\(chapter.subdirectory!)_\(type!).zip", destination: destination)
            .response { request, response, _, error in
                print("unzeep succeed = \(SSZipArchive.unzipFileAtPath((destination(NSURL(string: "")!, response!).absoluteString as NSString).substringFromIndex(7), toDestination: "\(self.docuementsDirectory())"))")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "\(chapter.subdirectory!)_\(type!)")

                self.filesQueue?.indexOf({$0.file?.identifier == file.identifier && $0.chapter?.name == chapter.name}).map({
                    if let file = self.filesQueue![$0].file {
                        self.saveStoredFile(file)
                    }
                    self.filesQueue!.removeAtIndex($0)
                    if self.filesQueue?.count == 0 {IATabBarController.sharedInstance.downloadProgress = 0}
                    IATabBarController.sharedInstance.downloadDone()
                })
            }.progress{ bytesRead, totalBytesRead, totalBytesExpectedToRead in
                self.filesQueue?.indexOf({$0.file?.identifier == file.identifier && $0.chapter?.name == chapter.name}).map({
                    self.filesQueue![$0].totalBytesRead = totalBytesRead
                    self.filesQueue![$0].totalBytesExpectedToRead = totalBytesExpectedToRead
                    IATabBarController.sharedInstance.downloadProgress = Float(self.totalProgress!)
                    }
                )
        }
        
    }
    
    private func saveStoredFile(file : FileData!) {
        let fileData = NSKeyedArchiver.archivedDataWithRootObject(file)
        NSUserDefaults.standardUserDefaults().setObject(fileData, forKey: "file_\(file.identifier!)")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    //MARK: - Helpers
    
    func docuementsDirectory()->String {
        let paths =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    func isChapterStored(chapter: ChapterData)->Bool {
        let type = chapter.type?.rawValue.lowercaseString
        return NSUserDefaults.standardUserDefaults().boolForKey("\(chapter.subdirectory!)_\(type!)")
    }
}