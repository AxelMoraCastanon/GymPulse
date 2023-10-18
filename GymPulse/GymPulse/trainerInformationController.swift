import UIKit

class trainerInformationController: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    
    private let baseURL = "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/"
    
    var trainerInfo: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        populateTrainerInfo()
    }

    private func setupTextFields() {
        firstNameTF.isUserInteractionEnabled = false
        lastNameTF.isUserInteractionEnabled = false
        emailTF.isUserInteractionEnabled = false
        phoneNumberTF.isUserInteractionEnabled = false
    }

    private func populateTrainerInfo() {
        if let firstName = trainerInfo["first_name"] as? String {
            firstNameTF.text = firstName
        } else {
            handleMissingInfoError(key: "first_name")
        }
        
        if let lastName = trainerInfo["last_name"] as? String {
            lastNameTF.text = lastName
        } else {
            handleMissingInfoError(key: "last_name")
        }
        
        if let email = trainerInfo["email"] as? String {
            emailTF.text = email
        } else {
            handleMissingInfoError(key: "email")
        }
        
        if let phoneNumber = trainerInfo["phone_number"] as? String {
            phoneNumberTF.text = phoneNumber
        } else {
            handleMissingInfoError(key: "phone_number")
        }
    }

    private func handleMissingInfoError(key: String) {
        print("Error: \(key) not found in trainerInfo.")
        showAlert(title: "Error", message: "Missing information for \(key). Please contact support.")
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
