import UIKit

class ClientSignUpController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var phoneNumberErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    let baseURL = "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/"
    
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
        let textFields = [firstNameTF, lastNameTF, emailTF, phoneNumberTF, passwordTF]
        let errorLabels = [firstNameErrorLabel, lastNameErrorLabel, emailErrorLabel, phoneNumberErrorLabel, passwordErrorLabel]
        
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
        // Prepare the data to be sent
        let clientData: [String: Any] = [
            "first_name": firstNameTF.text!,
            "last_name": lastNameTF.text!,
            "email": emailTF.text!,
            "phone_number": phoneNumberTF.text!,
            "password": passwordTF.text!
        ]
        
        // Convert the data to JSON
        let jsonData = try? JSONSerialization.data(withJSONObject: clientData)
        
        // Create the URL and request
        let url = URL(string: baseURL + "add_client.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error:", error ?? "Unknown error")
                return
            }
            
            // Handle the response (you can update the UI or show a message)
            if let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(response)
            }
        }
        
        task.resume()
        
        resetForm()
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
        let allFieldsFilled = [firstNameTF, lastNameTF, emailTF, phoneNumberTF, passwordTF].allSatisfy { $0?.text?.isEmpty == false }
        if allFieldsFilled && emailErrorLabel.isHidden && passwordErrorLabel.isHidden {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
        }
    }
}
