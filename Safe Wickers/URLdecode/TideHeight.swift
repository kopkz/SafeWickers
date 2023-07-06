//
//  TideHeight.swift
//  Safe Wickers
//
//  Created by 匡正 on 11/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class TideHeight: NSObject, Decodable {
    var height: Double?
    private enum heightKey: String, CodingKey {
        case height
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: heightKey.self)
        self.height = try container.decode(Double.self, forKey: .height).rounded()
    }
}
