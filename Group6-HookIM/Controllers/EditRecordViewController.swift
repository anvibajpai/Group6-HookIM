import UIKit

class EditRecordViewController: UIViewController {

    
    @IBOutlet weak var winsTextField: UITextField!
    
    @IBOutlet weak var lossesTextField: UITextField!
    
    var wins: Int = 0
    var losses: Int = 0
    
    // Closure to send data back
    var onSave: ((Int, Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        winsTextField.text = "\(wins)"
        lossesTextField.text = "\(losses)"
        winsTextField.keyboardType = .numberPad
        lossesTextField.keyboardType = .numberPad
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let newWins = Int(winsTextField.text ?? "") ?? wins
        let newLosses = Int(lossesTextField.text ?? "") ?? losses

        // Send data back through closure
        onSave?(newWins, newLosses)

        // Pop back to previous screen
        navigationController?.popViewController(animated: true)
    }
}
