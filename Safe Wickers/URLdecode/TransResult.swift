//
//  TransResult.swift
//  Safe Wickers
//
//  Created by 匡正 on 9/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class TransResult: NSObject, Decodable {
    var result: String?
    
    private enum RootKey: String, CodingKey {
        case dst
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        self.result = try container.decode(String.self, forKey: .dst)
    }
    
}
