import UIKit
import MapKit
import CoreLocation

class ContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var selectGymButton: UIButton!
    @IBOutlet weak var gymPickerView: UIPickerView!
    @IBOutlet weak var gymAddressLabel: UILabel!
    @IBOutlet weak var gymAddressTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewTrainersButton: UIButton!
    @IBOutlet weak var trainerPickerView: UIPickerView!
    
    // MARK: - Constants
    private let baseURL = "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/"
    
    // MARK: - Variables
    private var gyms: [String] = []
    private var selectedGymInfo: [String: Any] = [:]
    private var trainers: [[String: Any]] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchGymNames()
        
        // Add tap gesture recognizer to the map view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        gymPickerView.delegate = self
        gymPickerView.dataSource = self
        gymAddressTextField.isUserInteractionEnabled = false
    }

    // MARK: - Actions
    @IBAction func selectGymPressed(_ sender: UIButton) {
        fetchGymNames()
    }

    @IBAction func viewTrainersPressed(_ sender: UIButton) {
        if let locationId = selectedGymInfo["location_id"] as? Int {
            fetchTrainers(by: locationId)
        } else {
            showAlert(title: "Error", message: "Unable to fetch trainers for the selected gym.")
        }
    }

    // MARK: - Networking
    private func fetchGymNames() {
        let url = URL(string: baseURL + "get_all_gym_names.php")!
        fetchData(from: url) { (data: [String]?) in
            self.gyms = data ?? []
            self.gymPickerView.reloadAllComponents()
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
            }
        }
    }

    private func fetchTrainers(by locationId: Int) {
        let url = URL(string: baseURL + "get_trainer_by_location_id.php?location_id=\(locationId)")!
        fetchData(from: url) { (data: [[String: Any]]?) in
            self.trainers = data ?? []
            self.trainerPickerView.reloadAllComponents()
        }
    }

    private func fetchData<T>(from url: URL, completion: @escaping (T?) -> Void) where T: Any {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to fetch data. Please try again.")
                }
                return
            }
            
            guard let data = data else {
                print("No data received.")
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
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    // MARK: - UI Helpers
    private func updateMapView(with address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("Error geocoding address: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                self.mapView.setRegion(region, animated: true)
                
                // Add a pin to the map
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                annotation.title = self.selectedGymInfo["gym_name"] as? String
                annotation.subtitle = address
                self.mapView.addAnnotation(annotation)
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    // MARK: - Gesture Handlers
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: mapView)
        let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        // Fetch more information about the tapped location
        fetchInformation(for: tappedCoordinate)
    }

    func fetchInformation(for coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) in
            if let error = error {
                print("Error fetching location info: \(error.localizedDescription)")
                return
            }
            
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

    
    
    // MARK: - UIPickerView DataSource and Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == gymPickerView ? gyms.count : trainers.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == gymPickerView {
            return gyms[row]
        } else {
            let trainer = trainers[row]
            return "\(trainer["first_name"] ?? "") \(trainer["last_name"] ?? "")"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == gymPickerView {
            let selectedGym = gyms[row]
            fetchGymInfo(by: selectedGym)
        } else {
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
