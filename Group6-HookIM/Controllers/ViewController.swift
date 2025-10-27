//
//  LoginViewController.swift
//  Hook IM'
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit

/// View controller responsible for user login.
/// Handles email/password input, validation, and navigation to dashboard or account creation.
class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Fake user for testing purposes.
    let fakeUser = User(
        firstName: "Fake",
        lastName: "User",
        gender: "Other",
        email: "fake@utexas.edu",
        password: "pw",
        profileImageData: nil,
        interestedSports: ["Soccer", "Basketball"],
        division: "Womens",
        isFreeAgent: true
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save the fake user for testing
        UserManager.shared.save(fakeUser)
        
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
            showAlert(title: "Missing Info", message: "Please enter email and password.")
            return
        }
            
        if email == fakeUser.email && pw == fakeUser.password {
            performSegue(withIdentifier: "loginSegue", sender: fakeUser)
            print("login good")
        } else {
            showAlert(title: "Invalid Credentials", message: "No matching user found. Try creating an account.")
        }
    }
    
    /// Triggered when the Sign Up button is tapped,  Navigates to the Create Account screen.
    @IBAction func signUpTapped(_ sender: Any) {
        performSegue(withIdentifier: "createAccountSegue", sender: nil)
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
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .gray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        textField.rightView = toggleButton
        textField.rightViewMode = .always
    }
    
    /// Prepares data before navigating to another view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue",
           let destinationVC = segue.destination as? DashboardViewController,
           let user = sender as? User {
            destinationVC.user = user
        }
    }
}
