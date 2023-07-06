//
//  AboutUsViewController.swift
//  Safe Wickers
//
//  Created by 匡正 on 16/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var aboutUsLabel: UILabel!
    
    
    // add logo image to navigationbar
    func addNavBarImage() {
        let navController = navigationController!
        navigationController?.navigationBar.barTintColor = UIColor(red:0.27, green:0.45, blue:0.58, alpha:1)
        let image = UIImage(named: "titleLogo.png")
        let imageView = UIImageView(image: image)
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        addNavBarImage()
        
        // Do any additional setup after loading the view.
        self.aboutUsLabel.text = NSLocalizedString("Set_About_Us", comment: "Set_About_Us")
        self.infoLabel.text = NSLocalizedString("Aboutus_Message", comment: "Aboutus_Message")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
