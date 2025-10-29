//
//  UserProfileViewController.swift
//  Group6-HookIM
//
//  Created by Anvi Bajpai on 10/26/25.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseFirestore

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emaillabel: UILabel!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var sportsButton: UIButton!
    
    @IBOutlet weak var freeAgentSwitch: UISwitch!
    @IBOutlet weak var mensButton: UIButton!
    @IBOutlet weak var womensButton: UIButton!
    @IBOutlet weak var coedButton: UIButton!
    
    private let allSports = ["Basketball", "Soccer", "Volleyball", "Softball", "Tennis", "Ultimate", "Pickleball"]
    private let genderOptions = ["Male", "Female", "Other"]
    private var selectedSports = Set<String>()
    private var selectedDivision: String?
    private var selectedGender: String?
    private var newProfileImage: UIImage?
    
    // MARK: - Properties
    var user: User!
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = snapshot?.data(),
               let user = User(from: data) {
                completion(user)
            } else {
                completion(nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser { user in
            guard let user = user else {
                print("No logged in user found.")
                return
            }
            self.user = user
            DispatchQueue.main.async {
                self.loadUserData()
                self.setupUI()
            }
        }
    }

    private func setupUI() {
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.borderWidth = 1
        
        // Gender menu
        let genderActions = genderOptions.map { gender in
            UIAction(title: gender) { _ in
                self.selectedGender = gender
                self.genderButton.setTitle(gender, for: .normal)
            }
        }
        genderButton.menu = UIMenu(title: "Select Gender", children: genderActions)
        genderButton.showsMenuAsPrimaryAction = true

        // Sports menu
        setUpSportsMenu()

        updateDivisionButtons()
    }

    // MARK: - Sports Dropdown Menu
    private func setUpSportsMenu() {
        let actions = allSports.map { sport in
            UIAction(title: sport, state: selectedSports.contains(sport) ? .on : .off) { [weak self] action in
                guard let self = self else { return }
                
                // Toggle selection
                if self.selectedSports.contains(sport) {
                    self.selectedSports.remove(sport)
                } else {
                    self.selectedSports.insert(sport)
                }
                
                // Update button title
                let title = self.selectedSports.isEmpty ? "Select Sports" : self.selectedSports.joined(separator: ", ")
                self.sportsButton.setTitle(title, for: .normal)
                
                // Rebuild menu to update checkmarks
                self.setUpSportsMenu()
            }
        }
        
        sportsButton.menu = UIMenu(title: "Select Sports", children: actions)
        sportsButton.showsMenuAsPrimaryAction = true
    }


    private func loadUserData() {
        if let data = user.profileImageURL {
//           let img = UIImage(data: data) {
//            profileImageView.image = img
            profileImageView.image = UIImage(systemName: "person.crop.circle")
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle")
        }
        
        // Set initial values
        nameTextField.text = "\(user.firstName) \(user.lastName)"
        emaillabel.text = user.email
        
        selectedGender = user.gender
        genderButton.setTitle(selectedGender ?? "Select Gender", for: .normal)
        
        selectedSports = Set(user.interestedSports)
        sportsButton.setTitle(selectedSports.isEmpty ? "Select Sports" : "Selected Sports", for: .normal)
        
        freeAgentSwitch.isOn = user.isFreeAgent
        selectedDivision = user.division
        updateDivisionButtons()
        
    }

    // MARK: - Division Buttons
    @IBAction func menTapped(_ sender: Any) {
        selectedDivision = "Men's"
        updateDivisionButtons()
    }
    
    @IBAction func womenTapped(_ sender: Any) {
        selectedDivision = "Women's"
        updateDivisionButtons()
    }
    
    @IBAction func coedTapped(_ sender: Any) {
        selectedDivision = "Co-Ed"
        updateDivisionButtons()
    }
    
    private func updateDivisionButtons() {
        let buttons: [(UIButton, String)] = [
            (mensButton, "Men's"),
            (womensButton, "Women's"),
            (coedButton, "Co-Ed")
        ]
        
        for (button, division) in buttons {
            if division == selectedDivision {
                button.backgroundColor = .systemIndigo
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    // MARK: - Image Selection (Gallery Only)
    @IBAction func changePhotoTapped(_ sender: Any) {
        checkPhotoLibraryPermission { granted in
            if granted {
                self.openImagePicker()
            } else {
                self.showPermissionAlert()
            }
        }
    }

    private func openImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showAlert(title: "Error", message: "Photo Library not available.")
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        profileImageView.image = selectedImage
        newProfileImage = selectedImage
    }
    
    // MARK: - Save Button
    @IBAction func saveTapped(_ sender: Any) {
        guard let nameText = nameTextField.text, let gender = selectedGender else {
            showAlert(title: "Missing Info", message: "Please fill all required fields.")
            return
        }
        
        let splitName = nameText.split(separator: " ", maxSplits: 1).map(String.init)
        let first = splitName.first ?? ""
        let last = splitName.count > 1 ? splitName[1] : ""
        
        user.firstName = first
        user.lastName = last
        user.gender = gender
        user.isFreeAgent = freeAgentSwitch.isOn
        user.interestedSports = Array(selectedSports)
        user.division = selectedDivision
        
        if let newImage = newProfileImage {
            uploadProfileImage(newImage) { urlString in
                if let urlString = urlString {
                    self.user.profileImageURL = urlString
                }
                self.updateUserInFirestore()
            }
        } else {
            self.updateUserInFirestore()
        }
    }
    
    // MARK: - Firestore Update
    private func updateUserInFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.updateData(user.dictionary) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to update profile: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Saved", message: "Your profile has been updated.")
            }
        }
    }
    
    // MARK: - Firebase Storage Upload, not implemented yet :(
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        // upload image to storage
//        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
//        storageRef.putData(imageData, metadata: nil) { _, error in
//            if let error = error {
//                print("Upload error: \(error)")
//                completion(nil)
//                return
//            }
//            storageRef.downloadURL { url, _ in
//                completion(url?.absoluteString)
//            }
//        }
    }
    
    // MARK: - Helpers
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func showPermissionAlert() {
        showAlert(title: "Permission Denied", message: "Please allow photo access in Settings to change your profile picture.")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
