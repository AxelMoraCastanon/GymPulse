import UIKit

class TrainerSignUpController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var gymNameTF: UITextField!
    @IBOutlet weak var gymAddressTF: UITextField!  // Added this line
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var phoneNumberErrorLabel: UILabel!
    @IBOutlet weak var gymNameErrorLabel: UILabel!
    @IBOutlet weak var gymAddressErrorLabel: UILabel!  // Added this line
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    let errorMessages = ["Required", "Invalid Email Address", "Password must be at least 8 characters", "Password must contain at least 1 digit", "Password must contain at least 1 lowercase character", "Password must contain at least 1 uppercase character"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        resetForm()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func resetForm() {
        let textFields = [firstNameTF, lastNameTF, emailTF, phoneNumberTF, gymNameTF, gymAddressTF, passwordTF] // Added gymAddressTF
        let errorLabels = [firstNameErrorLabel, lastNameErrorLabel, emailErrorLabel, phoneNumberErrorLabel, gymNameErrorLabel, gymAddressErrorLabel, passwordErrorLabel] // Added gymAddressErrorLabel
        
        for textField in textFields {
            textField?.text = ""
        }
        
        for errorLabel in errorLabels {
            errorLabel?.isHidden = false
            errorLabel?.text = "Required"
        }
        
        signUpButton.isEnabled = false
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        let fieldToErrorLabelMap: [UITextField: UILabel] = [
            firstNameTF: firstNameErrorLabel,
            lastNameTF: lastNameErrorLabel,
            emailTF: emailErrorLabel,
            phoneNumberTF: phoneNumberErrorLabel,
            gymNameTF: gymNameErrorLabel,
            gymAddressTF: gymAddressErrorLabel,  // Added this line
            passwordTF: passwordErrorLabel
        ]
        
        if let errorLabel = fieldToErrorLabelMap[sender] {
            if sender == emailTF {
                errorLabel.text = validateEmail(sender.text ?? "")
            } else if sender == passwordTF {
                errorLabel.text = validatePassword(sender.text ?? "")
            } else {
                errorLabel.isHidden = !(sender.text?.isEmpty ?? true)
            }
            
            errorLabel.isHidden = (errorLabel.text == nil)
        }
        checkForValidForm()
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        // Access UI elements on the main thread
        DispatchQueue.main.async {
            // Extract data from UI
            let firstName = self.firstNameTF.text ?? ""
            let lastName = self.lastNameTF.text ?? ""
            let email = self.emailTF.text ?? ""
            let phoneNumber = self.phoneNumberTF.text ?? ""
            let gymName = self.gymNameTF.text ?? ""
            let gymAddress = self.gymAddressTF.text ?? ""
            let password = self.passwordTF.text ?? ""

            // Print data extracted from UI
            print("First Name: \(firstName)")
            print("Last Name: \(lastName)")
            print("Email: \(email)")
            print("Phone Number: \(phoneNumber)")
            print("Gym Name: \(gymName)")
            print("Gym Address: \(gymAddress)")
            print("Password: \(password)")

            // First, check if the location exists
            self.checkLocationAndAddIfNecessary { locationId in
                guard let locationId = locationId else {
                    print("Error: Unable to get location ID")
                    return
                }
                
                // Prepare the data to be sent for trainer
                let trainerData: [String: Any] = [
                    "first_name": firstName,
                    "last_name": lastName,
                    "email": email,
                    "phone_number": phoneNumber,
                    "location_id": locationId,
                    "password": password
                ]
                
                // Send the trainer data to the API
                self.sendDataToAPI(data: trainerData, endpoint: "add_trainer.php") { response in
                    // Once the trainer data has been sent and we've received a response, reset the form
                    self.resetForm()
                }
            }
        }
    }

    func checkLocationAndAddIfNecessary(completion: @escaping (Int?) -> Void) {
        DispatchQueue.main.async {
            // Extract data directly from UI
            let gymName = self.gymNameTF.text ?? ""
            let gymAddress = self.gymAddressTF.text ?? ""
            
            print("Directly from TextField - Gym Name: \(gymName)")
            print("Directly from TextField - Gym Address: \(gymAddress)")

            let locationData: [String: Any] = [
                "gym_name": gymName,
                "address": gymAddress
            ]
            
            self.sendDataToAPI(data: locationData, endpoint: "add_location.php") { response in
                print("API Response: \(response)")
                
                if let locationIdString = response["location_id"] as? String,
                   let locationId = Int(locationIdString) {
                    print("Successfully retrieved location ID: \(locationId)")
                    completion(locationId)
                } else {
                    print("Error: \(response["message"] ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }

    func sendDataToAPI(data: [String: Any], endpoint: String, completion: (([String: Any]) -> Void)? = nil) {
        // Attempt to serialize the data into JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            print("Error serializing data into JSON")
            return
        }
        
        // Print serialized JSON data
        print("Sending JSON Data: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")
        
        let url = URL(string: "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error sending data to API:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(response)
                DispatchQueue.main.async {  // Ensure the completion handler is called on the main thread
                    completion?(response)
                }
            }
        }
        
        task.resume()
    }

    
    func validateEmail(_ value: String) -> String? {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: value) ? nil : "Invalid Email Address"
    }
    
    func validatePassword(_ value: String) -> String? {
        if value.count < 8 { return "Password must be at least 8 characters" }
        if !containsDigit(value) { return "Password must contain at least 1 digit" }
        if !containsLowerCase(value) { return "Password must contain at least 1 lowercase character" }
        if !containsUpperCase(value) { return "Password must contain at least 1 uppercase character" }
        return nil
    }
    
    func containsDigit(_ value: String) -> Bool {
        return value.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }
    
    func containsLowerCase(_ value: String) -> Bool {
        return value.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
    }
    
    func containsUpperCase(_ value: String) -> Bool {
        return value.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }
    
    func checkForValidForm() {
        let allFieldsFilled = [firstNameTF, lastNameTF, emailTF, phoneNumberTF, gymNameTF, gymAddressTF, passwordTF].allSatisfy { $0?.text?.isEmpty == false } // Added gymAddressTF
        if allFieldsFilled && emailErrorLabel.isHidden && passwordErrorLabel.isHidden {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
        }
    }
}
