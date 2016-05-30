//
//  IABookDetailsVC.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/23/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData
import DGActivityIndicatorView

private let paramaterCellIdentifier = "ParameterCell"
private let chapterCellIdentifier = "ChapterCell"

enum ParamaterType {
    case Normal
    case Collection
    case Subject
    case Uploader
    case Author
}

struct Parameter {
    let key: String
    let value: String
    let type: ParamaterType
}
class IABookDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, IALoadingViewProtocol {
    var activityIndicatorView : DGActivityIndicatorView?
    var parameters = [Parameter]()
    var chapters = [Chapter]()
    var book: ArchiveItem?
    var pushListOnDismiss: ((text: String?, type: IABookListType)->())?

    var pushReaderOnChapter: ((chapterIndex: Int)->())?

    var chaptersLoaded = false
    var detailsLoaded = false
    private let loadingViewYOffset = CGFloat(100.0)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var parametersTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var chaptersTableView: UITableView!
    
    @IBOutlet weak var bookTitleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
        imageView.af_setImageWithURL(Constants.URL.ImageURL(book!.identifier!).url)
        bookTitleLabel.text = book!.title ?? ""
        segmentControl.hidden = true
        parametersTableView.hidden = true
        chaptersTableView.hidden = true
        addLoadingView()
        loadDetails()
        loadChapters()
        parametersTableView.estimatedRowHeight = 44
        parametersTableView.rowHeight = UITableViewAutomaticDimension
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        segmentControl.tintColor = UIColor.blackColor()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadDetails() {
        parameters.removeAll()
        let itemManager = IAItemsManager()
        if let book = book {
            let group = dispatch_group_create()
            if book.collections?.count == 0 || book.uploader == nil {
                dispatch_group_enter(group)
                itemManager.itemMetadataDetails(book.identifier!/*, item: book*/, completion: { dictionary in
                    if book.collections?.count == 0 {
                        if let collections = dictionary["collection"] as? [String] {
                            for collection in collections {
                                dispatch_group_enter(group)
                                itemManager.itemMetadataDetails(collection, completion: { dictionary in
                                    book.addCollection(dictionary)
                                    dispatch_group_leave(group)
                                })
                            }
                        }else if let collection = dictionary["collection"] as? String {
                            dispatch_group_enter(group)
                            itemManager.itemMetadataDetails(collection, completion: { dictionary in
                                book.addCollection(dictionary)
                                dispatch_group_leave(group)
                            })
                        }
                    }
                    if book.uploader == nil {
                        if let uploader = dictionary["uploader"] as? String {
                            book.setupUploader(uploader)
                        }
                    }
                    dispatch_group_leave(group)
                    dispatch_group_notify(group, dispatch_get_main_queue(), {
                        self.detailsLoaded = true
                        self.populateData()
                    })
                })
            }else {
                self.detailsLoaded = true
                self.populateData()
            }
            
        }
    }
    
    
    func loadChapters() {
        if let _ = self.book?.file?.chapters {
            showChapters()
        }else {
            let itemManager = IAItemsManager()
            itemManager.itemChapters(book!) {
                self.showChapters()
            }
        }
    }
    
    func showChapters() {
        print("chapters loaded")
        if let file = self.book!.file {
            self.chapters = (file.chapters?.allObjects as! [Chapter]).sort({$0.name<$1.name})
        }
        self.chaptersLoaded = true
        self.chaptersTableView.reloadData()
        if self.segmentControl.selectedSegmentIndex == 1 {
            self.removeLoadingView()
            self.chaptersTableView.hidden = false
        }
    }
    
    func populateData() {
        if let book = book {
            if let description = book.desc {
                self.parameters.append((Parameter(key:"Description",value:description, type: .Normal)))
            }
            if let uploader = book.uploader {
                self.parameters.append(Parameter(key:"Uploader",value:uploader, type: .Uploader))
            }
            if let publisher = book.publisher {
                self.parameters.append(Parameter(key:"publisher",value:publisher, type: .Normal))
            }
            if let authors = authors() {
                let authorNames = authors.flatMap({$0.name})
                if authorNames.count != 0 {
                    self.parameters.append(Parameter(key: "Author", value: authorNames.joinWithSeparator("\n"), type: .Author))
                }
            }
            if let collections = sortedCollections() {
                let collectionTitles = collections.flatMap({$0.title})
                if collectionTitles.count != 0 {
                    self.parameters.append(Parameter(key:"Collection",value:collectionTitles.joinWithSeparator("\n"), type: .Collection))
                }
            }
            if let subjects = subjects() {
                let subjectNames = subjects.flatMap({$0.name})
                if subjectNames.count != 0 {
                    self.parameters.append(Parameter(key: "Subjects", value: subjectNames.joinWithSeparator("\n"), type: .Subject))
                }
            }
            self.parametersTableView.reloadData()
            self.chaptersTableView.reloadData()
            if self.segmentControl.selectedSegmentIndex == 0 {
                self.removeLoadingView()
                parametersTableView.hidden = false
            }
            imageView.hidden = false
            bookTitleLabel.hidden = false
            segmentControl.hidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - TableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == parametersTableView ? parameters.count ?? 0 : chapters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == parametersTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(paramaterCellIdentifier) as! IABookDetailsTableViewCell
            let item = parameters[indexPath.row]
            cell.configure(item).collectionItemTapHandler = { (index,title) in
                switch item.type {
                case .Collection:
                    if let collections = self.sortedCollections() {
                        let collection = collections[index]
                        if collection.title == title {
                            self.presentList(collection.identifier!,type:.Collection)
                        }
                    }
                    break
                case .Uploader:
                    if let uploaders = self.uploaders() {
                        let uploader = uploaders[index]
                        if uploader == title {
                            self.presentList(uploader,type:.Uploader)
                        }
                    }
                    break
                case .Subject:
                    if let subjects = self.subjects() {
                        let subject = subjects[index]
                        if subject.name == title {
                            self.presentList(subject.name,type:.Subject)
                        }
                    }
                    break
                case .Author:
                    if let authors = self.authors() {
                        let author = authors[index]
                        if author.name == title {
                            self.presentList(author.name,type:.Creator)
                        }
                    }
                    break
                    
                default:
                    break
                }
                
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(chapterCellIdentifier)
            cell?.textLabel?.text = chapters[indexPath.row].name
            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == chaptersTableView {
            if let pushReaderOnChapter = pushReaderOnChapter {
                self.dismissViewControllerAnimated(true){
                    pushReaderOnChapter(chapterIndex: indexPath.row)
                }
            }
        }
    }
    
    //MARK: - Helper
    
    func sortedCollections()->[ArchiveItem]? {
        if let collections = (book?.collections?.allObjects as? [ArchiveItem]) {
            return collections.sort({$0.title > $1.title})
        }else {
            return nil
        }
    }

    func subjects()->[Subject]? {
        if let subjects = (book?.subjects?.allObjects as? [Subject]) {
            return subjects.sort({$0.name > $1.name})
        }else {
            return nil
        }
    }

    func authors()->[Author]? {
        if let authors = (book?.authors?.allObjects as? [Author]) {
            return authors.sort({$0.name > $1.name})
        }else {
            return nil
        }
    }

    func uploaders()->[String]? {
        return book?.uploader?.componentsSeparatedByString("\n")
    }
    
    func presentList(text:String?, type: IABookListType) {
        self.dismissViewControllerAnimated(true){
            self.pushListOnDismiss!(text: text, type: type)
        }
    }
    
    func addLoadingView() {
        addLoadingView(yOffset: loadingViewYOffset)
    }
    //MARK: - IBAction
    @IBAction func segmentControlValueChange() {
        switch  segmentControl.selectedSegmentIndex{
        case 0:
            chaptersTableView.hidden = true
            if detailsLoaded {
                removeLoadingView()
                parametersTableView.hidden = false
            }else {
                addLoadingView()
                parametersTableView.hidden = true
            }
            break
        case 1:
            parametersTableView.hidden = true
            if chaptersLoaded {
                removeLoadingView()
                chaptersTableView.hidden = false
            }else {
                addLoadingView()
                chaptersTableView.hidden = true
            }
            break
        default:
            break
        }
    }
}
