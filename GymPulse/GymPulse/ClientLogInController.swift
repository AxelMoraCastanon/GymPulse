// ClientLogInController.swift
import UIKit

class ClientLogInController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    
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
        emailTF.text = ""
        passwordTF.text = ""
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        logInButton.isEnabled = false
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if sender == emailTF {
            emailErrorLabel.text = validateEmail(sender.text ?? "")
        } else if sender == passwordTF {
            passwordErrorLabel.isHidden = sender.text?.isEmpty ?? true
        }
        
        emailErrorLabel.isHidden = (emailErrorLabel.text == nil)
        passwordErrorLabel.isHidden = (passwordErrorLabel.text == nil)
        
        checkForValidForm()
    }
    
    @IBAction func logInAction(_ sender: Any) {
        let clientData: [String: Any] = [
            "email": emailTF.text!,
            "password": passwordTF.text!
        ]
        
        sendDataToAPI(data: clientData, endpoint: "login_client.php") { response in
            if let status = response["status"] as? String, status == "success" {
                // Handle successful login
                print("Login successful!")
                if let user = response["user"] as? [String: Any] {
                    print("Logged in user:", user)
                }
            } else {
                // Handle error
                print("Login failed:", response["message"] ?? "Unknown error")
            }
        }
    }
    
    func validateEmail(_ value: String) -> String? {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: value) ? nil : "Invalid Email Address"
    }
    
    func checkForValidForm() {
        let allFieldsFilled = [emailTF, passwordTF].allSatisfy { $0?.text?.isEmpty == false }
        if allFieldsFilled && emailErrorLabel.isHidden {
            logInButton.isEnabled = true
        } else {
            logInButton.isEnabled = false
        }
    }
    
    func sendDataToAPI(data: [String: Any], endpoint: String, completion: (([String: Any]) -> Void)? = nil) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            print("Error serializing data into JSON")
            return
        }
        
        let url = URL(string: baseURL + endpoint)!
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
                DispatchQueue.main.async {
                    completion?(response)
                }
            }
        }
        
        task.resume()
    }
}