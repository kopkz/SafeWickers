//
//  myAnnotationView.swift
//  retest
//
//  Created by 郑维天 on 21/4/20.
//  Copyright © 2020 郑维天. All rights reserved.
//

import MapKit

class myAnnotationView: MKMarkerAnnotationView
{
    
    override var annotation: MKAnnotation?
        {
        
        willSet
        {
            
            guard let _myAnnotation = newValue as? myAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            markerTintColor = _myAnnotation.markerTintColor
            //glyphText = String(_myAnnotation.discipline.first!)
            if let imageName = _myAnnotation.imageName
            {
                glyphImage = UIImage(named: imageName)
            }
            else
            {
                glyphImage = nil
            }
        }
        
        
    }
    
    
}
