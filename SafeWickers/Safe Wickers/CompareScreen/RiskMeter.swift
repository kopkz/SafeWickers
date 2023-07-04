//
//  RiskMeter.swift
//  Safe Wickers
//
//  Created by 匡正 on 17/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class RiskMeter: UIView {

  
    let meterDiameter:CGFloat = 80
    
    let meterWidth:CGFloat = 8
    
    let trackColor = UIColor.lightGray
    
    var meterLayer:CAShapeLayer!
    
    var meterText:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // the text in the meter
        meterText = UILabel(frame:CGRect(x:0, y:0, width:bounds.width, height:meterDiameter))
        //set the text position
        meterText.textAlignment = .center
        //set default number
        meterText.text = "N/A"
        self.addSubview(meterText)
        
        // The track and the path of the progress bar above (at the middle level within the component)
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: 40),
                                radius: (meterDiameter - meterWidth)/2,
                                startAngle: toRadians(degrees: -210),
                                endAngle: toRadians(degrees: 30),
                                clockwise: true)
        
        //Progress Bar Background
        let trackLayer = CAShapeLayer()
        trackLayer.frame = self.bounds
        trackLayer.fillColor = UIColor.clear.cgColor
        //track color
        trackLayer.strokeColor = trackColor.cgColor
        //track transparency
        trackLayer.opacity = 0.25
        //Round corners for track
        trackLayer.lineCap = CAShapeLayerLineCap.round
        //meterWidth
        trackLayer.lineWidth = meterWidth
        //track path
        trackLayer.path = path.cgPath
        self.layer.addSublayer(trackLayer)
        
        //Draw progress bar
        meterLayer = CAShapeLayer()
        meterLayer.frame = self.bounds
        meterLayer.fillColor = UIColor.clear.cgColor
        meterLayer.strokeColor = UIColor.black.cgColor
        meterLayer.lineCap = CAShapeLayerLineCap.round
        meterLayer.lineWidth = meterWidth
        meterLayer.path = path.cgPath
        //The default end position of the progress bar is 0
        meterLayer.strokeEnd = 0
        self.layer.addSublayer(meterLayer)
        
        //the leftside, from yellow to bule (up to down)
        let gradientLayer1 = CAGradientLayer()
        gradientLayer1.frame = CGRect(x:0, y:0, width:self.frame.width/2,
                                      height:meterDiameter/4 * 3 + meterWidth)
        gradientLayer1.colors = [UIColor.yellow.cgColor,
                                 UIColor.green.cgColor,
                                 UIColor.cyan.cgColor,
                                 UIColor.blue.cgColor]
        gradientLayer1.locations = [0.1,0.4,0.6,1]
        
        //the rightside, from yellow to red (up to down)
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.frame = CGRect(x:self.frame.width/2, y:0, width:self.frame.width/2,
                                      height:meterDiameter/4 * 3 + meterWidth)
        gradientLayer2.colors = [UIColor.yellow.cgColor,
                                 UIColor.red.cgColor]
        gradientLayer2.locations = [0.1,0.8]
        
        let gradientLayer = CALayer()
        gradientLayer.addSublayer(gradientLayer1)
        gradientLayer.addSublayer(gradientLayer2)
        self.layer.addSublayer(gradientLayer)
        
        //Set the mask of the gradient layer to the progress bar
        gradientLayer.mask = meterLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPercent(riskPonit:Double, ifBoating:Bool, animated:Bool = true) {
        
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut))
        var percentDouble: Double
        
        if ifBoating {
            if riskPonit <= 9 {
                 percentDouble = 0.25
            } else if riskPonit <= 12 {
                percentDouble = 0.5
            } else {
                percentDouble = 0.75
            }
        } else {
            if riskPonit < 6 {
                percentDouble = 0.25
            } else if riskPonit < 9 {
                percentDouble = 0.5
            } else {
                percentDouble = 0.75
            }
        }
        
        
        let percent = CGFloat(percentDouble)
        meterLayer.strokeEnd = percent
        CATransaction.commit()
        
        if ifBoating {
            if riskPonit <= 9 {
                self.meterText.text = NSLocalizedString("compare_meter_label_low", comment: "compare_meter_label_low")
            } else if riskPonit <= 12 {
                self.meterText.text = NSLocalizedString("compare_meter_label_mid", comment: "compare_meter_label_mid")
            } else {
                self.meterText.text = NSLocalizedString("compare_meter_label_low", comment: "compare_meter_label_high")
            }
        } else {
            if riskPonit < 6 {
                self.meterText.text = NSLocalizedString("compare_meter_label_low", comment: "compare_meter_label_low")
            } else if riskPonit < 9 {
                self.meterText.text = NSLocalizedString("compare_meter_label_mid", comment: "compare_meter_label_mid")
            } else {
                self.meterText.text = NSLocalizedString("compare_meter_label_low", comment: "compare_meter_label_high")
            }
        }
        
        
    }
    
    //transfer angel to radians
    func toRadians(degrees:CGFloat) -> CGFloat {
        return .pi*(degrees)/180.0
    }

}
