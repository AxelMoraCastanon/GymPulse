//
//  ContactViewController.swift
//  GymPulse
//
//  Created by Axel Mora on 10/9/23.
//

import UIKit
import MapKit

class ContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var selectGymButton: UIButton!
    @IBOutlet weak var gymPickerView: UIPickerView!
    @IBOutlet weak var gymAddressLabel: UILabel!
    @IBOutlet weak var gymAddressTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewTrainersButton: UIButton!
    @IBOutlet weak var trainerPickerView: UIPickerView!

    var gyms: [String] = []
    var selectedGymInfo: [String: Any] = [:]
    var trainers: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        gymPickerView.delegate = self
        gymPickerView.dataSource = self
        gymAddressTextField.isUserInteractionEnabled = false // Ensure the user cannot edit the text field
        fetchGymNames()
    }

    @IBAction func selectGymPressed(_ sender: UIButton) {
        fetchGymNames()
    }

    @IBAction func viewTrainersPressed(_ sender: UIButton) {
        if let locationId = selectedGymInfo["location_id"] as? Int {
            fetchTrainers(by: locationId)
        }
    }

    func fetchGymNames() {
        let url = URL(string: baseURL + "get_all_gym_names.php")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let gymNames = try? JSONDecoder().decode([String].self, from: data) {
                DispatchQueue.main.async {
                    self.gyms = gymNames
                    self.gymPickerView.reloadAllComponents()
                }
            }
        }.resume()
    }

    func fetchGymInfo(by name: String) {
        let url = URL(string: baseURL + "get_gym_info_by_gym_name.php?gym_name=\(name)")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let gymInfo = try? JSONDecoder().decode([String: Any].self, from: data) {
                DispatchQueue.main.async {
                    self.selectedGymInfo = gymInfo
                    self.gymAddressTextField.text = gymInfo["address"] as? String
                    // Add code to update the MKMapView with the gym's address
                }
            }
        }.resume()
    }

    func fetchTrainers(by locationId: Int) {
        let url = URL(string: baseURL + "get_trainer_by_location_id.php?location_id=\(locationId)")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let trainersInfo = try? JSONDecoder().decode([[String: Any]].self, from: data) {
                DispatchQueue.main.async {
                    self.trainers = trainersInfo
                    self.trainerPickerView.reloadAllComponents()
                }
            }
        }.resume()
    }

    // UIPickerView DataSource and Delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == gymPickerView {
            return gyms.count
        } else {
            return trainers.count
        }
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
