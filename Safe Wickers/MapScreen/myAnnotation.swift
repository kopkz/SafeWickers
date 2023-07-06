//
//  myAnnotation.swift
//  retest
//
//  Created by 郑维天 on 21/4/20.
//  Copyright © 2020 郑维天. All rights reserved.
//

import MapKit
class myAnnotation: NSObject, MKAnnotation
{
    let title: String?
    let distance: Double?
    let discipline:String?
    let coordinate: CLLocationCoordinate2D
    let ifSafe: String?
    
    init(title:String, distance:Double, discipline:String, coordinate:CLLocationCoordinate2D, ifSafe: String) {
        self.title = title
        self.distance = distance
        self.discipline = discipline
        self.coordinate = coordinate
        self.ifSafe = ifSafe
        
        super.init()
    }
    var subtitle: String?
    {
        let distacnceString = "\(distance!/1000) km"
        return distacnceString
        
    }
    
    
    //marker tint color for discipline
    
    var  markerTintColor: UIColor
    {
        switch ifSafe {
        case "h":
            return .red
        case "l":
            return .green
        case "m":
            return .yellow
        default:
            return .black
        }
    }
    
    var imageName: String?
    {
        switch ifSafe {
        case "h":
            return "highRisk"
        case "l":
            return "lowRisk"
        case "m":
            return "midRisk"
        default:
            return nil
        }
    }
}
