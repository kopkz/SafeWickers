//
//  HelpTableViewCell.swift
//  Safe Wickers
//
//  Created by 匡正 on 15/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class HelpTableViewCell: UITableViewCell {

    @IBOutlet weak var helpItemLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
