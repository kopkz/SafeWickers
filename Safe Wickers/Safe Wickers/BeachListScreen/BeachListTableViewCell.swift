//
//  BeachListTableViewCell.swift
//  Safe Wickers
//
//  Created by 匡正 on 20/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import Cosmos
protocol LoveBeachDelagate {
    func loveUnloveBeach(beach: Beach)
}

class BeachListTableViewCell: UITableViewCell {
   
    @IBOutlet weak var loveUnloveButton: LoveButton!
    @IBOutlet weak var riskImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var beachNameLabel: UILabel!
    @IBOutlet weak var beachImage: UIImageView!
    @IBOutlet weak var riskLevelLabel: UILabel!
    
    @IBOutlet weak var cosmosView: CosmosView!
    var delegate: LoveBeachDelagate?
    var beachItem: Beach!
    var rating: Double?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        loveUnloveButton.addTarget(self, action: #selector(loveUnloveButtonTaped), for: .touchUpInside)
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
        //loveUnloveButton.isLove = beachItem.ifLoved!
        
        
    }
    func setBeach(beach: Beach){
        beachItem = beach
    }
    func setRating(rating: Double) {
        self.rating = rating
//        if self.rating == 0 {
//            cosmosView.rating = 1
//        } else{
            cosmosView.rating = rating
//        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func loveUnloveButtonTaped(){
        delegate?.loveUnloveBeach(beach: beachItem)
    }

}
