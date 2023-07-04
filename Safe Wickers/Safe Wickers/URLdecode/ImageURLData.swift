//
//  ImageURLData.swift
//  Safe Wickers
//
//  Created by 匡正 on 23/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import Foundation

class ImageURLData: NSObject, Decodable {
    var imageURL: String?
    
    private enum imageKeys: String, CodingKey{
        case imageURL = "link"
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: imageKeys.self)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
    }
}
