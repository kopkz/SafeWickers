//
//  CompareViewController.swift
//  Safe Wickers
//
//  Created by 匡正 on 7/5/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Cosmos
import MapKit

class CompareViewController: UIViewController, DatabaseListener, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {

   
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var beach_2_portLabel: UILabel!
    @IBOutlet weak var beach_2_lifeguardLabel: UILabel!
    @IBOutlet weak var beach_1_portLabel: UILabel!
    @IBOutlet weak var beach_1_lifguardLabel: UILabel!
    @IBOutlet weak var selectBeachLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var riskLabel: UILabel!
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var tideLabel: UILabel!
    
    @IBOutlet weak var uvLabel: UILabel!
    @IBOutlet weak var lifeguardLabel: UILabel!
    
    @IBOutlet weak var portLabel: UILabel!
    
    @IBOutlet weak var beach_1_textField: UITextField!
    
    @IBOutlet weak var beach_2_textField: UITextField!
    
    @IBOutlet weak var beach_1_cosmosView: CosmosView!
    
    @IBOutlet weak var beach_2_cosmosView: CosmosView!
    
//    @IBOutlet weak var beach_1_riskSlider: CustomSlider!
//    
//    @IBOutlet weak var beach_2_riskSlider: CustomSlider!
    
    @IBOutlet weak var beach_1_windSlider: CustomSlider!
    
    @IBOutlet weak var beach_2_windSlider: CustomSlider!
    
    @IBOutlet weak var beach_1_windValue: UILabel!
    
    @IBOutlet weak var beach_2_windValue: UILabel!
    
    
    @IBOutlet weak var beach_1_tideSlider: CustomSlider!
    
    @IBOutlet weak var beach_1_tideValue: UILabel!
    @IBOutlet weak var beach_2_tiderSlider: CustomSlider!
    @IBOutlet weak var beach_2_tiderValue: UILabel!
    
    @IBOutlet weak var beach_1_uvSlider: CustomSlider!
    
    @IBOutlet weak var beach_1_uvValue: UILabel!
    
    @IBOutlet weak var beach_2_uvSlider: CustomSlider!
    
    @IBOutlet weak var beach_2_uvValue: UILabel!
    
    @IBOutlet weak var beach_2_lifeguardImage: UIImageView!
    
    @IBOutlet weak var beach_2_portImage: UIImageView!
    
    
    @IBOutlet weak var beach_1_lifeguardImage: UIImageView!
    
    
    @IBOutlet weak var beach_1_portImage: UIImageView!
    @IBOutlet weak var activtySegment: UISegmentedControl!
    
    
    @IBOutlet weak var beach_1_detiallButton: UIButton!
    
    @IBOutlet weak var beach_2_detailButton: UIButton!
    
    
    
    @IBOutlet weak var contentViewHC: NSLayoutConstraint!
    
    var beach_1_meter: RiskMeter!
    var beach_2_meter: RiskMeter!
    
    var pickerView = UIPickerView()
    var pickValue: LovedBeach?
    var pickChoices : [Any] = []
    
    let BEACH_1 = 0
    let BEACH_2 = 1
    
    var ratings: [String:Double] = [:]
    
    var databaseController: DatabaseProtocol?
    var lovedBeachs:[LovedBeach] = []
    var comparedBeach: Beach?
    var listenerType = ListenerType.lovedBeach
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
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
        super.viewDidLoad()
        settranslate_Compare()
        addNavBarImage()
        self.activtySegment.tintColor = UIColor(red:0.27, green:0.45, blue:0.58, alpha:1)
        self.activtySegment.setTitle(NSLocalizedString("seg_swimming", comment: "seg_swimming"), forSegmentAt: 0)
        self.activtySegment.setTitle(NSLocalizedString("seg_surfing", comment: "seg_surfing"), forSegmentAt: 1)
        self.activtySegment.setTitle(NSLocalizedString("seg_boating", comment: "seg_boating"), forSegmentAt: 2)
        self.contentViewHC.constant = 400
        
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyKilometer
        locationManager.delegate = self
        
        //make rating non adjustable
        beach_1_cosmosView.settings.updateOnTouch = false
        beach_2_cosmosView.settings.updateOnTouch = false
        
        //add action to beach text field
        beach_1_textField.addTarget(self, action: #selector(showBeach1Picker), for: .allTouchEvents)
        beach_2_textField.addTarget(self, action: #selector(showBeach2Picker), for: .allTouchEvents)
        loadDefualtValue()
        
        activtySegment.addTarget(self, action: #selector(self.SegmentedChanged(_:)), for: .valueChanged)
        beach_2_detailButton.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        beach_1_detiallButton.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        
        //add risk meter
        beach_1_meter = RiskMeter(frame: CGRect(x: 20, y: 150, width: 80, height: 80))
        beach_1_meter.translatesAutoresizingMaskIntoConstraints = false
        beach_2_meter = RiskMeter(frame: CGRect(x: 20, y: 150, width: 80, height: 80))
        beach_2_meter.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(beach_1_meter)
        self.contentView.addSubview(beach_2_meter)
        
//        self.view.addSubview(beach_1_meter)
//        self.view.addSubview(beach_2_meter)
        
        let sc1 = NSLayoutConstraint(item: beach_1_meter, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 30)
        let sc2 = NSLayoutConstraint(item: beach_1_meter, attribute: .top, relatedBy: .equal, toItem: beach_1_cosmosView, attribute: .bottom, multiplier: 1, constant: 10)
        let sc4 = NSLayoutConstraint(item: beach_2_meter, attribute: .left, relatedBy: .equal, toItem: self.beach_2_windSlider, attribute: .left, multiplier: 1, constant: 20)
        let sc5 = NSLayoutConstraint(item: beach_2_meter, attribute: .top, relatedBy: .equal, toItem: beach_2_cosmosView, attribute: .bottom, multiplier: 1, constant: 10)
        NSLayoutConstraint.activate([sc1, sc2, sc4, sc5])

        
    }
    @objc func buttonDidTap(sender: UIButton) {
        if sender == beach_2_detailButton {
            createBeach(beachNo: BEACH_2)
        }
        if sender == beach_1_detiallButton {
            createBeach(beachNo: BEACH_1)
        }
        
    }
    //create beach data for passing to detail page
    func createBeach(beachNo: Int) {
        let beachName = (beachNo == BEACH_1) ? beach_1_textField.text : beach_2_textField.text
        if beachName!.isEmpty {return}
        
        let loveBeach = lovedBeachs.filter({$0.beachName == beachName}).first
        let lat = loveBeach?.lat
        let long = loveBeach?.long
        let image = loveBeach?.imageNmae
        let ifPort = loveBeach?.ifPort
        let ifGuard = loveBeach?.ifGuard
        let beachLocation = CLLocation(latitude:loveBeach!.lat, longitude: loveBeach!.long)
        let distance = currentLocation?.distance(from: beachLocation).rounded()
        
        let weatherData = getCurrentWeatherDate(beach: loveBeach!)
        let windSpeed = weatherData[0]
        let temp = weatherData[1]
        let hum = weatherData[2]
        let pre = weatherData[3]
        
        let uv = uvapi(lat: lat!, long: long!)
        
        let tides = tidesapi(lat: lat!, long: long!)
        let tideState = checkTideState(tides: tides)
        let tideHeight = getTideHeight(tides: tides)
        
        self.comparedBeach = Beach(beachName: beachName!, latitude: lat!, longitude: long!, imageName: image!, distance: distance ?? 0.0, risk: "s", ifGuard: ifGuard!, ifPort: ifPort!, descrip: "", windSpeed: windSpeed, temp: temp, hum: hum, pre: pre, ifLoved: true, uv: uv, tideState: tideState, tideHeight: tideHeight)
        
        performSegue(withIdentifier: "compareToBeachDetail", sender: self)
        
    }
    
   @objc func SegmentedChanged(_ segmented:UISegmentedControl) {
        if !beach_1_textField.text!.isEmpty {
            let beach = lovedBeachs.filter({$0.beachName == beach_1_textField.text}).first
            loadData(beachNo: BEACH_1, beach: beach!)
        }
        if !beach_2_textField.text!.isEmpty {
            let beach = lovedBeachs.filter({$0.beachName == beach_1_textField.text}).first
            loadData(beachNo: BEACH_2, beach: beach!)
        }
        
    }
    
    func loadDefualtValue(){
        beach_1_uvSlider.value = 0
        beach_1_uvValue.text = "N/A"
        beach_1_tideSlider.value = 0
        beach_1_tideValue.text = "N/A"
        //beach_1_portImage.image = nil
        beach_1_windValue.text = "N/A"
        beach_1_cosmosView.rating = 0
        //beach_1_riskSlider.value = 0
        beach_1_windSlider.value = 0
        //beach_1_lifeguardImage.image = nil
        beach_1_lifguardLabel.text = NSLocalizedString("compare_NoAvailable_label", comment: "compare_NoAvailable_label")
        beach_1_portLabel.text = NSLocalizedString("compare_NoAvailable_label", comment: "compare_NoAvailable_label")
        
        beach_2_uvSlider.value = 0
        beach_2_uvValue.text = "N/A"
        beach_2_tiderSlider.value = 0
        beach_2_tiderValue.text = "N/A"
        //beach_2_portImage.image = nil
        beach_2_windValue.text = "N/A"
        beach_2_cosmosView.rating = 0
        //beach_2_riskSlider.value = 0
        beach_2_windSlider.value = 0
        //beach_2_lifeguardImage.image = nil
        beach_2_lifeguardLabel.text = NSLocalizedString("compare_NoAvailable_label", comment: "compare_NoAvailable_label")
        beach_2_portLabel.text = NSLocalizedString("compare_NoAvailable_label", comment: "compare_NoAvailable_label")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    func onLovedBeachChange(change: DatabaseChange, lovedBeachs: [LovedBeach]) {
        self.lovedBeachs = lovedBeachs
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        currentLocation = location
    }
    
    @objc func showBeach1Picker() {
        if lovedBeachs.isEmpty {
            //displaying the message in alet
            let responseAlert = UIAlertController(title: NSLocalizedString("Compare_warn_empty", comment: "Compare_warn_empty"), message: NSLocalizedString("Compare_warn_empty_message", comment: "Compare_warn_empty_message"), preferredStyle: .alert)
            self.present(responseAlert, animated: true, completion: nil)
            // miss after 1 second
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        }
        pickChoices = lovedBeachs
        let alert = UIAlertController(title: NSLocalizedString("Compare_select1beach", comment: "Compare_select1beach"), message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        alert.view.addSubview(pickerFrame)
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        alert.addAction(UIAlertAction(title: NSLocalizedString("Compare_warn_Cancel" , comment: "Compare_warn_Cancel" ), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Compare_warn_OK", comment: "Compare_warn_OK"), style: .default, handler: { (UIAlertAction) in
            if self.pickValue == nil {
                self.pickValue = self.pickChoices.first as? LovedBeach
            }
            self.beach_1_textField.text = self.pickValue!.beachName
            self.loadData(beachNo: self.BEACH_1, beach: self.pickValue!)
            self.pickValue = nil
        }))
        
        self.present(alert,animated: true, completion: nil )
    }
 
    @objc func showBeach2Picker() {
        if lovedBeachs.isEmpty {
            //displaying the message in alet
            let responseAlert = UIAlertController(title: NSLocalizedString("Compare_warn_empty", comment: "Compare_warn_empty"), message: NSLocalizedString("Compare_warn_empty_message", comment: "Compare_warn_empty_message"), preferredStyle: .alert)
            self.present(responseAlert, animated: true, completion: nil)
            // miss after 1 second
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        }
        pickChoices = lovedBeachs
        let alert = UIAlertController(title: NSLocalizedString("Compare_select2beach", comment: "Compare_select2beach"), message: "\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        alert.view.addSubview(pickerFrame)
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        alert.addAction(UIAlertAction(title: NSLocalizedString("Compare_warn_Cancel2", comment: "Compare_warn_Cancel2"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Compare_warn_OK2", comment: "Compare_warn_OK2"), style: .default, handler: { (UIAlertAction) in
            if self.pickValue == nil {
                self.pickValue = self.pickChoices.first as? LovedBeach
                
            }
            self.beach_2_textField.text = self.pickValue!.beachName
            self.loadData(beachNo: self.BEACH_2, beach: self.pickValue!)
            self.pickValue = nil
        }))
        
        self.present(alert,animated: true, completion: nil )
    }
    
    //set up picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let titile = (pickChoices[row] as! LovedBeach).beachName
        return titile
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickValue = pickChoices[row] as? LovedBeach
    }
    
    //load all compare data
    func loadData(beachNo: Int, beach:LovedBeach){
        
        //load port and guard
        if beachNo == BEACH_1 {
            self.beach_1_lifeguardImage.image = beach.ifGuard ? UIImage(named: "yse") : UIImage(named: "no")
            self.beach_1_lifguardLabel.text = beach.ifGuard ? NSLocalizedString("compare_Available_label", comment: "compare_Available_label") : NSLocalizedString("compare_NoAvailable_label", comment: "compare_NoAvailable_label")
            if beach.ifPort {
                self.beach_1_portImage.image = UIImage(named: "yes")
                self.beach_1_portLabel.text = NSLocalizedString("compare_Available_label", comment: "compare_Available_label")
            } else {
                self.beach_1_portImage.image = UIImage(named: "no")
                self.beach_1_portLabel.text = NSLocalizedString("compare_NoAvailable_label", comment: "compare_NoAvailable_label")
            }
        } else {
            self.beach_2_lifeguardImage.image = beach.ifGuard ? UIImage(named: "yse") : UIImage(named: "no")
            self.beach_2_lifeguardLabel.text = beach.ifGuard ? NSLocalizedString("compare_Available_label", comment: "compare_Available_label") : NSLocalizedString("compare_NoAvailable_label", comment: "compare_NoAvailable_label")
            if beach.ifPort {
                self.beach_2_portImage.image = UIImage(named: "yes")
                 self.beach_2_portLabel.text = NSLocalizedString("compare_Available_label", comment: "compare_Available_label")
            } else {
                self.beach_2_portImage.image = UIImage(named: "no")
                 self.beach_2_portLabel.text = NSLocalizedString("compare_NoAvailable_label", comment: "compare_NoAvailable_label")
            }
        }
        
        //load rating
        getRating(beachNo: beachNo, beachName: beach.beachName!)
        //load tide
        let tideData = tidesapi(lat: beach.lat, long: beach.long)
        let tideState = checkTideState(tides: tideData)
        var tideSliderValue: Float = 0
        switch tideState {
        case "SLACK TIDE":
            tideSliderValue = 1
        case "MID TIDE":
            tideSliderValue = 5
        case "LOW TIDE":
            tideSliderValue = 9
        case "HIGH TIDE":
            tideSliderValue = 1
        default:
            tideSliderValue = 0
        }
        if beachNo == BEACH_1 {
            self.beach_1_tideValue.text = tideState
            self.beach_1_tideSlider.value = tideSliderValue
        }else {
            self.beach_2_tiderValue.text = tideState
            self.beach_2_tiderSlider.value = tideSliderValue
        }
        
        //load uv
        let uv = uvapi(lat: beach.lat, long: beach.long)
        var uvSliderValue :Float = 0
        if uv.isLess(than: 5) {
            uvSliderValue = 1
        } else if uv.isLess(than: 8) {
            uvSliderValue = 5
        } else {
            uvSliderValue = 9
        }
        if beachNo == BEACH_1 {
            self.beach_1_uvValue.text = "\(uv)"
            self.beach_1_uvSlider.value = uvSliderValue
        } else {
            self.beach_2_uvValue.text = "\(uv)"
            self.beach_2_uvSlider.value = uvSliderValue
        }
        
        //load wind speed
        let weather = getCurrentWeatherDate(beach: beach)
        let windSpeed = weather[0]
        var windSliderValue :Float = 0
        if (windSpeed*2.237).isLess(than: 9) {
            windSliderValue = 1
        } else if (windSpeed*2.237).isLess(than: 16) {
            windSliderValue = 5
        } else {
            windSliderValue = 9
        }
        
        if beachNo == BEACH_1 {
            self.beach_1_windValue.text = "\(windSpeed) m/s"
            self.beach_1_windSlider.value = windSliderValue
        } else {
            self.beach_2_windValue.text = "\(windSpeed) m/s"
            self.beach_2_windSlider.value = windSliderValue
        }
        //check risk level
        switch uvSliderValue {
        case 1:
            uvSliderValue = 1
        case 5:
            uvSliderValue = 2
        case 9:
            uvSliderValue = 3
        default:
            uvSliderValue = 1
        }
        
        switch windSliderValue {
        case 1:
            windSliderValue = 1
        case 5:
            windSliderValue = 2
        case 9:
            windSliderValue = 3
        default:
            windSliderValue = 1
        }
        
        switch tideSliderValue {
        case 1:
            tideSliderValue = 1
        case 5:
            tideSliderValue = 2
        case 9:
            tideSliderValue = 3
        default:
            tideSliderValue = 1
        }
        let guardPoint:Float = beach.ifGuard ? 1: 3
        
        var riskPoint = uvSliderValue + windSliderValue + tideSliderValue + guardPoint
        var ifBoating = false
        if self.activtySegment.selectedSegmentIndex == 2 {
            let portPoint:Float = beach.ifPort ? 1: 3
            riskPoint = riskPoint + portPoint
            ifBoating = true
        }
        
        
        
//        var riskSliderValue :Float = 0
//        if self.activtySegment.selectedSegmentIndex == 2 {
//            let portPoint:Float = beach.ifPort ? 1: 3
//            if (riskPoint + portPoint) <= 9{
//                riskSliderValue = 1
//            } else if (riskPoint + portPoint) <= 12 {
//                riskSliderValue = 5
//            } else {
//                riskSliderValue = 9
//            }
//        } else {
//            if riskPoint < 6 {
//                riskSliderValue = 1
//            } else if riskPoint < 6 {
//                riskSliderValue = 5
//            } else {
//                riskSliderValue = 9
//            }
//        }
        
        if beachNo == BEACH_1 {
            //self.beach_1_riskSlider.value = riskSliderValue
            self.beach_1_meter.setPercent(riskPonit: Double(riskPoint), ifBoating: ifBoating)
            
        } else {
            self.beach_2_meter.setPercent(riskPonit: Double(riskPoint), ifBoating: ifBoating)
        }
    }
    
    
    // get rating data from mysql database
    func getRating(beachNo: Int, beachName: String){
        var avRating = 0.0
        //Defined a constant that holds the URL for our web service
        let URL_GET_RATING = "http://safewickers.000webhostapp.com/v1/getRating.php"
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
                if avRating > 0{
                    if beachNo == self.BEACH_1 {
                        DispatchQueue.main.async {
                            self.beach_1_cosmosView.rating = avRating
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.beach_2_cosmosView.rating = avRating
                        }
                    }
                } else {
                    if beachNo == self.BEACH_1 {
                        DispatchQueue.main.async {
                            self.beach_1_cosmosView.rating = 0
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.beach_2_cosmosView.rating = 0
                        }
                    }
                }
            } catch{}
        }
    }
    
    
    
    //get cuurent tide height
    func getTideHeight(tides: TidesData) -> Double{
        let height = tides.heights![0].height
        return height!
    }
  
    // check cuurnet tide state
    func checkTideState(tides: TidesData) -> String{
        let tide = tides.tides![0]
        
        let tideTimeStamp = tide.tideTimeStamp
        let tideState = tide.tideState
        
        let currentTime = Date()
        let currentTimeStamp = Int(currentTime.timeIntervalSince1970)
        
        let diff = tideTimeStamp! - currentTimeStamp
        
        if diff < 300 {
            return tideState!
        } else if diff < 3600 {
            return "MID TIDE"
        } else if diff < 18000 {
            return "SLACK TIDE"
        } else if diff < 21600 {
            return "MID TIDE"
        } else {
            if tideState == "HIGH TIDE" {
                return "LOW TIDE"
            } else {
                return "HIGH TIDE"
            }
        }
    }

    
  
    func tidesapi(lat: Double, long: Double) -> TidesData{
        var tide: TidesData?
        let sem = DispatchSemaphore.init(value: 0)
        // tides
        let headers = [
            "x-rapidapi-host": "tides.p.rapidapi.com",
            "x-rapidapi-key": "fffef8c1dcmsh4e578ad11989305p1fe58cjsnf0e1f2e55a6b"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://tides.p.rapidapi.com/tides?interval=60&duration=1440&latitude=44.414&longitude=-2.097")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in defer {sem.signal()}
            if (error != nil) {
                print(error?.localizedDescription as Any)
            } else {
                do {
//                    let test = try JSONSerialization.jsonObject(with: data!, options: [])
//                    print(test)
                    let decoder = JSONDecoder()
                    tide = try decoder.decode(TidesData.self, from: data!)
//                    tide = tideDatas.tides?[0]
                    
                } catch let err { print(err)
                }
            }
        })
        
        dataTask.resume()
        sem.wait()
        return tide!
    }
    
    
    // get UV data of the beach
    // uv api
    func uvapi(lat: Double, long: Double) -> Double {
        
        var uv: Double?
        let sem = DispatchSemaphore.init(value: 0)
        
        //backup key: 7d473ca9dd980058039404acc2f591c8    52cdda85a1f37c9eedc23a29cc5f5c11
        let headers = [
            "x-access-token": "7d473ca9dd980058039404acc2f591c8"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.openuv.io/api/v1/uv?lat=\(lat)&lng=\(long)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in defer {sem.signal()}
            if (error != nil) {
                print(error?.localizedDescription as Any)
            } else {
                do {
                    
                    let decoder = JSONDecoder()
                    let uvData = try decoder.decode(UVData.self, from: data!)
                    uv = uvData.uv
                    
                } catch let err { print(err)
                }
            }
        })
        
        dataTask.resume()
        sem.wait()
        return uv ?? 6.0
    }
    
    // get weather data
    func getCurrentWeatherDate(beach: LovedBeach) -> [Double]{
        var weatherData: [Double] = []
        let lat = beach.lat
        let long = beach.long
        
        let weatherApiID = "da9c3535ceb9e41bb432c229b579f2a8"
        let urlString = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=\(weatherApiID)"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
        guard let weatheData = NSData(contentsOf: url!) else {
            return []
        }
        
        
        do{
            let decoder = JSONDecoder()
            let weather = try decoder.decode(WeatherURLData.self, from: weatheData as Data)
            weatherData.append(weather.windSpeed)
            weatherData.append(weather.temp)
            weatherData.append(weather.humidity)
            weatherData.append(weather.pressure)
        } catch let err{
            print(err.localizedDescription)
        }
        return weatherData
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     if segue.identifier == "compareToBeachDetail"{
     let destination = segue.destination as! BeachDetailViewController
     destination.beach = self.comparedBeach
     }
    }
    func settranslate_Compare()
    {
        vsLabel.text = NSLocalizedString("Compare_vsLabel", comment: "Compare_vsLabel")
        ratingLabel.text = NSLocalizedString("Compare_ratingLabel", comment: "Compare_ratingLabel")
        riskLabel.text = NSLocalizedString("Compare_riskLabel", comment: "Compare_riskLabel")
        windSpeedLabel.text = NSLocalizedString("Compare_wind", comment: "Compare_wind")
        tideLabel.text = NSLocalizedString("Compare_tide", comment: "Compare_tide")
        uvLabel.text = NSLocalizedString("Compare_UV", comment: "Compare_UV")
        beach_1_detiallButton.setTitle(NSLocalizedString("Compare_detal1Button", comment: "Compare_detal1Button"), for: .normal)
        beach_2_detailButton.setTitle(NSLocalizedString("Compare_detal2Button", comment: "Compare_detal2Button"), for: .normal)
        selectBeachLabel.text = NSLocalizedString("Compare_slectLabel", comment: "Compare_slectLabel")
        beach_1_textField.placeholder = NSLocalizedString("CompareTextField1", comment: "CompareTextField1")
        beach_2_textField.placeholder = NSLocalizedString("CompareTextField2", comment: "CompareTextField2")
        lifeguardLabel.text = NSLocalizedString("Compare_lifeguard", comment: "Compare_lifeguard")
        portLabel.text = NSLocalizedString("Compare_port", comment: "Compare_port")
    }
}

