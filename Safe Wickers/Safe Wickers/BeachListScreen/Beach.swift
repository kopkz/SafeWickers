//
//  Beach.swift
//  Safe Wickers
//
//  Created by 匡正 on 21/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class Beach: NSObject {
    var beachName: String?
    var latitude: Double?
    var longitude: Double?
    var imageName: String?
    var distance: Double?
    var risk: String?
    var ifGuard: Bool?
    var ifPort: Bool?
    var descrip: String?
    var windSpeed: Double?
    var temp: Double?
    var hum: Double?
    var pre: Double?
    var ifLoved: Bool?
    var uv: Double?
    var tideState: String?
    var tideHeight: Double?
    
    init(beachName: String, latitude: Double, longitude: Double, imageName: String, distance: Double, risk: String, ifGuard: Bool, ifPort: Bool, descrip: String, windSpeed: Double, temp: Double, hum: Double, pre: Double, ifLoved: Bool, uv: Double, tideState: String, tideHeight: Double) {
        self.beachName = beachName
        self.latitude = latitude
        self.longitude = longitude
        self.imageName = imageName
        self.distance = distance
        self.risk = risk
        self.ifGuard = ifGuard
        self.ifPort = ifPort
        self.descrip = descrip
        self.windSpeed = windSpeed
        self.temp = temp
        self.hum = hum
        self.pre = pre
        self.ifLoved = ifLoved
        self.uv = uv
        self.tideState = tideState
        self.tideHeight = tideHeight
    }
    
    
}
