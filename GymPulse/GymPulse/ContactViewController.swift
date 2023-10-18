import UIKit
import MapKit
import CoreLocation

class ContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var selectGymButton: UIButton!
    @IBOutlet weak var gymPickerView: UIPickerView!
    @IBOutlet weak var gymAddressLabel: UILabel!
    @IBOutlet weak var gymAddressTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var availableTrainersLabel: UILabel!
    @IBOutlet weak var trainerPickerView: UIPickerView!
    
    let baseURL = Bundle.main.infoDictionary?["BASE_URL"] as? String
    private var gyms: [String] = []
    private var selectedGymInfo: [String: Any] = [:]
    private var trainers: [[String: Any]] = []
    private var userCurrentLocation: CLLocation?
    private var locationManager = CLLocationManager()
    private let searchRadius: CLLocationDistance = 500
    private let proximityRadius: CLLocationDistance = 32186.9

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        setupUI()
        fetchGymNames()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        let appleMapsTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAppleMapsTap(_:)))
        mapView.addGestureRecognizer(appleMapsTapGesture)
    }
    
    private func setupUI() {
        gymPickerView.delegate = self
        gymPickerView.dataSource = self
        trainerPickerView.delegate = self
        trainerPickerView.dataSource = self
        gymAddressTextField.isUserInteractionEnabled = false
    }
    
    @IBAction func selectGymPressed(_ sender: UIButton) {
        fetchGymNames()
    }
    
    @IBAction func viewTrainersPressed(_ sender: UIButton) {
        if let locationId = selectedGymInfo["location_id"] as? Int {
            fetchTrainers(by: locationId) { success in
                if !success {
                    self.showAlert(title: "No Trainers", message: "No trainers available at the selected gym.")
                }
            }
        } else {
            showAlert(title: "Error", message: "Unable to fetch trainers for the selected gym.")
        }
    }
    
    private func fetchTrainers(by locationId: Int, completion: @escaping (Bool) -> Void) {
        let url = URL(string: baseURL + "get_trainer_by_location_id.php?location_id=\(locationId)")!
        
        fetchData(from: url) { (data: [[String: Any]]?) in
            if let fetchedTrainers = data, !fetchedTrainers.isEmpty {
                self.trainers = fetchedTrainers
                self.trainerPickerView.reloadAllComponents()
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    private func fetchGymNames() {
        let url = URL(string: baseURL + "get_all_gym_names.php")!
        fetchData(from: url) { (data: [String]?) in
            self.gyms = data ?? []
            self.gymPickerView.reloadAllComponents()
            
            if let firstGym = self.gyms.first {
                self.fetchGymInfo(by: firstGym)
            }
        }
    }

    private func fetchGymInfo(by name: String) {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: baseURL + "get_gym_info_by_gym_name.php?gym_name=\(encodedName)")!
        fetchData(from: url) { (data: [String: Any]?) in
            if let gymInfo = data {
                self.selectedGymInfo = gymInfo
                if let address = gymInfo["address"] as? String {
                    self.gymAddressTextField.text = address
                    self.updateMapView(with: address)
                }
                if let locationId = gymInfo["location_id"] as? Int {
                    self.fetchTrainers(by: locationId)
                }
            }
        }
    }

    private func fetchTrainers(by locationId: Int) {
        let url = URL(string: baseURL + "get_trainer_by_location_id.php?location_id=\(locationId)")!
        fetchData(from: url) { (data: [[String: Any]]?) in
            if let fetchedTrainers = data {
                self.trainers = fetchedTrainers
                self.trainerPickerView.reloadAllComponents()
                self.availableTrainersLabel.text = "Available Trainers: \(fetchedTrainers.count)  "
            } else {
                self.availableTrainersLabel.text = "No Trainers Available"
            }
        }
    }
    
    private func fetchData<T>(from url: URL, completion: @escaping (T?) -> Void) where T: Any {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to fetch data. Please try again.")
                }
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if T.self is [String].Type {
                    let decodedData = try JSONDecoder().decode([String].self, from: data)
                    DispatchQueue.main.async {
                        completion(decodedData as? T)
                    }
                } else if T.self is [String: Any].Type || T.self is [[String: Any]].Type {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? T {
                        DispatchQueue.main.async {
                            completion(jsonObject)
                        }
                    }
                }
            } catch {
            }
        }.resume()
    }
    
    private func updateMapView(with address: String) {
        let gymName = selectedGymInfo["gym_name"] as? String ?? ""
        
        searchInMaps(using: gymName) { (results) in
            if results.isEmpty {
                self.showAlert(title: "Error", message: "Unable to find the location.")
                return
            }
            
            if results.count == 1, let firstResult = results.first {
                self.displayLocation(location: firstResult.placemark.location!, title: gymName, subtitle: address)
                return
            }
            
            let actionSheet = UIAlertController(title: "Select a Location", message: "Multiple locations found. Please select the correct one.", preferredStyle: .actionSheet)
            
            for result in results {
                let addressAndCity = self.formatStreetAddressAndCity(from: result.placemark)
                let action = UIAlertAction(title: addressAndCity, style: .default) { _ in
                    self.displayLocation(location: result.placemark.location!, title: gymName, subtitle: address)
                }
                actionSheet.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let coordinate = view.annotation?.coordinate {
            fetchInformation(for: coordinate)
        }
    }

    
    private func formatStreetAddressAndCity(from placemark: CLPlacemark) -> String {
        var addressString = ""
        if let thoroughfare = placemark.thoroughfare {
            addressString += thoroughfare + ", "
        }
        if let locality = placemark.locality {
            addressString += locality
        }
        return addressString.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
    }
    
    private func searchInMaps(using query: String, completion: @escaping ([MKMapItem]) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error) in
            if let results = response?.mapItems {
                completion(results)
            } else {
                completion([])
            }
        }
    }
    
    private func isAddressMatching(placemark: CLPlacemark?, address: String) -> Bool {
        if let placemark = placemark {
            let components = [placemark.thoroughfare, placemark.subThoroughfare, placemark.locality, placemark.subLocality, placemark.postalCode]
            for component in components {
                if let component = component, component.contains(address) {
                    return true
                }
            }
        }
        return false
    }
    
    private func displayLocation(location: CLLocation, title: String, subtitle: String) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: searchRadius, longitudinalMeters: searchRadius)
        self.mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        self.mapView.addAnnotation(annotation)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: mapView)
        let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        fetchInformation(for: tappedCoordinate)
    }
    
    @objc func handleAppleMapsTap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: mapView)
        
        let logoRegion = CGRect(x: 0, y: mapView.bounds.height - 50, width: 50, height: 50)
        
        if logoRegion.contains(locationInView) {
            if let url = URL(string: "http://maps.apple.com/") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    
    func fetchInformation(for coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) in
            if let placemark = placemarks?.first {
                var locationInfo = "Details about the location:\n"
                
                if let name = placemark.name {
                    locationInfo += "Name: \(name)\n"
                }
                if let thoroughfare = placemark.thoroughfare {
                    locationInfo += "Street: \(thoroughfare)\n"
                }
                if let locality = placemark.locality {
                    locationInfo += "City: \(locality)\n"
                }
                if let administrativeArea = placemark.administrativeArea {
                    locationInfo += "State: \(administrativeArea)\n"
                }
                if let postalCode = placemark.postalCode {
                    locationInfo += "Postal Code: \(postalCode)\n"
                }
                if let country = placemark.country {
                    locationInfo += "Country: \(country)\n"
                }
                
                let alert = UIAlertController(title: "Location Info", message: locationInfo, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Get Directions", style: .default, handler: { _ in
                    self.getDirections(to: coordinate)
                }))
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func getDirections(to coordinate: CLLocationCoordinate2D) {
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = "Selected Location"
        destinationMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    func updateUserCurrentLocation() {
        userCurrentLocation = locationManager.location
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == gymPickerView ? gyms.count : trainers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        if pickerView == gymPickerView {
            title = gyms[row]
        } else {
            let trainer = trainers[row]
            title = "\(trainer["first_name"] ?? "") \(trainer["last_name"] ?? "")"
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.darkGray
        ]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
        var title = ""
        if pickerView == gymPickerView {
            title = gyms[row]
        } else {
            let trainer = trainers[row]
            title = "\(trainer["first_name"] ?? "") \(trainer["last_name"] ?? "")"
        }
        
        label.text = title
        label.textAlignment = .center
        label.backgroundColor = UIColor.darkGray
        label.textColor = UIColor.white
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == gymPickerView {
            let selectedGym = gyms[row]
            fetchGymInfo(by: selectedGym)
        } else {
            guard !trainers.isEmpty else {
                showAlert(title: "No Trainers", message: "No trainers available at the selected gym.")
                return
            }
            let selectedTrainer = trainers[row]
            performSegue(withIdentifier: "trainerContactSegue", sender: selectedTrainer)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trainerContactSegue", let destinationVC = segue.destination as? trainerInformationController, let trainerInfo = sender as? [String: Any] {
            destinationVC.trainerInfo = trainerInfo
        }
    }
}
