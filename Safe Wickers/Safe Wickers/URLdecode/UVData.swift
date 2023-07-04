//
//  UVData.swift
//  Safe Wickers
//
//  Created by 匡正 on 10/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class UVData: NSObject, Decodable {

    var uv: Double?
    
    private enum Rootkey: String, CodingKey {
        case result
    }
    private enum UVKey: String, CodingKey {
        case uv
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Rootkey.self)
        let uvCoontainer = try container.nestedContainer(keyedBy: UVKey.self, forKey: .result)
        self.uv = try uvCoontainer.decode(Double.self, forKey: .uv)
    }
    
}
