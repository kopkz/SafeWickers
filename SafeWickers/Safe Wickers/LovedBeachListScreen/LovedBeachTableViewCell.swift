//
//  LovedBeachTableViewCell.swift
//  Safe Wickers
//
//  Created by 匡正 on 26/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import Cosmos

class LovedBeachTableViewCell: UITableViewCell {

    @IBOutlet weak var beachImageView: UIImageView!
    @IBOutlet weak var beachNameLabel: UILabel!
    
    @IBOutlet weak var cosmosView: CosmosView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setRating(rating: Double) {
        cosmosView.rating = rating
    }

}
