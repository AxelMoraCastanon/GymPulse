//
//  trainerInformationController.swift
//  GymPulse
//
//  Created by Axel Mora on 10/10/23.
//

import UIKit

class trainerInformationController: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!

    var trainerInfo: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        populateTrainerInfo()
        // Ensure the user cannot edit the text fields
        firstNameTF.isUserInteractionEnabled = false
        lastNameTF.isUserInteractionEnabled = false
        emailTF.isUserInteractionEnabled = false
        phoneNumberTF.isUserInteractionEnabled = false
    }

    func populateTrainerInfo() {
        firstNameTF.text = trainerInfo["first_name"] as? String
        lastNameTF.text = trainerInfo["last_name"] as? String
        emailTF.text = trainerInfo["email"] as? String
        phoneNumberTF.text = trainerInfo["phone_number"] as? String
    }
}
