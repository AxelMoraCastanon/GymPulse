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
    var clientId: Int?
    var trainerId: Int?
    var locationId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldEditableState(to: false)
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

    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
        let url = URL(string: baseURL + endpoint)!
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
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil, let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let message = responseJSON["message"] as? String else {
                completion(false)
                return
            }
            
            completion(message.contains("successfully"))
        }
        
        task.resume()
    }

    func fetchData(endpoint: String, completion: @escaping ([String: Any]) -> Void) {
        let url = URL(string: baseURL + endpoint)!
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return
            }
            
            DispatchQueue.main.async {
                completion(jsonObject)
            }
        }
        
        task.resume()
    }

    func displayError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
