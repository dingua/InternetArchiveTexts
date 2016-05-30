//
//  IABookDetailsTableViewCell.swift
//  Archive
//
//  Created by Mejdi Lassidi on 5/25/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import FRHyperLabel

class IABookDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var paramLabel: UILabel!
   
    @IBOutlet weak var valueLabel: FRHyperLabel!
    
    var collectionItemTapHandler: ((index: Int, title: String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(parameter: Parameter)->IABookDetailsTableViewCell {
        paramLabel.text = parameter.key
         let attributes = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        valueLabel.attributedText = NSAttributedString(string: parameter.value, attributes: attributes)
        if parameter.type == .Collection || parameter.type == .Uploader || parameter.type == .Subject || parameter.type == .Author {
            let titles = parameter.value.componentsSeparatedByString("\n")
            for title in titles {
                let myText = valueLabel.text! as NSString
                let range = myText.rangeOfString(title)
                valueLabel.setLinkForRange(range, withLinkHandler: { (_, range) in
                    let text = myText.substringWithRange(range)
                    self.collectionItemTapHandler!(index: titles.indexOf(text)!,title: text)
                })}
        }
        return self
    }
}
