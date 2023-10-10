//
//  ContactViewController.swift
//  GymPulse
//
//  Created by Axel Mora on 10/9/23.
//

import UIKit
import MapKit
import CoreLocation

class ContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var selectGymButton: UIButton!
    @IBOutlet weak var gymPickerView: UIPickerView!
    @IBOutlet weak var gymAddressLabel: UILabel!
    @IBOutlet weak var gymAddressTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewTrainersButton: UIButton!
    @IBOutlet weak var trainerPickerView: UIPickerView!
    
    private let baseURL = "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/"
    
    private var gyms: [String] = []
    private var selectedGymInfo: [String: Any] = [:]
    private var trainers: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchGymNames()
    }

    private func setupUI() {
        gymPickerView.delegate = self
        gymPickerView.dataSource = self
        gymAddressTextField.isUserInteractionEnabled = false
    }

    @IBAction func selectGymPressed(_ sender: UIButton) {
        fetchGymNames()
    }

    @IBAction func viewTrainersPressed(_ sender: UIButton) {
        if let locationId = selectedGymInfo["location_id"] as? Int {
            fetchTrainers(by: locationId)
        } else {
            showAlert(title: "Error", message: "Location ID not found.")
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
            // Add code to handle trainer selection and perform segue
            performSegue(withIdentifier: "trainerContactSegue", sender: selectedTrainer)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trainerContactSegue", let destinationVC = segue.destination as? trainerInformationController, let trainerInfo = sender as? [String: Any] {
            destinationVC.trainerInfo = trainerInfo
        }
    }
}
