import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var gymNameTF: UITextField!
    @IBOutlet weak var gymAddressTF: UITextField!
    @IBOutlet weak var verifyInfoButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    let baseURL = Bundle.main.infoDictionary?["BASE_URL"] as? String
    var isClient: Bool = true
    var clientId: Int?
    var trainerId: Int?
    var locationId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        initializeProfileState()
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    func initializeProfileState() {
        firstNameTF.text = ""
        lastNameTF.text = ""
        emailTF.text = ""
        phoneNumberTF.text = ""
        passwordTF.text = ""
        gymNameTF.text = ""
        gymAddressTF.text = ""
        
        setTextFieldEditableState(to: false)
        
        emailTF.isUserInteractionEnabled = false
        gymNameTF.isUserInteractionEnabled = false
        
        verifyInfoButton.isEnabled = false
        verifyInfoButton.alpha = 0.5
        updateButton.isEnabled = false
        updateButton.alpha = 0.5
        
        displayUserRoleAlert()
    }

    func displayUserRoleAlert() {
        let alert = UIAlertController(title: "Select Role", message: "Type an email if you are a client or an email and gym name if you are a trainer.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Client", style: .default, handler: { _ in
            self.isClient = true
            self.emailTF.isUserInteractionEnabled = true
            self.verifyInfoButton.isEnabled = true
        }))
        alert.addAction(UIAlertAction(title: "Trainer", style: .default, handler: { _ in
            self.isClient = false
            self.emailTF.isUserInteractionEnabled = true
            self.gymNameTF.isUserInteractionEnabled = true
            self.verifyInfoButton.isEnabled = true
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func verifyInfoButtonPressed(_ sender: UIButton) {
        print("verifyInfoButtonPressed started")

        if isClient {
            guard let email = emailTF.text, !email.isEmpty else {
                displayError(message: "Please enter an email.")
                return
            }
            
            let endpoint = "get_client_id.php?email=\(email)"
            fetchData(endpoint: endpoint) { response in
                if let id = response["client_id"] as? Int {
                    self.clientId = id
                    self.displayUpdateInformationAlert()
                    
                    if !(self.firstNameTF.text?.isEmpty ?? true) || !(self.lastNameTF.text?.isEmpty ?? true) || !(self.emailTF.text?.isEmpty ?? true) || !(self.phoneNumberTF.text?.isEmpty ?? true) || !(self.passwordTF.text?.isEmpty ?? true) {
                        self.updateButton.isEnabled = true
                        self.updateButton.alpha = 1.0
                    }
                } else {
                    self.displayError(message: "No client found with the provided email.")
                }
            }
        } else {
            guard let email = emailTF.text, !email.isEmpty, let gymName = gymNameTF.text, !gymName.isEmpty else {
                displayError(message: "Please enter both email and gym name.")
                return
            }
            
            let trainerEndpoint = "get_trainer_id.php?email=\(email)"
            fetchData(endpoint: trainerEndpoint) { response in
                if let id = response["trainer_id"] as? Int {
                    self.trainerId = id
                    
                    let locationEndpoint = "get_location_id.php?trainer_id=\(id)"
                    self.fetchData(endpoint: locationEndpoint) { locationResponse in
                        if let locationId = locationResponse["location_id"] as? Int {
                            self.locationId = locationId
                            self.displayUpdateInformationAlert()
                            
                            if !(self.firstNameTF.text?.isEmpty ?? true) || !(self.lastNameTF.text?.isEmpty ?? true) || !(self.emailTF.text?.isEmpty ?? true) || !(self.gymNameTF.text?.isEmpty ?? true) || !(self.gymAddressTF.text?.isEmpty ?? true) || !(self.passwordTF.text?.isEmpty ?? true) {
                                self.updateButton.isEnabled = true
                                self.updateButton.alpha = 1.0
                            }
                        } else {
                            self.displayError(message: "No location found for the provided gym name.")
                        }
                    }
                } else {
                    self.displayError(message: "No trainer found with the provided email.")
                }
            }
        }
        print("verifyInfoButtonPressed ended")
    }

    func displayUpdateInformationAlert() {
        let alert = UIAlertController(title: "Update Information", message: "You can now update your information.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.setTextFieldEditableState(to: true)
            self.updateButton.isEnabled = true
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func updateButtonPressed(_ sender: UIButton) {
        let gymName = gymNameTF.text ?? ""
        let gymAddress = gymAddressTF.text ?? ""
        let firstName = firstNameTF.text ?? ""
        let lastName = lastNameTF.text ?? ""
        let email = emailTF.text ?? ""
        let phoneNumber = phoneNumberTF.text ?? ""
        let password = passwordTF.text ?? ""
        
        if isClient {
            guard let clientId = clientId else {
                displayError(message: "Client ID not found.")
                return
            }
            
            let endpoint = "update_client.php"
            let parameters: [String: Any] = [
                "client_id": clientId,
                "first_name": firstName,
                "last_name": lastName,
                "email": email,
                "phone_number": phoneNumber,
                "password": password
            ]
            
            sendDataToAPI(endpoint: endpoint, parameters: parameters) { success in
                if success {
                    print("Client profile updated successfully.")
                } else {
                    print("Failed to update client profile.")
                }
            }
        } else {
            guard let trainerId = trainerId, let locationId = locationId else {
                displayError(message: "Trainer ID or Location ID not found.")
                return
            }
            
            let trainerEndpoint = "update_trainer.php"
            let trainerParameters: [String: Any] = [
                "trainer_id": trainerId,
                "first_name": firstName,
                "last_name": lastName,
                "email": email,
                "phone_number": phoneNumber,
                "location_id": locationId,
                "password": password
            ]
            
            sendDataToAPI(endpoint: trainerEndpoint, parameters: trainerParameters) { success in
                if success {
                    print("Trainer profile updated successfully.")
                    
                    let locationEndpoint = "update_location.php"
                    let locationParameters: [String: Any] = [
                        "location_id": locationId,
                        "gym_name": gymName,
                        "address": gymAddress
                    ]
                    
                    self.sendDataToAPI(endpoint: locationEndpoint, parameters: locationParameters) { locationSuccess in
                        if locationSuccess {
                            print("Location details updated successfully.")
                        } else {
                            print("Failed to update location details.")
                        }
                    }
                } else {
                    print("Failed to update trainer profile.")
                }
            }
        }
    }

    func setTextFieldEditableState(to state: Bool) {
        firstNameTF.isUserInteractionEnabled = state
        lastNameTF.isUserInteractionEnabled = state
        emailTF.isUserInteractionEnabled = state
        phoneNumberTF.isUserInteractionEnabled = state
        passwordTF.isUserInteractionEnabled = state
        gymNameTF.isUserInteractionEnabled = !isClient && state
        gymAddressTF.isUserInteractionEnabled = !isClient && state
    }

    func fetchAndDisplayUserDetails() {
        if isClient, let clientId = clientId {
            let endpoint = "get_client_by_id.php?client_id=\(clientId)"
            fetchData(endpoint: endpoint) { userDetails in
                self.firstNameTF.text = userDetails["first_name"] as? String
                self.lastNameTF.text = userDetails["last_name"] as? String
                self.emailTF.text = userDetails["email"] as? String
                self.phoneNumberTF.text = userDetails["phone_number"] as? String
                if let locationId = userDetails["location_id"] as? Int {
                    self.locationId = locationId
                    self.fetchAndDisplayGymDetails(locationId: locationId)
                }
            }
        } else if let trainerId = trainerId {
            let endpoint = "get_trainer_by_id.php?trainer_id=\(trainerId)"
            fetchData(endpoint: endpoint) { userDetails in
                self.firstNameTF.text = userDetails["first_name"] as? String
                self.lastNameTF.text = userDetails["last_name"] as? String
                self.emailTF.text = userDetails["email"] as? String
                self.phoneNumberTF.text = userDetails["phone_number"] as? String
                if let locationId = userDetails["location_id"] as? Int {
                    self.locationId = locationId
                    self.fetchAndDisplayGymDetails(locationId: locationId)
                }
            }
        }
    }

    func fetchAndDisplayGymDetails(locationId: Int) {
        let endpoint = "get_gym_location.php?location_id=\(locationId)"
        fetchData(endpoint: endpoint) { gymDetails in
            self.gymNameTF.text = gymDetails["gym_name"] as? String
            self.gymAddressTF.text = gymDetails["address"] as? String
        }
    }

    func updateUserProfile() {
        var endpoint = ""
        var parameters: [String: Any] = [
            "first_name": firstNameTF.text ?? "",
            "last_name": lastNameTF.text ?? "",
            "email": emailTF.text ?? "",
            "phone_number": phoneNumberTF.text ?? ""
        ]
        
        if let password = passwordTF.text, !password.isEmpty {
            parameters["password"] = password
        }
        
        if isClient, let clientId = clientId {
            endpoint = "update_client.php"
            parameters["client_id"] = clientId
        } else if let trainerId = trainerId {
            endpoint = "update_trainer.php"
            parameters["trainer_id"] = trainerId
        }
        
        sendDataToAPI(endpoint: endpoint, parameters: parameters) { success in
            if success {
                print("Profile updated successfully.")
                if !self.isClient, let locationId = self.locationId {
                    self.updateGymLocation(locationId: locationId)
                }
            } else {
                print("Failed to update profile.")
            }
        }
    }

    func updateGymLocation(locationId: Int) {
        let endpoint = "update_location.php"
        let parameters: [String: Any] = [
            "location_id": locationId,
            "gym_name": gymNameTF.text ?? "",
            "address": gymAddressTF.text ?? ""
        ]
        
        sendDataToAPI(endpoint: endpoint, parameters: parameters) { success in
            if success {
                print("Gym location updated successfully.")
            } else {
                print("Failed to update gym location.")
            }
        }
    }

    func sendDataToAPI(endpoint: String, parameters: [String: Any], completion: @escaping (Bool) -> Void) {
        
        guard let unwrappedBaseURL = baseURL,
              let url = URL(string: unwrappedBaseURL + endpoint) else {
            print("Error: Invalid URL or baseURL not found")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Sending parameters to \(endpoint): \(parameters)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print("Error encoding parameters:", error.localizedDescription)
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil, let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                if let error = error {
                    print("Network error:", error.localizedDescription)
                } else {
                    print("Error parsing response or no data received.")
                }
                completion(false)
                return
            }
            
            print("Server Response:", responseJSON)
            
            if let status = responseJSON["status"] as? String, status == "success" {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        task.resume()
    }

    func fetchData(endpoint: String, completion: @escaping ([String: Any]) -> Void) {
        print("fetchData started with endpoint: \(endpoint)")

        guard let unwrappedBaseURL = baseURL else {
            print("Error fetching baseURL")
            return
        }
        
        let url = URL(string: unwrappedBaseURL + endpoint)!

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("fetchData error or no data received for endpoint: \(endpoint)")
                return
            }
            
            DispatchQueue.main.async {
                completion(jsonObject)
            }
        }
        
        task.resume()

        print("fetchData task resumed for endpoint: \(endpoint)")
    }

    func displayError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
