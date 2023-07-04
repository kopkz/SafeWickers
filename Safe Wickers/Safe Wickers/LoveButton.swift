//
//  LoveButton.swift
//  Safe Wickers
//
//  Created by 匡正 on 27/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//
import UIKit

class LoveButton: UIButton {
    
    var isLove: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
//        if isLove{
//            setImage(UIImage(named: "icons8-like-96"), for: .normal)
//        } else {
//            setImage(UIImage(named: "icons8-unlike-96"), for: .normal)
//        }
        setImage(UIImage(named: "icons8-unlike-96"), for: .normal)
        self.tintColor = UIColor.white
        addTarget(self, action: #selector(LoveButton.buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        activateButton(bool: !isLove)
    }
    
    func unpdateImage() {
        let colour = isLove ? UIColor.red : .white
        let image = isLove ? UIImage(named: "icons8-like-96-2") : UIImage(named: "icons8-unlike-96")
        setImage(image, for: .normal)
        self.tintColor = colour
    }
    
    func activateButton(bool: Bool) {
        
        isLove = bool
        let colour = bool ? UIColor.red : .white
        let image = bool ? UIImage(named: "icons8-like-96-2") : UIImage(named: "icons8-unlike-96")
        setImage(image, for: .normal)
        self.tintColor = colour
    }
    
    
}

