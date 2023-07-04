//
//  BeachDetailViewController.swift
//  Safe Wickers
//
//  Created by 匡正 on 22/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import SDWebImage
import Cosmos
import Alamofire
import MapKit


class BeachDetailViewController: UIViewController {
    
    @IBOutlet weak var cosmosView: CosmosView!
    
    @IBOutlet weak var lifeGuardLab: UILabel!
    @IBOutlet weak var PortLabel: UILabel!
 
    @IBOutlet weak var beachdetail_Ratingbutton: UIButton!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var contentViewHC: NSLayoutConstraint!
    @IBOutlet weak var beachImageView: UIImageView!
    @IBOutlet weak var beachNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ifPortImageView: UIImageView!
    @IBOutlet weak var ifGuardImageView: UIImageView!
    @IBOutlet weak var windSpeedValue: UILabel!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    @IBOutlet weak var tempValue: UILabel!
    
    @IBOutlet weak var humLabel: UILabel!
    
    @IBOutlet weak var humValue: UILabel!
    
    @IBOutlet weak var preLabel: UILabel!
    var beach: Beach?
    @IBOutlet weak var preValue: UILabel!
    
    @IBOutlet weak var uvLabel: UILabel!
    
    @IBOutlet weak var uvValueLabel: UILabel!
    
    @IBOutlet weak var tideStateLabel: UILabel!
    @IBOutlet weak var tideStateValueLabel: UILabel!
    @IBOutlet weak var tideHeightLabel: UILabel!
    @IBOutlet weak var tideHeightValueLabel: UILabel!
    
    @IBOutlet weak var loveUnloveButton: LoveButton!
    //database listener
    var listenerType = ListenerType.lovedBeach
    
    weak var databaseController: DatabaseProtocol?
    var lovedBeachs: [LovedBeach] = []
    
    
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
        navController.navigationBar.backItem?.title = "Back"
    }
    
    override func viewDidLoad() {
        setuptranslation_beachDetail()
        super.viewDidLoad()
        //set up scroll view
//        self.contentViewHC.constant = UIScreen.main.bounds.size.height
        self.contentViewHC.constant = 450

        //set up navigation bar
        addNavBarImage()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        beachNameLabel.text = beach?.beachName
        distanceLabel.text = "\((beach?.distance!)!/1000) km"
        windSpeedValue.text = "\(beach!.windSpeed!) m/s"
        if beach!.ifGuard! {
            ifGuardImageView.image = UIImage(named: "yes")
        }else{
            ifGuardImageView.image = UIImage(named: "no")
        }
        if beach!.ifPort! {
            ifPortImageView.image = UIImage(named: "yes")
        }else{
            ifPortImageView.image = UIImage(named: "no")
        }
        
        //TODO load real image
        //beachImageView.image = UIImage(named: beach!.imageName!)
        let url = URL(string: (beach?.imageName!)!)
        
       beachImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultBeachImage.jpg"), completed: nil)
        let tempC = beach!.temp! - 273.15
        tempValue.text = "\(tempC.rounded()) ℃"
        humValue.text = "\(beach!.hum!) %"
        preValue.text = "\(beach!.pre!) hpa"
        uvValueLabel.text = "\(beach!.uv!.rounded())"
        tideHeightValueLabel.text = "\(beach!.tideHeight!) m"
        tideStateValueLabel.text = beach?.tideState
        // Do any additional setup after loading the view.
        
        //TODO get rating from database or beach object passed from previous class
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
        cosmosView.rating = 0
        getRating(beachName: beach!.beachName!)
        
        
        loveUnloveButton.isLove = beach!.ifLoved!
        loveUnloveButton.unpdateImage()
        loveUnloveButton.addTarget(self, action: #selector(loveUloveBeach), for: .touchUpInside)
        setuptranslation_beachDetail()
    }
    
    
    @IBAction func giveRatingButton(_ sender: Any) {
        
        
        let alert = UIAlertController(title: NSLocalizedString("Detail_Ratting_message", comment: "Detail_Ratting_message"), message: "\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        let ratingCosmosView = CosmosView(frame: CGRect(x: 75, y: 70, width: 250, height: 100))
        ratingCosmosView.settings.fillMode = .full
        alert.view.addSubview(ratingCosmosView)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Detail_Ratting_Cancel", comment: "Detail_Ratting_Cancel"), style: .cancel, handler: { (UIAlertAction) in
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Detail_Ratting_OK", comment: "Detail_Ratting_OK"), style: .default, handler: { (UIAlertAction) in
            self.giveRating(beachName: self.beach!.beachName!, ratingLevel: Int(ratingCosmosView.rating))
            self.getRating(beachName: self.beach!.beachName!)
        }))
        
        self.present(alert,animated: true, completion: nil )
    }
    
    //post a rating to database
    func giveRating(beachName: String, ratingLevel: Int){
        //Defined a constant that holds the URL for our web service "http://safewickers.000webhostapp.com/v1/giveRating.php"
        let URL_GIVE_RATING = "http://safewickers.000webhostapp.com/v1/giveRating.php"
//        "http://172.20.10.3/safe_wickers/v1/giveRating.php"
        //creating parameters for the get request
        let parameters : Parameters = ["beach_name" : beachName, "rating_level" : ratingLevel]
        //Sending http get request
        Alamofire.request(URL_GIVE_RATING, method: .post, parameters: parameters).responseJSON { response in
            //getting the json value from the server
            if let result = response.result.value {
                //converting it as NSDictionary
                let jsonData = result as! NSDictionary
                //displaying the message in alet
                let responseAlert = UIAlertController(title: jsonData.value(forKey: "message") as! String?, message: nil, preferredStyle: .alert)
                self.present(responseAlert, animated: true, completion: nil)
                // miss after 1 second
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
            } else {
                let responseAlert = UIAlertController(title: NSLocalizedString("detail_Error_title", comment: "detail_Error_title"), message: NSLocalizedString("detail_Error_meassage", comment: "detail_Error_meassage"), preferredStyle: .alert)
                self.present(responseAlert, animated: true, completion: nil)
                // miss after 2 second
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
            }
            
        }
    }
    
    
    
    // get rating data from mysql database
    func getRating(beachName: String){
        var avRating = 0.0
        //Defined a constant that holds the URL for our web service
        //
        let URL_GET_RATING = "http://safewickers.000webhostapp.com/v1/getRating.php"
//        "http://172.20.10.3/safe_wickers/v1/getRating.php"
        //creating parameters for the get request
        let parameters : Parameters = ["beach_name" : beachName]
        //Sending http get request
        Alamofire.request(URL_GET_RATING, method: .get, parameters: parameters).responseJSON { response in
            do {
                var ratingStrings: [String] = []
                let data = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [[String:String]]
                for obj in data{
                    ratingStrings.append(obj["rating_level"]!)
                }
                
                for ratingString in ratingStrings{
                    let rating = Int(ratingString)
                    avRating = avRating + Double(rating!)
                }
                
                avRating = avRating/Double(ratingStrings.count)
                if !(avRating > 0){
                    avRating = 0
                }
                DispatchQueue.main.async {
                    self.cosmosView.rating = avRating
                }
                //                print(self.tttt)
            } catch{}
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailToMapSeque" {
            let destination = segue.destination as! MapViewController
            destination.focusLocation = CLLocation(latitude: self.beach!.latitude!, longitude: self.beach!.longitude!)
            let list: [Beach] = [self.beach!]
            destination.beachList = list
        }
    }
    
    
    //love or unlove beach
    
    @objc func loveUloveBeach(){
        if self.beach!.ifLoved!{
            cancelLovedBeach(beachName: self.beach!.beachName!)
        } else{
            addLovedBeach(beach: self.beach!)
        }
    }
    
    func checkIfLoved(beachNmae: String) -> Bool{
        var ifLoved = false
        for beach in lovedBeachs {
            if beach.beachName == beachNmae{
                ifLoved = true
            }
        }
        return ifLoved
    }
    
    // add beach to loved beach database
    func addLovedBeach(beach:Beach) {
        
        let ifLoved = checkIfLoved(beachNmae: beach.beachName!)
        if ifLoved {
            return
        }
        let _ = databaseController!.addLovedBeach(beachName: beach.beachName!, lat: beach.latitude!, long: beach.longitude!, imageName: beach.imageName!, ifGuard: beach.ifGuard!, ifPort: beach.ifPort!)
        self.beach!.ifLoved = true
        
        let responseAlert = UIAlertController(title: NSLocalizedString("detail_love_title", comment: "detail_love_title"), message:nil, preferredStyle: .alert)
        self.present(responseAlert, animated: true, completion: nil)
        // miss after 2 second
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    // remove beach from loved beach database
    func cancelLovedBeach(beachName: String) {
        var unlovedBeach: LovedBeach?
        for beach in lovedBeachs {
            if beach.beachName == beachName{
                unlovedBeach = beach
            }
        }
        guard let unloved = unlovedBeach else {
            return
        }
        
        let _ = databaseController!.deleteLovedBeach(lovedBeach: unloved)
        self.beach!.ifLoved = false
        let responseAlert = UIAlertController(title: NSLocalizedString("detail_unlove_title", comment: "detail_unlove_title"), message:nil, preferredStyle: .alert)
        self.present(responseAlert, animated: true, completion: nil)
        // miss after 2 second
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
}

extension BeachDetailViewController: DatabaseListener{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onLovedBeachChange(change: DatabaseChange, lovedBeachs: [LovedBeach]) {
        self.lovedBeachs = lovedBeachs
    }
    func setuptranslation_beachDetail()
    {
        //beachNameLabel.text = NSLocalizedString("BeachDetail_beachNameLabel", comment: "BeachDetail_beachNameLabel")
//        distanceLabel.text = NSLocalizedString("BeachDetail_distanceLabel", comment: "BeachDetail_distanceLabel")
        windSpeedLabel.text = NSLocalizedString("BeachDetail_windSpeedLabel", comment: "BeachDetail_windSpeedLabel")
        lifeGuardLab.text = NSLocalizedString("BeachDetail_lifeGuardLabel", comment: "BeachDetail_lifeGuardLabel")
        PortLabel.text = NSLocalizedString("BeachDetail_PortLabel", comment: "BeachDetail_PortLabel")
    beachdetail_Ratingbutton.setTitle(NSLocalizedString("beachDetail_rattingButton", comment: "beachDetail_rattingButton"), for: .normal)
        tempLabel.text = NSLocalizedString("BeachDetail_tempLabel", comment: "BeachDetail_tempLabel")
        tideStateLabel.text = NSLocalizedString("BeachDetail_tideStateLabel" , comment: "BeachDetail_tideStateLabel" )
        tideHeightLabel.text = NSLocalizedString("BeachDetail_tideHeightLabel", comment: "BeachDetail_tideHeightLabel")
        humLabel.text = NSLocalizedString("BeachDetail_humLabel", comment: "BeachDetail_humLabel")
        preLabel.text = NSLocalizedString("BeachDetail_preLabel", comment: "BeachDetail_preLabel")
        uvLabel.text = NSLocalizedString("BeachDetail_uvLabel" , comment: "BeachDetail_uvLabel" )
    }
    
}
