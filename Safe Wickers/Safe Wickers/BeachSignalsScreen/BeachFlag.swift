//
//  BeachFlag.swift
//  Safe Wickers
//
//  Created by 匡正 on 8/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class BeachFlag: NSObject {

    var flagName: String?
    var meaning: String?
    var des: String?
    var imageName: String?
    
    init(flagName: String, meaning: String, des: String, imageName: String) {
        self.flagName = flagName
        self.meaning = meaning
        self.des = des
        self.imageName = imageName
    }
}
