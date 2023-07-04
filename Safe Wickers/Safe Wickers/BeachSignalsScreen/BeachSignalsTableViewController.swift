//
//  BeachSignalsTableViewController.swift
//  Safe Wickers
//
//  Created by 匡正 on 8/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import SDWebImage
import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

class BeachSignalsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate {
    @IBOutlet weak var SelectLanguage: UIBarButtonItem!
    
    
    var pickerView = UIPickerView()
    var pickValue = String()
    var pickChoices : [Any] = []
    
    var flags: [BeachFlag] = []
    var transFlags: [BeachFlag] = []
    var currentLanguage = "English"
    
    let SECTION_LANGUAGE = 0
    let SECTION_FLAG = 1
    let CELL_LANGUAGE = "languageCell"
    let CELL_FLAG = "flagCell"

    
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
        loadBeachSignal()
        addNavBarImage()
        transFlags = flags
        
        
        self.tableView.separatorStyle = .singleLine
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        SelectLanguage.title = NSLocalizedString("Sig_SelectLanguage", comment: "Sig_SelectLanguage")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == SECTION_LANGUAGE {
            return 1
        }
        return transFlags.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_LANGUAGE{
            let languageCell = tableView.dequeueReusableCell(withIdentifier: CELL_LANGUAGE, for: indexPath)
            languageCell.textLabel?.text = NSLocalizedString("sign_cur_language", comment: "sign_cur_language") + "\(currentLanguage)"
            return languageCell
        }
        
        let flagCell = tableView.dequeueReusableCell(withIdentifier: CELL_FLAG, for: indexPath) as! FlagTableViewCell

        let flag = transFlags[indexPath.row]
        flagCell.flagNameLabel.text = flag.flagName
        flagCell.meaningLabel.text = flag.meaning
        
        let url = URL(string: flag.imageName!)
        flagCell.flagImageView.sd_setImage(with: url, completed: nil)

        return flagCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SECTION_LANGUAGE{
            return 45
        }
        return 115
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let flag = transFlags[indexPath.row]
        let alertController = UIAlertController(title: flag.flagName, message: flag.des, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func selectLanguage(_ sender: Any) {
        pickChoices = ["English", "简体中文", "日本語", "한국어", "Français", "Español", "ภาษาไทย", "العربية", "русский язык", "Português", "Deutsch", "Italiano", "Ελληνικά", "Nederlands", "Polski", "български", "Eesti", "Dansk", "Suomi", "Česko", "Română", "SlovenskoName", "Svenska", "MagyarName", "ViệtName", "繁體中文"]
        
        let alert = UIAlertController(title: NSLocalizedString("signal Select Language", comment: "signal Select Language"), message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 180))
        alert.view.addSubview(pickerFrame)
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        alert.addAction(UIAlertAction(title: NSLocalizedString("sign_Cancel", comment: "sign_Cancel"), style: .cancel, handler: { (UIAlertAction) in
            self.removeSpinner()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("sign_OK", comment: "sign_OK"), style: .default, handler: { (UIAlertAction) in

            self.translation(language: self.pickValue)
            }))
        
        self.present(alert,animated: true, completion: nil )
        self.showSpinner()
        self.pickValue = ""
    }
    
    // translate beach signal info
    func translation(language: String){
        
        self.currentLanguage = language
        if language.isEmpty{
            self.currentLanguage = "English"
            self.transFlags = self.flags
            self.tableView.reloadData()
            self.removeSpinner()
            return
        }
        if language == "English" && language.isEmpty{
            self.transFlags = self.flags
            self.tableView.reloadData()
            self.removeSpinner()
            return
        }
        let lanCode = self.getLanguageCode(language: language)
        transFlags = []
        for flag in flags {
            let transName = translationAPI(langCode: lanCode, text: flag.flagName!)
            let transMeaning = translationAPI(langCode: lanCode, text: flag.meaning!)
            let transDes = translationAPI(langCode: lanCode, text: flag.des!)
            let transFlag = BeachFlag(flagName: transName, meaning: transMeaning, des: transDes, imageName: flag.imageName!)
            transFlags.append(transFlag)
        }
        self.tableView.reloadData()
        self.removeSpinner()
    }
    
    // connect translation API
    
    func translationAPI(langCode: String, text: String) -> String{
        let appid = "20200508000444081"
        let securityKey = "_Lu4vA1C8Tazl69Akbix"
        
        let salt = randomString()
        let src = appid + text + salt + securityKey
        let sign =  MD5(string: src)
        var resultString: String?
        
        let searchString = "http://api.fanyi.baidu.com/api/trans/vip/translate?q=\(text)&from=en&to=\(langCode)&appid=20200508000444081&salt=\(salt)&sign=\(sign)"
        let jsonURL = URL(string: searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        guard let urlData = NSData(contentsOf: jsonURL!) else{ print("error")
            return ""}
        
        do{
            let decoder = JSONDecoder()
            let transDate = try decoder.decode(TransData.self, from: urlData as Data)
            var transResult: [TransResult]?
            transResult = transDate.transResults
            resultString = transResult![0].result
        }catch {
            print("error")
        }
        return resultString ?? "error"
    }
    
    
    //set up picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (pickChoices[row] as! String)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickValue = pickChoices[row] as! String
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MD5 hash and random salt for creating sign of translation API
    func MD5(string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        let md5String = digestData.map { String(format: "%02hhx", $0) }.joined()
        return md5String
    }
    // random salt
    func randomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<10).map{ _ in letters.randomElement()! })
    }
    
    
    //load all beach signal form loacl file
    fileprivate func loadBeachSignal()  {
        if let path = Bundle.main.path(forResource: "flags", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .dataReadingMapped)
                let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [[String:String]]
                
                for object in jsonResult {
                    let flagName = object["name"]!
                    let meaning = object["meaning"]!
                    let des = object["description"]!
                    let imageName = object["image"]!
                    let beachFlag = BeachFlag(flagName: flagName, meaning: meaning, des: des, imageName: imageName)
                    self.flags.append(beachFlag)
                }
                
//                return countryNames
            } catch {
                print("Error parsing jSON: \(error)")
//                return []
            }
        }
    }
    
    //get language code
    func getLanguageCode(language: String) -> String{
        switch language {
        case "简体中文":
            return "zh"
        case "日本語":
            return "jp"
        case "한국어":
            return "kor"
        case "Français":
            return "fra"
        case "Español":
            return "spa"
        case "ภาษาไทย":
            return "th"
        case "العربية":
            return "ara"
        case "русский язык":
            return "ru"
        case "Português":
            return "pt"
        case "Deutsch":
            return "de"
        case "Italiano":
            return "it"
        case "Ελληνικά":
            return "el"
        case "Nederlands":
            return "nl"
        case "Polski":
            return "pl"
        case "български":
            return "bul"
        case "Eesti":
            return "est"
        case "Dansk":
            return "dan"
        case "Suomi":
            return "fin"
        case "Česko":
            return "cs"
        case "Română":
            return "rom"
        case "SlovenskoName":
            return "slo"
        case "Svenska":
            return "swe"
        case "MagyarName":
            return "hu"
        case "ViệtName":
            return "vie"
        case "繁體中文":
            return "cht"
        default:
            return "en"
        }
    }
}

fileprivate var indiView: UIView?
extension BeachSignalsTableViewController {
    func showSpinner(){
        indiView = UIView(frame: self.tableView.bounds)
        indiView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.center = indiView!.center
        //add text to indicator
        let indicatorLabel = UILabel()
        indicatorLabel.frame = CGRect(x: indiView!.bounds.width/8, y: indiView!.bounds.height/70, width: 100, height: 30)
        indicatorLabel.text = NSLocalizedString("Translating...", comment: "Translating...")
        indicatorLabel.textColor = UIColor.white
        indicatorLabel.font = UIFont(name: "Avenir Light", size: 20)
        indicatorLabel.sizeToFit()
        indicator.addSubview(indicatorLabel)
        indicator.startAnimating()
        indiView?.addSubview(indicator)
        self.view.addSubview(indiView!)
    }
    
    func removeSpinner(){
        indiView?.removeFromSuperview()
        indiView = nil
    }
}
