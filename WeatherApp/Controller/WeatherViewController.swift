//
//  ViewController.swift
//  WeatherApp
//
//  Created by Peter Schwartz on 1/20/22.
//

import UIKit
import CoreLocation
import CoreData

class WeatherViewController: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, PopUpDelegate {
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let loadingVC = LoadingViewController()
    
    var locationManager:CLLocationManager!
    
    var userLat: Double = 0.0
    var userLon: Double = 0.0
    
    var userSubmittedLat: Double = 0.0
    var userSubmittedLon: Double = 0.0

    var dataController: DataController!
    
    var locations: [Location]!
    var location: Location!
    
    var callOnce:Bool = false

    var favLocation: Location!
    
    var cityState: String!
    
    var hourlyForecast: [HourlyForecast]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        temp.text = ""
        city.text = ""
        
        collectionView.layer.cornerRadius = 15.0
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        collectionView.layer.borderWidth = 0.0
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 0)
        collectionView.layer.shadowRadius = 5.0
        collectionView.layer.shadowOpacity = 1
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(favTapped))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        fetchLocations()
    }
    
    @objc func addTapped() {
        PopupViewController.showPopup(parentVC: self)
    }
    
    @objc func favTapped() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoritesViewController") as? FavoritesViewController {
            vc.locations = locations
            vc.cityState = cityState
            vc.modalPresentationStyle = .fullScreen
            vc.dataController = dataController
            present(vc, animated: true, completion: nil)
        }
    }
    
    func refreshWeather(latitude: Double, longitude: Double) {
        userSubmittedLat = latitude
        userSubmittedLon = longitude
        let location = CLLocation(latitude: userSubmittedLat, longitude: userSubmittedLon)
        getPlacemarkFromLocation(location: location)
        fetchForecast()
    }
    
    func fetchLocations() {
        // fetch locations
        let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            locations = result
        }
                
        if !locations.isEmpty {
            var foundFav = false
            for loc in locations {
                if loc.favorite == true {
                    foundFav = true
                    favLocation = loc
                }
            }
            if foundFav == true {
                userLat = favLocation.latitude
                userLon = favLocation.longitude
                userSubmittedLon = 0.0
                userSubmittedLat = 0.0
                let location = CLLocation(latitude: userLat, longitude: userLon)
                getPlacemarkFromLocation(location: location)
            } else {
                // Just load the first one in the list this will be set later in favorites once it's opened
                userSubmittedLat = 0.0
                userSubmittedLon = 0.0
                userLat = locations[0].latitude
                userLon = locations[0].longitude
                let location = CLLocation(latitude: userLat, longitude: userLon)
                getPlacemarkFromLocation(location: location)
            }
            fetchForecast()
        } else {
            if userLat != 0.0 && userLon != 0.0 {
                fetchForecast()
            }
        }
    }
    
    func fetchForecast() {
        let loadingVC = LoadingViewController()
        loadingVC.modalPresentationStyle = .overCurrentContext
        loadingVC.modalTransitionStyle = .crossDissolve
        present(loadingVC, animated: true, completion: nil)
        
        var forecastLat: Double = 0.0
        var forecastLon: Double = 0.0
        
        if userLat != 0.0 && userLon != 0.0 {
            forecastLat = userLat
            forecastLon = userLon
        }
        
        if userSubmittedLat != 0.0 && userSubmittedLon != 0.0 {
            forecastLat = userSubmittedLat
            forecastLon = userSubmittedLon
        }
        
        OWMClient.getForecast(latitude: forecastLat, longitude: forecastLon) { forecastResponse, error in
            if let forecastResponse = forecastResponse {
                DispatchQueue.main.async {
                    self.hourlyForecast = forecastResponse.hourly
                    self.collectionView.reloadData()
                    self.addLocationToCoreData(lat: forecastLat, lon: forecastLon)
                }
                OWMClient.downloadWeatherIcon(weatherIcon: forecastResponse.current.weather[0].icon) { imageData, error in
                    DispatchQueue.main.async {
                        if let imageData = imageData {
                            self.weatherIcon.image = UIImage(data: imageData)
                            let fahrenTemp = (forecastResponse.current.temp - 273.15) * 9/5 + 32
                            self.temp.text = String(Int(fahrenTemp)) + "\u{00B0}"
                            loadingVC.dismiss(animated: true, completion: nil)
                        } else {
                            loadingVC.dismiss(animated: true) {
                                self.showError(message: error?.localizedDescription ?? "")
                            }
                        }
                    }
                }
            } else {
                loadingVC.dismiss(animated: true) {
                    self.showError(message: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !callOnce || locations.isEmpty {
            let userLocation: CLLocation = locations[0] as CLLocation
            
            print("User latitude: \(userLocation.coordinate.latitude)")
            print("User longitude: \(userLocation.coordinate.longitude)")
            
            userLat = userLocation.coordinate.latitude
            userLon = userLocation.coordinate.longitude
            
            getPlacemarkFromLocation(location: userLocation)
            
            fetchForecast()
            
            callOnce = true
        }
    }
    
    func getPlacemarkFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let placemarks = placemarks {
                let userCity = placemarks[0].locality ?? ""
                let userState = placemarks[0].administrativeArea ?? ""
                if !userCity.isEmpty && !userState.isEmpty {
                    self.city.text =  "\(userCity), \(userState)"
                    self.cityState = self.city.text
                } else if !userCity.isEmpty {
                    self.city.text =  "\(userCity)"
                    self.cityState = self.city.text
                } else {
                    self.city.text =  "\(userState)"
                    self.cityState = self.city.text
                }
            }
        }
    }
    
    func addLocationToCoreData(lat: Double, lon: Double) {
        let managedContext = dataController.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
        
        if !locations.isEmpty {
            var isUnique = false
            for loc in locations {
                if userSubmittedLon != 0.0 && userSubmittedLat != 0.0 {
                    if userSubmittedLon != loc.longitude && userSubmittedLat != loc.latitude {
                        isUnique = true
                    } else {
                        isUnique = false
                    }
                }
            }
            if isUnique {
                let location = Location(entity: entity, insertInto: managedContext)
                location.setValue(userSubmittedLat, forKeyPath: "latitude")
                location.setValue(userSubmittedLon, forKeyPath: "longitude")
                location.setValue(cityState, forKeyPath: "cityState")
                self.locations.append(location)
            }
        } else {
            //If locations is empty just add the location must be a first load
            if userLat != 0.0 && userLon != 0.0 {
                let location = Location(entity: entity, insertInto: managedContext)
                location.setValue(userLat, forKeyPath: "latitude")
                location.setValue(userLon, forKeyPath: "longitude")
                location.setValue(cityState, forKeyPath: "cityState")
                self.locations.append(location)
            }
        }
        try? self.dataController.viewContext.save()
    }
    
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hourlyForecast == nil {
            return 0
        } else {
            return hourlyForecast.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! WeatherCollectionViewCell
        
        cell.loadingIndicator.startAnimating()
        cell.loadingIndicator.isHidden = false
        cell.hourlyTime.text = ""
        //cell.hourlyTemp.text = ""
        cell.hourlyIcon.image == nil
        
        OWMClient.downloadWeatherIcon(weatherIcon: hourlyForecast[indexPath.row].weather[0].icon) { imageData, error in
            DispatchQueue.main.async {
                if let imageData = imageData {
                    let date = self.hourlyForecast[indexPath.row].dt
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h a"
                    dateFormatter.timeZone = TimeZone.current
                    dateFormatter.locale = Locale.current
                    
                    let formattedDate = dateFormatter.string(from:date)

                    let hourlyTime = formattedDate
                    cell.hourlyTime.text = hourlyTime
                    
                    cell.hourlyIcon.image = UIImage(data: imageData)
                    
                    let hourlyTemp = (self.hourlyForecast[indexPath.row].temp - 273.15) * 9/5 + 32
                    cell.hourlyTemp.text = String(Int(hourlyTemp)) + "\u{00B0}"
                    
                    cell.loadingIndicator.stopAnimating()
                    cell.loadingIndicator.isHidden = true
                } else {
                    cell.loadingIndicator.stopAnimating()
                    cell.loadingIndicator.isHidden = true
                }
            }
        }
        
        cell.layer.cornerRadius = 15.0
        cell.layer.borderWidth = 0.0
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 1

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let constraints = collectionView.bounds
        return CGSize(width: (constraints.width/4), height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top:8, left: 16, bottom: 8, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 22
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}




