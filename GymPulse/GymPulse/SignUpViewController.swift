import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var ClientSegmentView: UIView!
    
    @IBOutlet weak var TrainerSegmentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
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
