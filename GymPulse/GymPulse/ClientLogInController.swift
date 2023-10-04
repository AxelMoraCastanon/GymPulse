import UIKit

class ClientLogInController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var logInButton: UIButton!
    
    let errorMessages = ["Required", "Invalid Email Address", "Password must be at least 8 characters"]
    
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
        
        emailErrorLabel.isHidden = false
        passwordErrorLabel.isHidden = false
        
        emailErrorLabel.text = "Required"
        passwordErrorLabel.text = "Required"
        
        logInButton.isEnabled = false
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if sender == emailTF {
            emailErrorLabel.text = validateEmail(sender.text ?? "")
            emailErrorLabel.isHidden = (emailErrorLabel.text == nil)
        } else if sender == passwordTF {
            passwordErrorLabel.text = validatePassword(sender.text ?? "")
            passwordErrorLabel.isHidden = (passwordErrorLabel.text == nil)
        }
        
        checkForValidForm()
    }
    
    @IBAction func logInAction(_ sender: Any) {
        // Implement the login logic here
    }
    
    func validateEmail(_ value: String) -> String? {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: value) ? nil : "Invalid Email Address"
    }
    
    func validatePassword(_ value: String) -> String? {
        if value.count < 8 { return "Password must be at least 8 characters" }
        return nil
    }
    
    func checkForValidForm() {
        let allFieldsFilled = [emailTF, passwordTF].allSatisfy { $0?.text?.isEmpty == false }
        if allFieldsFilled && emailErrorLabel.isHidden && passwordErrorLabel.isHidden {
            logInButton.isEnabled = true
        } else {
            logInButton.isEnabled = false
        }
    }
}
