
//
//  CreateAccountViewController.swift
//  Hook IM'
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit

class CreateAccountViewController: UIViewController {
    // Hook IBOutlets
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let genders = ["Male", "Female", "Other"]
    var selectedGender: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Hook 'IM"
        setupPasswordToggle(for: passwordTextField)
        let actions = genders.map { gender in
           UIAction(title: gender) { _ in
               self.selectedGender = gender
               self.genderButton.setTitle(gender, for: .normal)
           }
       }
       
       // Attach menu to the button
       genderButton.menu = UIMenu(title: "Select Gender", children: actions)
       genderButton.showsMenuAsPrimaryAction = true
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        print("next")
        guard let first = firstName.text, !first.isEmpty,
              let last = lastName.text, !last.isEmpty,
              let gender = selectedGender,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Missing Fields", message: "Please complete all fields.")
            return
        }
        
        // email has to be ut associated
        let validDomains = ["utexas.edu", "my.utexas.edu"]
        let emailDomain = email.split(separator: "@").last?.lowercased() ?? ""
        
        guard validDomains.contains(where: { emailDomain == $0 }) else {
            showAlert(title: "Invalid Email", message: "Please use your UTexas email address (e.g., name@utexas.edu).")
            return
        }
        
        // Save a partial user to pass to next screen
        let user = User(firstName: first,
                        lastName: last,
                        gender: gender,
                        email: email,
                        password: password,
                        profileImageData: nil,
                        interestedSports: [],
                        division: nil,
                        isFreeAgent: false)
        performSegue(withIdentifier: "uploadImageSegue", sender: user)
    }
        
    func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        present(controller, animated: true)
    }
    
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        guard let textField = sender.superview as? UITextField ?? sender.superview?.superview as? UITextField else { return }
        textField.isSecureTextEntry.toggle()
        let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func setupPasswordToggle(for textField: UITextField) {
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .gray
        toggleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        textField.rightView = toggleButton
        textField.rightViewMode = .always
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "uploadImageSegue",
           let destinationVC = segue.destination as? UploadImageViewController,
           let user = sender as? User {
            destinationVC.user = user
        }
    }
}
