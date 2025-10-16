
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

    //private var genderPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupGenderPicker()
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

//    func setupGenderPicker() {
//        genderPicker = UIPickerView()
//        genderPicker.delegate = self
//        genderPicker.dataSource = self
//    }

//    @IBAction func genderButtonTapped(_ sender: Any) {
//        print("gender tapped")
//        let alert = UIAlertController(title: "Select Gender", message: nil, preferredStyle: .actionSheet)
//
//        for gender in genders {
//            alert.addAction(UIAlertAction(title: gender, style: .default, handler: { _ in
//                self.selectedGender = gender
//                self.genderButton.setTitle(gender, for: .normal)
//            }))
//        }
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(alert, animated: true)
//    }
    
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
        performSegue(withIdentifier: "uploadImageSegue", sender: nil)
    }
        

    func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        present(controller, animated: true)
    }
    //  UIPickerView Delegates (not used currently)
//    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { genders.count }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { genders[row] }
}
