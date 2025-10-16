//
//  LoginViewController.swift
//  Hook IM'
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit

class ViewController: UIViewController {
    // Hook these up in IB
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded")
        emailTextField.text = ""
        passwordTextField.text = ""
    }

    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
        let pw = passwordTextField.text, !pw.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter email and password.")
            return
        }
            
        if email == "fake@utexas.edu" && pw == "pw" {
                //add segue to Dashboard,add prepare function to pass user credentials
                print("login good")
            } else {
                showAlert(title: "Invalid Credentials", message: "No matching user found. Try creating an account.")
            }
    }
    
    
    @IBAction func signUpTapped(_ sender: Any) {
        performSegue(withIdentifier: "createAccountSegue", sender: nil)
    }
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        present(controller, animated: true)
    }
}
