//
//  IABookDetailsTableViewCell.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/25/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IABookDetailsSingleParamCell: UITableViewCell {

    @IBOutlet weak var paramLabel: UILabel!
   
    @IBOutlet weak var valueLabel: UILabel!
    
    func configure(parameter: Parameter) {
        paramLabel.text = parameter.title
        valueLabel.text = parameter.values?.first ?? ""
    }
}

class IABookDetailsMultipleParamCell: UITableViewCell {
    
    @IBOutlet weak var paramLabel: UILabel!
    @IBOutlet weak var collectionView: IABookDetailsCollectionView!
    
    func configure(parameter: Parameter, index: Int) {
        paramLabel.text = parameter.title
        collectionView.parameterIndex = index
        collectionView.reloadData()
    }
    
    override func systemLayoutSizeFittingSize(targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        collectionView.layoutIfNeeded()
        let size = collectionView.collectionViewLayout.collectionViewContentSize()
        return CGSizeMake(size.width, size.height+20)
    }
}