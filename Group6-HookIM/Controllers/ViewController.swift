//
//  LoginViewController.swift
//  Hook IM'
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

/// View controller responsible for user login.
/// Handles email/password input, validation, and navigation to dashboard or account creation.
class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPasswordToggle(for: passwordTextField)
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar for login screen
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restore nav bar
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    /// Triggered when the login button is tapped.
    /// Validates user input and logs in if credentials match.
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let pw = passwordTextField.text, !pw.isEmpty else {
            self.showAlert(title: "Missing Info", message: "Please enter email and password.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: pw) { authResult, error in
            if let error = error {
                self.showAlert(title: "Invalid Credentials", message: "No matching user found. Try creating an account.")
                return
            }

            guard let uid = authResult?.user.uid else { return }

            Firestore.firestore().collection("users").document(uid).getDocument { snapshot, err in
                if let err = err {
                    self.showAlert(title: "Error fetching user: ", message: "\(err.localizedDescription)")
                    return
                }
                if let data = snapshot?.data(), let user = User(from: data) {
                    print("Welcome back, \(user.firstName)!")
                    // Move to dashboard
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
        }
        
    }
    
    /// Displays an alert with a title, message, and optional additional actions.
    func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        present(controller, animated: true)
    }
    
    /// Toggles the visibility of the password field.
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        guard let textField = sender.superview as? UITextField ?? sender.superview?.superview as? UITextField else { return }
        textField.isSecureTextEntry.toggle()
        let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    /// Sets up a password visibility toggle button for a given text field.
    func setupPasswordToggle(for textField: UITextField) {
        textField.isSecureTextEntry = true
        
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .gray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        textField.rightView = toggleButton
        textField.rightViewMode = .always
    }
}
