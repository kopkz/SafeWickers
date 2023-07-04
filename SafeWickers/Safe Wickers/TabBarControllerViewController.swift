//
//  TabBarControllerViewController.swift
//  Safe Wickers
//
//  Created by 郑维天 on 15/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class TabBarControllerViewController: UITabBarController {
    private let currentLang = AppSettings.shared.language

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        
        let languageCode = defaults.object(forKey: "appLanguage") as? String ?? "en"
        switch languageCode {
//        case "":
//            return
        case "en":
            AppSettings.shared.language = .English
        case "zh-Hans":
            AppSettings.shared.language = .Chinese
        case "hi" :
            AppSettings.shared.language = .Hindi
        default:
            AppSettings.shared.language = .English
        }
        
        if (currentLang != AppSettings.shared.language) {
            resetRootViewController()
        }
        

        self.children[0].title = NSLocalizedString("tabBar_find", comment: "tabBar_find")
        self.children[1].title = NSLocalizedString("tabBar_favourite", comment: "tabBar_favourite")
       self.children[2].title = NSLocalizedString("tabBar_compare", comment: "tabBar_compare")
        self.children[3].title = NSLocalizedString("tabBar_sign", comment: "tabBar_sign")
        self.children[4].title = NSLocalizedString("tabBar_setting", comment: "tabBar_setting")
    }
    
    
    
    func resetRootViewController() {
        if let appdelegate = UIApplication.shared.delegate {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            if let mainController = storyBoard.instantiateViewController(withIdentifier: "rootViewController") as? UITabBarController{
                appdelegate.window??.rootViewController = mainController
                
            }
        }
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
