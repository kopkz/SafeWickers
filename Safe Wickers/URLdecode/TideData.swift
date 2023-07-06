//
//  TideData.swift
//  Safe Wickers
//
//  Created by 匡正 on 10/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class TideData: NSObject, Decodable {
    var tideTimeStamp: Int?
    var tideState: String?
    
    private enum tideKey: String, CodingKey{
        case timestamp
        case state
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: tideKey.self)
        self.tideTimeStamp = try container.decode(Int.self, forKey: .timestamp)
        self.tideState = try container.decode(String.self, forKey: .state)
    }
    
}
