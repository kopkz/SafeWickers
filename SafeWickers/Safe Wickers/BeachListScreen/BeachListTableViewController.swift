//
//  BeachListTableViewController.swift
//  Safe Wickers
//
//  Created by 匡正 on 20/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage
import CoreData
import Popover_OC
import Alamofire

class BeachListTableViewController: UITableViewController{
    
    weak var databaseController: DatabaseProtocol?
    //database listener
    var listenerType = ListenerType.lovedBeach
    var lovedBeachs:[LovedBeach] = []
    var ratings: [String:Double] = [:]
    
    var regionLocation: CLLocationCoordinate2D?
    var matchingItems:[MKMapItem] = []
    var beachList:[Beach] = []
    var fliteredList:[Beach] = []
    var activityName: String?
    var indicator = UIActivityIndicatorView()
    var imageURLs:[String] = []
    var lifeGuardLoactions:[String] = []
    var ifSearchBeachDirctly: Bool?
    var ifOnlyLifeGuard: Bool?
    var ifOnlyPort: Bool?
    
    
    let weatherApiID = "da9c3535ceb9e41bb432c229b579f2a8"
    
    let SECTION_SETTING = 0
    let SECTION_BEACH = 1
    let SECTION_COUNT = 2
    let CELL_SETTING = "settingCell"
    let CELL_BEACH = "beachCell"
    let CELL_COUNT = "countCell"
    
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

        //edit navi bar
        addNavBarImage()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //create a loading animation
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.tableView.center
//        //add text to indicator
//        let indicatorLabel = UILabel()
//        indicatorLabel.text = "LOADING"
//        indicatorLabel.textColor = UIColor.gray
//        indicatorLabel.font = UIFont(name: "Avenir Light", size: 10)
//        indicatorLabel.sizeToFit()
//        indicatorLabel.center = CGPoint(x: indicator.center.x, y: indicator.center.y + 30)
//        indicator.addSubview(indicatorLabel)
        self.view.addSubview(indicator)
        indicator.startAnimating()
       
        lifeGuardLoactions = lifeGuardLoaction()
        //get beach info
        getBeachLocationList()
        
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
       
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        //create a loading animation
//        indicator.style = UIActivityIndicatorView.Style.gray
//        indicator.center = self.tableView.center
//        self.view.addSubview(indicator)
//
//        //loadImage()
//    }
    
    
    
    // load other beach info, such as image,distance,etc
    func loadBeachInfo(){
        for item in matchingItems{
            let beachName = item.name
            let latitude = item.placemark.coordinate.latitude
            let longitude = item.placemark.coordinate.longitude
            let distance = item.placemark.location?.distance(from: CLLocation(latitude: regionLocation!.latitude, longitude: regionLocation!.longitude)).rounded()
            
            let ifGuard = checkIfGuard(beach: item)
            let ifPort = checkIfPort(beach: item)
            
            //get rating from sql database
            getRating(beachName: beachName!)
            
            
            // when test other functuon stop search image
            let imageNmae = ""
//            let imageNmae = searchIamgeOnline(beach: "\(beachName!) Victoria")
            
//            let des = item.placemark.locality ?? ""
            let weatherData = getCurrentWeatherDate(beach: item)
            let windSpeed = weatherData[0]
            let temp = weatherData[1]
            let hum = weatherData[2]
            let pre = weatherData[3]
            
            let uv = uvapi(lat: latitude, long: longitude)
            
            let tides = tidesapi(lat: latitude, long: longitude)
            let tideState = checkTideState(tides: tides)
            let tideHeight = getTideHeight(tides: tides)
            
            
            let risk = chechRisk(ifPort: ifPort, ifGuard: ifGuard, windSpeed: windSpeed, uv: uv, tideState: tideState)

            let ifLoved = checkIfLoved(beachNmae: beachName!)

            let beach = Beach(beachName: beachName!, latitude: latitude, longitude: longitude, imageName: imageNmae, distance: distance!, risk: risk, ifGuard: ifGuard, ifPort: ifPort, descrip: "", windSpeed: windSpeed, temp: temp, hum: hum, pre: pre, ifLoved: ifLoved, uv: uv, tideState: tideState, tideHeight: tideHeight)

            beachList.append(beach)
        }
        
    }
    
    //chech the risk according to activity, wind , guard, port, uv, tide, detail algoritm in data plan SM page
    
    func chechRisk(ifPort: Bool, ifGuard: Bool, windSpeed: Double, uv: Double, tideState: String) -> String{
        var portRating: Int?
        var guardRating: Int?
        var windRating: Int?
        var uvRating: Int?
        var tideRating: Int?
        var risk: String?
        
        if ifPort {
            portRating = 1
        } else {
            portRating = 3
        }
        
        if ifGuard {
            guardRating = 1
        } else {
            guardRating = 3
        }
        
        if (windSpeed*2.237).isLess(than: 9) {
            windRating = 1
        } else if (windSpeed*2.237).isLess(than: 16) {
            windRating = 2
        } else {
            windRating = 3
        }
        
        if uv.isLess(than: 5) {
            uvRating = 1
        } else if uv.isLess(than: 8) {
            uvRating = 2
        } else {
            uvRating = 3
        }
        
        switch tideState {
        case "LOW TIDE":
            tideRating = 3
        case "HIGH TIDE":
            tideRating = 3
        case "MID TIDE":
            tideRating = 2
        case "SLACK TIDE":
            tideRating = 1
        default:
            tideRating = 2
        }
    
        
        
        if activityName == "Boating" {
           let riskRating = portRating! + guardRating! + windRating! + uvRating! + tideRating!
            if riskRating <= 9 {
                risk = "l"
            } else if riskRating <= 12 {
                risk = "m"
            } else {
                risk = "h"
            }
        } else {
            let riskRating = guardRating! + windRating! + uvRating! + tideRating!
            if riskRating < 6 {
                risk = "l"
            } else if riskRating < 9 {
                risk = "m"
            } else {
                risk = "h"
            }
        }
        
      
        return risk!
    }
    
    func searchIamgeOnline(beach: String) -> String {
        var beachImageURL: String?

        //key:   AIzaSyBDczIvDMC85RvOC1lKpxUGB50GH4mD6yc    AIzaSyBcZK2M_pWExrukRTeeMBJ_LgFv13lIVQI

        let searchString = "https://www.googleapis.com/customsearch/v1?key=AIzaSyBDczIvDMC85RvOC1lKpxUGB50GH4mD6yc&cx=002407881098821145824:29fpb6s3hfq&q=\(beach)&searchType=image&num=1"
        let jsonURL = URL(string: searchString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)

        
        guard let urlData = NSData(contentsOf: jsonURL!) else{ return ""}
        
        do{
            let decoder = JSONDecoder()
            let imageDate = try decoder.decode(OnlineImageData.self, from: urlData as Data)
            
            guard let imageURL = imageDate.onlineImages?[0].imageURL else {return ""}
            beachImageURL = imageURL
            
            
        } catch let err{
                            DispatchQueue.main.async {
                               self.displayMessage(title: "Error", message: err.localizedDescription)
                            }
                        }
        return beachImageURL ?? ""
    }

    
    //get weather info of beach
    
    func getCurrentWeatherDate(beach: MKMapItem) -> [Double]{
        var weatherData: [Double] = []
        let lat = beach.placemark.location?.coordinate.latitude
        let long = beach.placemark.location?.coordinate.longitude
        
        let urlString = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat!)&lon=\(long!)&appid=\(weatherApiID)"
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
                                        DispatchQueue.main.async {
                                           self.displayMessage(title: "Error", message: err.localizedDescription)
                                        }
                                    }
        return weatherData
    }
    
    // get UV data of the beach
    // uv api
    func uvapi(lat: Double, long: Double) -> Double {
        
        var uv: Double?
        let sem = DispatchSemaphore.init(value: 0)
        
        //backup key: 7d473ca9dd980058039404acc2f591c8    52cdda85a1f37c9eedc23a29cc5f5c11
        let headers = [
            "x-access-token": "52cdda85a1f37c9eedc23a29cc5f5c11"
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
    
    
    // get data form tide API
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
    
    
    // check the beach if have lifeguard
    func checkIfGuard(beach: MKMapItem) -> Bool{
        if let  lgLocation = beach.placemark.subLocality {
            return lifeGuardLoactions.contains(lgLocation)
        }
        return false
    }
    
    
    
    
    //check the beach if have port
    func checkIfPort(beach: MKMapItem) -> Bool{
        
        let melPort = CLLocation(latitude: -37.8432094464, longitude: 144.9267604579)
        let welPort = CLLocation(latitude: -38.694353, longitude: 146.466637)
        let geePort = CLLocation(latitude: -38.116666667, longitude: 144.383333333)
        let portPort = CLLocation(latitude: -38.35, longitude: 141.616666667)

        if (beach.placemark.location?.distance(from: melPort).isLess(than: 5000))! {
            return true
        }
        if (beach.placemark.location?.distance(from: welPort).isLess(than: 5000))! {
            return true
        }
        if (beach.placemark.location?.distance(from: geePort).isLess(than: 5000))! {
            return true
        }
        if (beach.placemark.location?.distance(from: portPort).isLess(than: 5000))! {
            return true
        }
        
        return false
    }
    
    //sort the list
    func sortListByLetter(){
        // sort according to alphabetical order
        fliteredList = beachList.sorted(){ $0.beachName!.lowercased() < $1.beachName!.lowercased()}
        self.tableView.reloadData()
    }
    
    
    
    // sort by distance
    func sortListByDistance(){
        // sort according to alphabetical order
        fliteredList = beachList.sorted(by: {$0.distance! < $1.distance!})
        
//       fliteredList = beachList.sorted(){ String(format: "%f",$0.distance!) < String(format: "%f",$1.distance!) }
         self.tableView.reloadData()
    }
   
    
    func fliterList(){
        // safe or unsafe
        fliteredList = beachList.filter({(beach: Beach) -> Bool in
            return beach.risk?.contains("l") ?? false
        })
        if fliteredList.count == 0 {
            let responseAlert = UIAlertController(title: NSLocalizedString("filter_Error_title", comment: "filter_Error_title"), message: NSLocalizedString("filter_Error_messgae", comment: "filter_Error_messgae"), preferredStyle: .alert)
            responseAlert.addAction(UIAlertAction(title: NSLocalizedString("Se_Dismiss", comment: "Se_Dismiss"), style: .default, handler: nil))
            self.present(responseAlert, animated: true, completion: nil)
            
        }
         self.tableView.reloadData()
    }
    
    // filter by lifeguard
    func fliterListByLifeGuard(){
        fliteredList = beachList.filter({(beach: Beach) -> Bool in
            return beach.ifGuard ?? false
        })
        if fliteredList.count == 0 {
            let responseAlert = UIAlertController(title: NSLocalizedString("filter_Error_title", comment: "filter_Error_title"), message: NSLocalizedString("filter_Error_messgae", comment: "filter_Error_messgae"), preferredStyle: .alert)
            responseAlert.addAction(UIAlertAction(title: NSLocalizedString("Se_Dismiss", comment: "Se_Dismiss"), style: .default, handler: nil))
            self.present(responseAlert, animated: true, completion: nil)
            
        }
        self.tableView.reloadData()
    }
    
    // filter by port
    func fliterListByPort(){
        fliteredList = beachList.filter({(beach: Beach) -> Bool in
            return beach.ifPort ?? false
        })
        if fliteredList.count == 0 {
            let responseAlert = UIAlertController(title: NSLocalizedString("filter_Error_title", comment: "filter_Error_title"), message: NSLocalizedString("filter_Error_messgae", comment: "filter_Error_messgae"), preferredStyle: .alert)
            responseAlert.addAction(UIAlertAction(title: NSLocalizedString("Se_Dismiss", comment: "Se_Dismiss"), style: .default, handler: nil))
            self.present(responseAlert, animated: true, completion: nil)
            
        }
        self.tableView.reloadData()
    }
    
    
    // serch neaby beach
    func getBeachLocationList() {
      
        //create request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "beach"
        searchRequest.region = MKCoordinateRegion.init(center: regionLocation!, latitudinalMeters: 20000, longitudinalMeters: 20000)
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        //start search
        activeSearch.start { (response, error) in
            
            if response == nil
            {
                print("ERROR")
            }
            else
            {
                //Getting data
                if self.ifSearchBeachDirctly!{
                    self.matchingItems = [response!.mapItems.first] as! [MKMapItem]
                }else {
                    self.matchingItems = response!.mapItems
                }
                self.loadBeachInfo()
                self.fliteredList = self.beachList
                
                self.indicator.stopAnimating()
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    // get rating data from mysql database
    func getRating(beachName: String){
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
                    self.ratings.updateValue(avRating, forKey: beachName)
                } else {
                    self.ratings.updateValue(0, forKey: beachName)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                //                print(self.tttt)
            } catch{}
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == SECTION_BEACH {
            return fliteredList.count
        } else{
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...

        if indexPath.section == SECTION_SETTING{
            let settingCell = tableView.dequeueReusableCell(withIdentifier: CELL_SETTING, for: indexPath) as! FilterButtonTableViewCell
            //settingCell.textLabel?.text = " \(String(describing: activityName))TODO: filter button"
            settingCell.delegate = self
            return settingCell
        }
        
            let beachCell = tableView.dequeueReusableCell(withIdentifier: CELL_BEACH, for: indexPath) as! BeachListTableViewCell
        beachCell.riskLevelLabel.text = NSLocalizedString("Beachlist_riskLabel", comment: "Beachlist_riskLabel")
        
        
            let beach = fliteredList[indexPath.row]
            beachCell.delegate = self
            beachCell.setBeach(beach: beach)
            beachCell.loveUnloveButton.isLove = beach.ifLoved!
            beachCell.loveUnloveButton.unpdateImage()
//            beachCell.loveUnloveButton.imageView?.image = beach.ifLoved! ? UIImage(named: "icons8-like-96-2") : UIImage(named: "icons8-unlike-96")
        
            //beach.beachName
            beachCell.beachNameLabel.text = beach.beachName
            beachCell.distanceLabel.text = "\(beach.distance!/1000) km"
        //
        // load image online
            //beachCell.beachImage.image = UIImage(named: beach.imageName!)
        let url = URL(string: beach.imageName!)
       
        beachCell.beachImage!.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultBeachImage.jpg"), completed: nil)
        
        switch beach.risk {
        case "l":
            beachCell.riskImageView.image = UIImage(named: "lowRisk")
        case "m":
            beachCell.riskImageView.image = UIImage(named: "midRisk")
        case "h":
            beachCell.riskImageView.image = UIImage(named: "highRisk")
        default:
            beachCell.riskImageView.image = UIImage(named: "midRisk")
        }
        
        
        // get rating from database or load beach info methods
        for obj in ratings{
            if beach.beachName! == obj.key {
                beachCell.setRating(rating: obj.value)
            } 
        }
        
        
            return beachCell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SECTION_BEACH{
            return 300
        }
        return 45
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_BEACH{
//            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "listToBeachDetail", sender: self)
        }
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

    
     //MARK: - Navigation

     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMapSegue" {
           let destination = segue.destination as! MapViewController
            destination.focusLocation = CLLocation(latitude: regionLocation!.latitude, longitude: regionLocation!.longitude)
            destination.beachList = fliteredList
        }
        if segue.identifier == "listToBeachDetail" {
            let destination = segue.destination as! BeachDetailViewController
            let index = tableView.indexPathForSelectedRow?.row
            destination.beach = fliteredList[index!]
        }
    }
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func lifeGuardLoaction() -> [String] {
        if let path = Bundle.main.path(forResource: "lg_suburbs", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .dataReadingMapped)
                let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [[String:String]]
                
                var countryNames = [String]()
                for country in jsonResult {
                    countryNames.append(country["lg_suburb"]!)
                }
                
                return countryNames
            } catch {
                print("Error parsing jSON: \(error)")
                return []
            }
        }
        return []
    }
    
    
}

extension BeachListTableViewController: FilterCellDelegate {
    func showSortingMenue() {
         let action1 = PopoverAction.init(title: NSLocalizedString("List_sortingByName", comment: "List_sortingByName")) { (action1) in
                   self.sortingByInitials()
                   
                  
               }
               let action2 = PopoverAction.init(title: NSLocalizedString("List_sortingByDistance", comment: "List_sortingByDistance")) { (action2) in
                   self.sortingByDistance()
               }
               let action3 = PopoverAction.init(title: NSLocalizedString("List_sortingAllBeaches", comment: "List_sortingAllBeaches")) { (action3) in
                   self.showAllBeach()
               }
               let action4 = PopoverAction.init(title: NSLocalizedString("List_sortingSafeBeaches", comment: "List_sortingSafeBeaches")) { (action4) in
                   self.onlyShowSafeBeach()
               }
               let action5 = PopoverAction.init(title: NSLocalizedString("List_SortinglifeGuard", comment: "List_SortinglifeGuard")) { (action4) in
                   self.fliterListByLifeGuard()
               }
               let action6 = PopoverAction.init(title: NSLocalizedString("List_SortingPort", comment: "List_SortingPort")) { (action4) in
                   self.fliterListByPort()
               }
        let sortingMenueView = PopoverView()
        sortingMenueView.show(to: CGPoint(x: self.view.bounds.width, y: 130), with: [action1!, action2!, action3!, action4!, action5!, action6!])
        
    }
    
    func onlyShowSafeBeach() {
        self.fliterList()
    }
    
    func showAllBeach() {
        self.fliteredList = beachList
        self.tableView.reloadData()
    }
    
    func sortingByInitials() {
        self.sortListByLetter()
    }
    
    func sortingByDistance() {
        self.sortListByDistance()
    }
}

extension BeachListTableViewController: DatabaseListener{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onLovedBeachChange(change: DatabaseChange, lovedBeachs: [LovedBeach]) {
        self.lovedBeachs = lovedBeachs
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
    
    func addLovedBeach(beach:Beach) {
        
        let ifLoved = checkIfLoved(beachNmae: beach.beachName!)
        if ifLoved {
            return
        }
        let _ = databaseController!.addLovedBeach(beachName: beach.beachName!, lat: beach.latitude!, long: beach.longitude!, imageName: beach.imageName!, ifGuard: beach.ifGuard!, ifPort: beach.ifPort!)
        beach.ifLoved = true
        let responseAlert = UIAlertController(title: NSLocalizedString("detail_love_title", comment: "detail_love_title"), message:nil, preferredStyle: .alert)
        self.present(responseAlert, animated: true, completion: nil)
        // miss after 2 second
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    func cancelLovedBeach(beach: Beach) {
        var unlovedBeach: LovedBeach?
        for bea in lovedBeachs {
            if bea.beachName == beach.beachName{
                unlovedBeach = bea
            }
        }
        guard let unloved = unlovedBeach else {
            return
        }
        
        let _ = databaseController!.deleteLovedBeach(lovedBeach: unloved)
        beach.ifLoved = false
        let responseAlert = UIAlertController(title: NSLocalizedString("detail_unlove_title", comment: "detail_unlove_title"), message:nil, preferredStyle: .alert)
        self.present(responseAlert, animated: true, completion: nil)
        // miss after 2 second
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    
}

extension BeachListTableViewController: LoveBeachDelagate {
  
    func loveUnloveBeach(beach: Beach) {
        if beach.ifLoved! {
            cancelLovedBeach(beach: beach)
        }else {
            addLovedBeach(beach: beach)
        }
//        tableView.reloadData()
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.reloadSections(IndexSet(integer: 1) as IndexSet, with:
            UITableView.RowAnimation.none)
        self.tableView.endUpdates()
    }
}
