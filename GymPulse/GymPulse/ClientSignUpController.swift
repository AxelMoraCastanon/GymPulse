import UIKit

class ClientSignUpController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    let baseURL = "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/"
    
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
        
        for textField in textFields {
            textField?.text = ""
        }
                
        signUpButton.isEnabled = false
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        checkForValidForm()
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        let clientData: [String: Any] = [
            "first_name": firstNameTF.text!,
            "last_name": lastNameTF.text!,
            "email": emailTF.text!,
            "phone_number": phoneNumberTF.text!,
            "password": passwordTF.text!
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: clientData)
        
        let url = URL(string: baseURL + "add_client.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            if let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(response)
            }
        }
        
        task.resume()
        
        resetForm()
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
        let allFieldsFilled = [firstNameTF, lastNameTF, emailTF, phoneNumberTF, passwordTF].allSatisfy { $0?.text?.isEmpty == false }
        if allFieldsFilled {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
        }
    }
}
