//
//  FlagTableViewCell.swift
//  Safe Wickers
//
//  Created by 匡正 on 8/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class FlagTableViewCell: UITableViewCell {
    @IBOutlet weak var flagImageView: UIImageView!
    
    @IBOutlet weak var flagNameLabel: UILabel!
    
    @IBOutlet weak var meaningLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let mScreenSize = UIScreen.main.bounds
//        let mSeparatorHeight = CGFloat(2.0) // Change height of speatator as you want
//        let mAddSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height - mSeparatorHeight - 1, width: mScreenSize.width, height: mSeparatorHeight))
//        mAddSeparator.backgroundColor = UIColor(red:0.27, green:0.45, blue:0.58, alpha:1) // Change backgroundColor of separator
//        self.addSubview(mAddSeparator)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
