//
//  LovedBeachListTableViewController.swift
//  Safe Wickers
//
//  Created by 匡正 on 26/4/20.
//  Copyright © 2020 匡正. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import SDWebImage
import Alamofire

class LovedBeachListTableViewController: UITableViewController, DatabaseListener, CLLocationManagerDelegate {
    
    var ratings: [String:Double] = [:]
    var databaseController: DatabaseProtocol?
    var lovedBeachs:[LovedBeach] = []
    var beach: Beach?
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
        self.tableView.estimatedRowHeight = 0
        addNavBarImage()
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLLocationAccuracyKilometer
        locationManager.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        currentLocation = location
    }
    
    
    func onLovedBeachChange(change: DatabaseChange, lovedBeachs: [LovedBeach]) {
        self.lovedBeachs = lovedBeachs
        for beach in lovedBeachs {
             getRating(beachName: beach.beachName!)
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lovedBeachs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lovedBeachCell", for: indexPath) as! LovedBeachTableViewCell
        
        let lovedBeach = lovedBeachs[indexPath.row]
        
        cell.beachNameLabel.text = lovedBeach.beachName
        
//        let beachLocation = CLLocation(latitude:lovedBeach.lat, longitude: lovedBeach.long)
//
//        if let loction = currentLocation{
//            let distance = loction.distance(from:beachLocation).rounded()
//            cell.distanceLabel.text = "\(distance/1000) km"
//        }else{
//                cell.distanceLabel.text = ""
//            }
//        if let distance = currentLocation?.distance(from:beachLocation).rounded() {
//            cell.distanceLabel.text = "\(distance/1000) km"
//        } else{
//             cell.distanceLabel.text = ""
//        }
        let url = URL(string: lovedBeach.imageNmae!)
        cell.beachImageView!.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultBeachImage.jpg"), completed: nil)

        // Configure the cell...
        // get rating from database or load beach info methods
        for obj in ratings{
            if lovedBeach.beachName! == obj.key {
                cell.setRating(rating: obj.value)
            }
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 300
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    //header of section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Favourite_title", comment: "Favourite_title")
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let beach = lovedBeachs[indexPath.row]
            // Delete the row from the data source
             self.lovedBeachs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.databaseController?.deleteLovedBeach(lovedBeach: beach)
            
        }
    }
    
    // action after select a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        getBeachInfo(lovedBeach: lovedBeachs[indexPath.row])
        performSegue(withIdentifier: "loveToBeachDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    

    // create a beach send to detail screen
    func getBeachInfo(lovedBeach:LovedBeach){
        let beachName = lovedBeach.beachName
        let lat = lovedBeach.lat
        let long = lovedBeach.long
        let imageName = lovedBeach.imageNmae
        let ifPort = lovedBeach.ifPort
        let ifGuard = lovedBeach.ifGuard
        let beachLocation = CLLocation(latitude:lovedBeach.lat, longitude: lovedBeach.long)
        let distance = currentLocation?.distance(from: beachLocation).rounded()
        
        let weatherData = getCurrentWeatherDate(beach: lovedBeach)
        let windSpeed = weatherData[0]
        let temp = weatherData[1]
        let hum = weatherData[2]
        let pre = weatherData[3]
        let uv = uvapi(lat: lat, long: long)
        
        let tides = tidesapi(lat: lat, long: long)
        let tideState = checkTideState(tides: tides)
        let tideHeight = getTideHeight(tides: tides)
           
        
        self.beach = Beach(beachName: beachName!, latitude: lat, longitude: long, imageName: imageName!, distance: distance ?? 0.0, risk: "s", ifGuard: ifGuard, ifPort: ifPort, descrip: "", windSpeed: windSpeed, temp: temp, hum: hum, pre: pre, ifLoved: true, uv: uv, tideState: tideState, tideHeight: tideHeight)
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
            DispatchQueue.main.async {
                self.displayMessage(title: "Error", message: err.localizedDescription)
            }
        }
        return weatherData
    }
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
// uv api
    func uvapi(lat: Double, long: Double) -> Double {
        
        var uv: Double?
        let sem = DispatchSemaphore.init(value: 0)
        
        //backup key: 7d473ca9dd980058039404acc2f591c8     52cdda85a1f37c9eedc23a29cc5f5c11
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
                //self.ratings.updateValue(avRating, forKey: beachName)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                //                print(self.tttt)
            } catch{}
        }
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "loveToBeachDetail"{
            let destination = segue.destination as! BeachDetailViewController
            destination.beach = self.beach
        }
        if segue.identifier == "showLovedMapSegue" {
            let destination = segue.destination as! MapViewController
            destination.focusLocation = CLLocation(latitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!)
            var list: [Beach] = []
            for item in lovedBeachs{
                getBeachInfo(lovedBeach: item)
                list.append(self.beach!)
            }
            destination.beachList = list
        }
    }
    

}
