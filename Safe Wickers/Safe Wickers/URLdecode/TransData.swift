//
//  TransData.swift
//  Safe Wickers
//
//  Created by 匡正 on 9/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//
import UIKit

class TransData: NSObject, Decodable {
    
    var transResults: [TransResult]?
    
    private enum CodingKeys: String, CodingKey {
        case transResults = "trans_result"
    }
}
