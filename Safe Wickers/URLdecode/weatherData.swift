//
//  weatherData.swift
//  Safe Wickers
//
//  Created by 匡正 on 24/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import Foundation

class WeatherURLData: NSObject, Decodable {
    var temp: Double
    var pressure: Double
    var humidity: Double
    var windSpeed: Double
    
    private enum WeatherKeys: String, CodingKey{
        case main
    }
    private enum WindKeys: String, CodingKey{
        case wind
    }
    private enum infoKeys: String, CodingKey{
        case temp
        case pressure
        case humidity
    }
    private enum speedKeys: String, CodingKey{
    case speed
    }
    
    required init(from decoder: Decoder) throws {
        let maincontainer = try decoder.container(keyedBy: WeatherKeys.self)
        let infocontainer = try maincontainer.nestedContainer(keyedBy: infoKeys.self, forKey: .main)
        let windcontainer = try decoder.container(keyedBy: WindKeys.self)
        let speedcontainer = try windcontainer.nestedContainer(keyedBy: speedKeys.self, forKey: .wind)
        self.temp = try infocontainer.decode(Double.self, forKey: .temp)
        self.pressure = try infocontainer.decode(Double.self, forKey: .pressure)
        self.humidity = try infocontainer.decode(Double.self, forKey: .humidity)
        self.windSpeed = try speedcontainer.decode(Double.self, forKey: .speed)
    }
}
