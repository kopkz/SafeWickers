//
//  FilterButtonTableViewCell.swift
//  Safe Wickers
//
//  Created by 匡正 on 25/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

protocol FilterCellDelegate{
    func showSortingMenue()
}

class FilterButtonTableViewCell: UITableViewCell {
   
    @IBOutlet weak var showSortingMenueButton: UIButton!
    
    var delegate: FilterCellDelegate?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showSortingMenueButton.setTitle(NSLocalizedString("beach_list_showSortingMenueButton", comment: "beach_list_showSortingMenueButton"), for: .init())
        showSortingMenueButton.layer.borderColor = UIColor(red:0.27, green:0.45, blue:0.58, alpha:1).cgColor
        showSortingMenueButton.tintColor = UIColor(red:0.27, green:0.45, blue:0.58, alpha:1)
        showSortingMenueButton.layer.borderWidth = 1
        showSortingMenueButton.layer.cornerRadius = 5
        showSortingMenueButton.addTarget(self, action: #selector(showMenue), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func showMenue(){
        delegate?.showSortingMenue()
    }
    
    
}
