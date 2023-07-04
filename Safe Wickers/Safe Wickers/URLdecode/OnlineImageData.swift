//
//  OnlineImages.swift
//  Safe Wickers
//
//  Created by 匡正 on 23/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import Foundation

class OnlineImageData: NSObject, Decodable{
    var onlineImages: [ImageURLData]?
    
    private enum CodingKeys: String, CodingKey{
        case onlineImages = "items"
    }
}
