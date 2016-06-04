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

private let SingleParamaterCellIdentifier = "SingleParameterCell"
private let MultipleParameterCellIdentifier = "MutlpleParameterCell"
private let ChapterCellIdentifier = "ChapterCell"

enum ParamaterType {
    case Normal
    case Collection
    case Subject
    case Uploader
    case Author
}

struct Parameter {
    let title: String
    var values: [String]?
    let type: ParamaterType
}

class IABookDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, IALoadingViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource {
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
    
    
    @IBOutlet weak var bookTitleLabel: UILabel!
   
    @IBOutlet weak var parametersTVHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addLoadingView()
        loadDetails()
        loadChapters()
        parametersTableView.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
    }
    
   deinit {
        parametersTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    func prepareUI() {
        activityIndicatorView = DGActivityIndicatorView(type: .ThreeDots, tintColor: UIColor.blackColor())
        imageView.af_setImageWithURL(Constants.URL.ImageURL(book!.identifier!).url)
        bookTitleLabel.text = book!.title ?? ""
        segmentControl.hidden = true
        parametersTableView.hidden = true
        parametersTableView.estimatedRowHeight = 20
        parametersTableView.rowHeight = UITableViewAutomaticDimension
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        segmentControl.tintColor = UIColor.blackColor()
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
        if let file = self.book!.file {
            self.chapters = (file.chapters?.allObjects as! [Chapter]).sort({$0.name<$1.name})
        }
        self.chaptersLoaded = true
        self.parametersTableView.reloadData()
        if self.segmentControl.selectedSegmentIndex == 1 {
            self.removeLoadingView()
        }
    }
    
    func populateData() {
        if let book = book {
            if let description = book.desc {
                self.parameters.append((Parameter(title:"Description", values:[description], type: .Normal)))
            }
            if let uploader = book.uploader {
                self.parameters.append(Parameter(title:"Uploader", values:[uploader], type: .Uploader))
            }
            if let publisher = book.publisher {
                self.parameters.append(Parameter(title:"Publisher", values:[publisher], type: .Normal))
            }
            if let authors = authors() {
                let authorNames = authors.flatMap({$0.name})
                if authorNames.count != 0 {
                    self.parameters.append(Parameter(title: "Author", values: authorNames, type: .Author))
                }
            }
            if let collections = sortedCollections() {
                let collectionTitles = collections.flatMap({$0.title})
                if collectionTitles.count != 0 {
                    self.parameters.append(Parameter(title:"Collection", values: collectionTitles, type: .Collection))
                }
            }
            if let subjects = subjects() {
                let subjectNames = subjects.flatMap({$0.name})
                if subjectNames.count != 0 {
                    self.parameters.append(Parameter(title: "Subjects", values: subjectNames, type: .Subject))
                }
            }
            self.parametersTableView.reloadData()
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
        return segmentControl.selectedSegmentIndex == 0 ? parameters.count ?? 0 : chapters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segmentControl.selectedSegmentIndex == 0 {
            let parameter = parameters[indexPath.row]
            if parameter.type == .Collection || parameter.type == .Uploader || parameter.type == .Subject || parameter.type == .Author {
                let cell = tableView.dequeueReusableCellWithIdentifier(MultipleParameterCellIdentifier) as! IABookDetailsMultipleParamCell
                cell.configure(parameter,index: indexPath.row)
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier(SingleParamaterCellIdentifier) as! IABookDetailsSingleParamCell
                cell.configure(parameter)
                return cell
            }
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(ChapterCellIdentifier)
            cell?.textLabel?.text = chapters[indexPath.row].name
            return cell!
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if segmentControl.selectedSegmentIndex == 1{
            openReader(atChapter: indexPath.row)
         }
    }
   
    //MARK: - UICollectionViewDelegate (CollectionView included in MultipleParamCell)
   
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let index = (collectionView as! IABookDetailsCollectionView).parameterIndex {
            let parameter = parameters[index]
            return parameter.values?.count ?? 0
        }else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("detailsCollectionViewCell", forIndexPath: indexPath) as! IABookDetailsCollectionViewCell
        let parameter = parameters[(collectionView as! IABookDetailsCollectionView).parameterIndex!]
        cell.label.text = parameter.values![indexPath.row] ?? ""
        return cell
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let parameter = parameters[(collectionView as! IABookDetailsCollectionView).parameterIndex!]
        switch parameter.type {
        case .Collection:
            if let collections = self.sortedCollections() {
                let collection = collections[indexPath.row]
                    self.presentList(collection.identifier!,type:.Collection)
            }
            break
        case .Uploader:
            if let uploaders = parameter.values {
                let uploader = uploaders[indexPath.row]
                    self.presentList(uploader,type:.Uploader)
            }
            break
        case .Subject:
            if let subjects = parameter.values {
                let subject = subjects[indexPath.row]
                    self.presentList(subject,type:.Subject)
            }
            break
        case .Author:
            if let authors = parameter.values {
                let author = authors[indexPath.row]
                    self.presentList(author,type:.Creator)
            }
            break
            
        default:
            break
        }

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let parameter = parameters[(collectionView as! IABookDetailsCollectionView).parameterIndex!]
        let text = parameter.values![indexPath.row] ?? ""
        let font = UIFont(name: "HelveticaNeue", size: 16)!
        let rect = text.boundingRectWithSize(CGSizeMake(1000,1000), options: .UsesLineFragmentOrigin, attributes: ([NSFontAttributeName:font]), context: nil)
        return rect.size
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

    func presentList(text:String?, type: IABookListType) {
        if Utils.isiPad() {
            self.dismissViewControllerAnimated(true){
                self.pushListOnDismiss!(text: text, type: type)
            }
        }else {
            pushList(text, type: type)
        }
    }
    
    func pushList(text:String?, type: IABookListType) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let itemsListVC = storyboard.instantiateViewControllerWithIdentifier("bookListVC") as! IAItemsListVC
        itemsListVC.loadList(text ?? "", type: type)
        self.navigationController?.pushViewController(itemsListVC, animated: true)
    }
    
    func openReader(atChapter chapterIndex :Int = 0){
        if Utils.isiPad() {
            if let pushReaderOnChapter = pushReaderOnChapter {
                self.dismissViewControllerAnimated(true){
                    pushReaderOnChapter(chapterIndex: chapterIndex)
                }
            }
        }else {
            showReader(book!, atChapterIndex: chapterIndex)
        }
    }
    
    func showReader(item: ArchiveItem, atChapterIndex chapterIndex :Int = 0) {
        let navController = UIStoryboard(name: "Reader",bundle: nil).instantiateInitialViewController() as! UINavigationController
        let bookReader = navController.topViewController as! IAReaderVC
        bookReader.item = item
        bookReader.didGetFileDetailsCompletion = {
            bookReader.setupReaderToChapter(chapterIndex)
        }
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    func addLoadingView() {
        addLoadingView(yOffset: loadingViewYOffset)
    }
  
    //MARK: - IBAction
   
    @IBAction func segmentControlValueChange() {
        switch  segmentControl.selectedSegmentIndex{
        case 0:
            if detailsLoaded {
                removeLoadingView()
            }else {
                addLoadingView()
            }
            break
        case 1:
            if chaptersLoaded {
                removeLoadingView()
            }else {
                addLoadingView()
            }
            break
        default:
            break
        }
        parametersTableView.reloadData()
    }

    @IBAction func openButtonPressed(sender: AnyObject) {
        openReader()
    }
    
    //MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentSize" {
            self.parametersTVHeightConstraint.constant = self.parametersTableView.contentSize.height
        }
    }
}
