//
//  ActivityCollectionViewCell.swift
//  Safe Wickers
//
//  Created by 匡正 on 17/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class ActivityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityImageView: UIImageView!
    
    /// selected activity will have diffent colour
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nilView = UIView(frame: bounds)
        nilView.backgroundColor = nil
        self.backgroundView = nilView
        
        let blueView = UIView(frame: bounds)
        blueView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1)
        self.selectedBackgroundView = blueView
    }
}
