
//
//  CreateAccountViewController.swift
//  Hook IM'
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

/// View controller responsible for creating a new account.
/// Handles input of user information: name, gender, email, and password.
class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Gender options to display on menu and the selected gender
    let genders = ["Male", "Female", "Other"]
    var selectedGender: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Hook 'IM"
        
        // Set up password visibility and toggle
        setupPasswordToggle(for: passwordTextField)
        
        // Set-up gender selection menu
        let actions = genders.map { gender in
           UIAction(title: gender) { _ in
               self.selectedGender = gender
               self.genderButton.setTitle(gender, for: .normal)
           }
       }
       
       // Attach menu to the gender pull down button
       genderButton.menu = UIMenu(title: "Select Gender", children: actions)
       genderButton.showsMenuAsPrimaryAction = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.isSecureTextEntry = true
    }
    
    /// Triggered when the "Next" button is tapped.
    /// Validates input, ensures email is UT-associated, and passes partial user to next screen.
    @IBAction func nextButtonTapped(_ sender: Any) {
        // ensure all fields are filled
        guard
            let first = firstName.text, !first.isEmpty,
            let last = lastName.text, !last.isEmpty,
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty,
            let gender = selectedGender
        else {
            showAlert(title: "Missing Fields", message: "Please complete all fields.")
            return
        }
        
        // email has to be UT associated
        let validDomains = ["utexas.edu", "my.utexas.edu"]
        let emailDomain = email.split(separator: "@").last?.lowercased() ?? ""
        
        guard validDomains.contains(where: { emailDomain == $0 }) else {
            showAlert(title: "Invalid Email", message: "Please use your UTexas email address (e.g., name@utexas.edu).")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Signup failed: ", message: "\(error.localizedDescription)")
                return
            }
            guard let uid = authResult?.user.uid else { return }
            
            let partialUserData: [String: Any] = [
                "uid": uid,
                "firstName": first,
                "lastName": last,
                "email": email,
                "gender": gender,
                "password": password //might not want to store plaintext locally
            ]
            UserDefaults.standard.set(partialUserData, forKey: "partialUserData")
    
            self.performSegue(withIdentifier: "uploadImageSegue", sender: nil)
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
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .gray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        textField.rightView = toggleButton
        textField.rightViewMode = .always
    }
}
