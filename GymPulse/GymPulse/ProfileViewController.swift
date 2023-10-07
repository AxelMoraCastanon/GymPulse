import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var gymNameTF: UITextField!
    @IBOutlet weak var gymAddressTF: UITextField!
    
    let baseURL = "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/"
    var isClient: Bool = true
    var userId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially, text fields are not editable
        setTextFieldEditableState(to: false)
        
        // Fetch and display user details
        fetchAndDisplayUserDetails()
    }

    @IBAction func updateButtonPressed(_ sender: UIButton) {
        setTextFieldEditableState(to: true)
        
        let alert = UIAlertController(title: "Update Profile", message: "Do you want to update your profile?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.updateUserProfile()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func setTextFieldEditableState(to state: Bool) {
        firstNameTF.isUserInteractionEnabled = state
        lastNameTF.isUserInteractionEnabled = state
        emailTF.isUserInteractionEnabled = state
        phoneNumberTF.isUserInteractionEnabled = state
        passwordTF.isUserInteractionEnabled = state
        if isClient {
            gymNameTF.isUserInteractionEnabled = false
            gymAddressTF.isUserInteractionEnabled = false
        } else {
            gymNameTF.isUserInteractionEnabled = state
            gymAddressTF.isUserInteractionEnabled = state
        }
    }

    func fetchAndDisplayUserDetails() {
        guard let userId = userId else { return }
        let endpoint = isClient ? "get_client_by_id.php?client_id=\(userId)" : "get_trainer_by_id.php?trainer_id=\(userId)"
        let url = URL(string: baseURL + endpoint)!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching user details:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let userDetails = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                DispatchQueue.main.async {
                    self.firstNameTF.text = userDetails["first_name"] as? String
                    self.lastNameTF.text = userDetails["last_name"] as? String
                    self.emailTF.text = userDetails["email"] as? String
                    self.phoneNumberTF.text = userDetails["phone_number"] as? String
                    if !self.isClient {
                        // Fetch gym details if it's a trainer
                        if let locationId = userDetails["location_id"] as? Int {
                            self.fetchAndDisplayGymDetails(locationId: locationId)
                        }
                    }
                }
            }
        }
        
        task.resume()
    }

    func fetchAndDisplayGymDetails(locationId: Int) {
        let endpoint = "get_gym_location.php?location_id=\(locationId)"
        let url = URL(string: baseURL + endpoint)!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching gym details:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let gymDetails = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                DispatchQueue.main.async {
                    self.gymNameTF.text = gymDetails["gym_name"] as? String
                    self.gymAddressTF.text = gymDetails["address"] as? String
                }
            }
        }
        
        task.resume()
    }

    func updateUserProfile() {
        guard let userId = userId else {
            print("User ID not found.")
            return
        }
        
        var endpoint = ""
        var parameters: [String: Any] = [
            "first_name": firstNameTF.text ?? "",
            "last_name": lastNameTF.text ?? "",
            "email": emailTF.text ?? "",
            "phone_number": phoneNumberTF.text ?? ""
        ]
        
        if isClient {
            endpoint = "update_client.php"
            parameters["client_id"] = userId
        } else {
            endpoint = "update_trainer.php"
            parameters["trainer_id"] = userId
            
            // Fetch the location_id for the trainer
            let trainerDetailsEndpoint = "get_trainer_by_id.php?trainer_id=\(userId)"
            let trainerDetailsURL = URL(string: baseURL + trainerDetailsEndpoint)!
            
            let task = URLSession.shared.dataTask(with: trainerDetailsURL) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching trainer details:", error?.localizedDescription ?? "Unknown error")
                    return
                }
                
                if let trainerDetails = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let locationId = trainerDetails["location_id"] as? Int {
                    parameters["location_id"] = locationId
                    
                    // Now send the data to the API
                    self.sendDataToAPI(endpoint: endpoint, parameters: parameters) { success in
                        if success {
                            print("Profile updated successfully.")
                            self.updateGymLocation()
                        } else {
                            print("Failed to update profile.")
                        }
                    }
                }
            }
            
            task.resume()
            return
        }
        
        // If it's a client, directly send the data to the API
        sendDataToAPI(endpoint: endpoint, parameters: parameters) { success in
            if success {
                print("Profile updated successfully.")
                if !self.isClient {
                    self.updateGymLocation()
                }
            } else {
                print("Failed to update profile.")
            }
        }

        func updateGymLocation() {
            guard let userId = userId else {
                print("User ID not found.")
                return
            }
            
            // Fetch the location_id for the trainer
            let trainerDetailsEndpoint = "get_trainer_by_id.php?trainer_id=\(userId)"
            let trainerDetailsURL = URL(string: baseURL + trainerDetailsEndpoint)!
            
            let task = URLSession.shared.dataTask(with: trainerDetailsURL) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching trainer details:", error?.localizedDescription ?? "Unknown error")
                    return
                }
                
                if let trainerDetails = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let locationId = trainerDetails["location_id"] as? Int {
                    
                    let endpoint = "update_location.php"
                    let parameters: [String: Any] = [
                        "location_id": locationId,
                        "gym_name": self.gymNameTF.text ?? "",
                        "address": self.gymAddressTF.text ?? ""
                    ]
                    
                    self.sendDataToAPI(endpoint: endpoint, parameters: parameters) { success in
                        if success {
                            print("Gym location updated successfully.")
                        } else {
                            print("Failed to update gym location.")
                        }
                    }
                }
            }
            
            task.resume()
        }

    func sendDataToAPI(endpoint: String, parameters: [String: Any], completion: @escaping (Bool) -> Void) {
        let url = URL(string: "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/\(endpoint)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            print("Error encoding parameters:", error.localizedDescription)
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error sending data to API:", error?.localizedDescription ?? "Unknown error")
                completion(false)
                return
            }
            
            if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = responseJSON["message"] as? String {
                print("API Response:", message)
                completion(message.contains("successfully"))
            } else {
                completion(false)
            }
        }
        
        task.resume()
    }

        func updatePassword() {
            guard let userId = userId else {
                print("User ID not found.")
                return
            }
            
            var endpoint = ""
            var parameters: [String: Any] = [
                "password": passwordTF.text ?? ""
            ]
            
            if isClient {
                endpoint = "update_client_password.php"
                parameters["client_id"] = userId
            } else {
                endpoint = "update_trainer_password.php"
                parameters["trainer_id"] = userId
            }
            
            sendDataToAPI(endpoint: endpoint, parameters: parameters) { success in
                if success {
                    print("Password updated successfully.")
                } else {
                    print("Failed to update password.")
                }
            }
        }

    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        // Handle logout logic here
        // For example, navigate back to the login screen or clear user session data
    }

    @IBAction func switchRoleButtonPressed(_ sender: UIButton) {
        // Handle switching user roles (from client to trainer or vice versa)
        isClient.toggle()
        fetchAndDisplayUserDetails()
    }

    func displayError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
