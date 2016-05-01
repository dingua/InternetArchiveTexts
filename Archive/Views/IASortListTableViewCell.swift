//
//  IASortListTableViewCell.swift
//  Archive
//
//  Created by Mejdi Lassidi on 2/8/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit

class IASortListTableViewCell: UITableViewCell {

    @IBOutlet weak var optionImageView: UIImageView!
    @IBOutlet weak var optionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
