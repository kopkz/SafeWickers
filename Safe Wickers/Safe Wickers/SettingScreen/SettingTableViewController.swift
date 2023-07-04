//
//  SettingTableViewController.swift
//  Safe Wickers
//
//  Created by 匡正 on 15/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let SECTION_SETTING = 0
    let SECTION_HELP = 1
    
    let CELL_SETTING = "systemSettingCell"
    let CELL_HELP = "helpCell"
    
    var pickerView = UIPickerView()
    var pickValue = String()
    var pickChoices : [String] = []
    var index = IndexPath()
    
    private let currentLang = AppSettings.shared.language
    
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
        addNavBarImage()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        if (currentLang != AppSettings.shared.language) {
//            resetRootViewController()
//        }
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_SETTING {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SETTING, for: indexPath) as! SettingTableViewCell
            cell.iconImage.image = UIImage(named: "language")
            cell.settingItemLabel.text = NSLocalizedString("SettingLanguage", comment: "SettingLanguage")
            switch AppSettings.shared.language {
            case .Chinese:
                cell.settingValueLabel.text = "简体中文"
            case .English:
                cell.settingValueLabel.text = "English"
            case .Hindi:
                cell.settingValueLabel.text = "हिन्दी"
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_HELP, for: indexPath) as! HelpTableViewCell
        
        cell.helpItemLabel.text = NSLocalizedString("About us", comment: "About us")
        cell.iconImage.image = UIImage(named: "help")
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_SETTING{
            return NSLocalizedString("System Setting", comment: "System Setting")
        }
        return NSLocalizedString("Help and Information", comment: "Help and Information")
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SECTION_SETTING {
            return 40
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_SETTING {
            self.pickChoices = ["English", "简体中文", "हिन्दी"]
            let alert = UIAlertController(title: NSLocalizedString("Setting_Select_Language", comment: "Setting_Select_Language"), message: "\n\n\n\n\n\n", preferredStyle: .alert)
            alert.isModalInPopover = true
            let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
            alert.view.addSubview(pickerFrame)
            pickerFrame.dataSource = self
            pickerFrame.delegate = self
            alert.addAction(UIAlertAction(title: NSLocalizedString("Setting_warn_Cancel", comment: "Setting_warn_Cancel"), style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Setting_warn_OK", comment: "Setting_warn_OK"), style: .default, handler: { (UIAlertAction) in
                
                if let cell = self.tableView.cellForRow(at: indexPath) as? SettingTableViewCell {
                    
                    
//                    if self.pickValue != "" {
                        cell.settingValueLabel.text = self.pickValue
                        switch self.pickValue{
                        case "English":
                            AppSettings.shared.language = .English
                        case "简体中文":
                            AppSettings.shared.language = .Chinese
                        case "हिन्दी":
                            AppSettings.shared.language = .Hindi
                        default:
                            AppSettings.shared.language = .English
                        }
//                        }
                    let defaults = UserDefaults.standard
                    defaults.set(AppSettings.shared.language.code, forKey: "appLanguage")
                    self.tableView.reloadData()
                    self.title = NSLocalizedString("tabBar_setting", comment: "tabBar_setting")
                    
                    self.tabBarController?.tabBar.items![0].title = NSLocalizedString("tabBar_find", comment: "tabBar_find")
                    self.tabBarController?.tabBar.items![1].title = NSLocalizedString("tabBar_favourite", comment: "tabBar_favourite")
                    self.tabBarController?.tabBar.items![2].title = NSLocalizedString("tabBar_compare", comment: "tabBar_compare")
                    self.tabBarController?.tabBar.items![3].title = NSLocalizedString("tabBar_sign", comment: "tabBar_sign")
                    if (self.currentLang != AppSettings.shared.language) {
                        self.resetRootViewController()
                    }
                    self.pickValue = ""
                    
                    }}))
            
            
            self.present(alert,animated: true, completion: nil )
        } else {
            performSegue(withIdentifier: "showAboutUs", sender: self)
        }
        
        
        
    }
    
    
    func resetRootViewController() {
        if let appdelegate = UIApplication.shared.delegate {
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            if let mainController = storyBoard.instantiateViewController(withIdentifier: "rootViewController") as? UITabBarController{
                appdelegate.window??.rootViewController = mainController
                
            }
            
        }
        self.tabBarController?.selectedIndex = 4
    }
    
//    func resetCurrentViewController() {
//        if let appdelegate = UIApplication.shared.delegate {
//            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
//            if let currentController = storyBoard.instantiateViewController(withIdentifier: "settingVC") as? UITableViewController{
//                appdelegate.window??.rootViewController = currentController
//
//            }
//        }
//    }
    
    
    //set up picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (pickChoices[row] )
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickValue = pickChoices[row]
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showAboutUs" {
            _ = segue.destination as! AboutUsViewController
        }
    }
    

}
