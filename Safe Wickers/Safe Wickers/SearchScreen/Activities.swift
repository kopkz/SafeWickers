//
//  Activities.swift
//  Safe Wickers
//
//  Created by 匡正 on 17/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class Activities: NSObject {
    var imageName: String?
    var activityName : String?
    
    init(imageName: String, activityName: String) {
        self.imageName = imageName
        self.activityName = activityName
    }

}
