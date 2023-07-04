//
//  TidesData.swift
//  Safe Wickers
//
//  Created by 匡正 on 10/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class TidesData: NSObject, Decodable {
    
    var tides: [TideData]?
    var heights: [TideHeight]?

    private enum CodingKeys: String, CodingKey{
        case tides = "extremes"
        case heights = "heights"
    }
}
