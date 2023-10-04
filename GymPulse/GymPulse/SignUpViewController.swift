//
//  SignUpViewController.swift
//  GymPulse
//
//  Created by Axel Mora on 10/3/23.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var ClientSegmentView: UIView!
    
    @IBOutlet weak var TrainerSegmentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.bringSubviewToFront(ClientSegmentView)
    }

    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            self.view.bringSubviewToFront(ClientSegmentView)
        case 1:
            self.view.bringSubviewToFront(TrainerSegmentView)
        default:
            break
        }
    }
    
    
    
}

