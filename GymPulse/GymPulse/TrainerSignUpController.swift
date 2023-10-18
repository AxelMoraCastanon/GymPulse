import UIKit

class TrainerSignUpController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var gymNameTF: UITextField!
    @IBOutlet weak var gymAddressTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
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
        let textFields = [firstNameTF, lastNameTF, emailTF, phoneNumberTF, gymNameTF, gymAddressTF, passwordTF]
        
        for textField in textFields {
            textField?.text = ""
        }
        
        signUpButton.isEnabled = false
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        checkForValidForm()
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        DispatchQueue.main.async {
            let firstName = self.firstNameTF.text ?? ""
            let lastName = self.lastNameTF.text ?? ""
            let email = self.emailTF.text ?? ""
            let phoneNumber = self.phoneNumberTF.text ?? ""
            let gymName = self.gymNameTF.text ?? ""
            let gymAddress = self.gymAddressTF.text ?? ""
            let password = self.passwordTF.text ?? ""

            self.checkLocationAndAddIfNecessary { locationId in
                guard let locationId = locationId else {
                    return
                }
                
                let trainerData: [String: Any] = [
                    "first_name": firstName,
                    "last_name": lastName,
                    "email": email,
                    "phone_number": phoneNumber,
                    "location_id": locationId,
                    "password": password
                ]
                
                self.sendDataToAPI(data: trainerData, endpoint: "add_trainer.php") { response in
                    self.resetForm()
                }
            }
        }
    }

    func checkLocationAndAddIfNecessary(completion: @escaping (Int?) -> Void) {
        DispatchQueue.main.async {
            let gymName = self.gymNameTF.text ?? ""
            let gymAddress = self.gymAddressTF.text ?? ""
            
            let locationData: [String: Any] = [
                "gym_name": gymName,
                "address": gymAddress
            ]
            
            self.sendDataToAPI(data: locationData, endpoint: "add_location.php") { response in
                if let locationIdString = response["location_id"] as? String,
                   let locationId = Int(locationIdString) {
                    completion(locationId)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func sendDataToAPI(data: [String: Any], endpoint: String, completion: (([String: Any]) -> Void)? = nil) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            return
        }
        
        let url = URL(string: "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            if let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                DispatchQueue.main.async {
                    completion?(response)
                }
            }
        }
        
        task.resume()
    }

    func validateEmail(_ value: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: value)
    }
    
    func validatePassword(_ value: String) -> Bool {
        if value.count < 8 { return false }
        if !containsDigit(value) { return false }
        if !containsLowerCase(value) { return false }
        if !containsUpperCase(value) { return false }
        return true
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
        let allFieldsFilled = [firstNameTF, lastNameTF, emailTF, phoneNumberTF, gymNameTF, gymAddressTF, passwordTF].allSatisfy { $0?.text?.isEmpty == false }
        if allFieldsFilled && validateEmail(emailTF.text ?? "") && validatePassword(passwordTF.text ?? "") {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
        }
    }
}
