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
import FirebaseStorage

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emaillabel: UILabel!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var sportsButton: UIButton!
    
    @IBOutlet weak var freeAgentSwitch: UISwitch!
    @IBOutlet weak var mensButton: UIButton!
    @IBOutlet weak var womensButton: UIButton!
    @IBOutlet weak var coedButton: UIButton!
    
    private var bottomTabBar: UITabBar!
    
    private let allSports = ["Basketball", "Soccer", "Volleyball", "Softball", "Tennis", "Ultimate", "Pickleball"]
    private let genderOptions = ["Male", "Female", "Other"]
    private var selectedSports = Set<String>()
    private var selectedDivision: String?
    private var selectedGender: String?
    private var newProfileImage: UIImage?
    
    /// Retrieves current user and displays error if it occurs.
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Set Profile tab as selected
        if let items = bottomTabBar?.items, items.count > 4 {
            bottomTabBar.selectedItem = items[4] // Profile item
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
                self.setupTabBar()
            }
        }
    }
    
    private func setupTabBar() {
        bottomTabBar = UITabBar()
        bottomTabBar.translatesAutoresizingMaskIntoConstraints = false
        bottomTabBar.backgroundColor = UIColor(red: 0.749, green: 0.341, blue: 0.0, alpha: 0.7)

        bottomTabBar.isTranslucent = true 
        bottomTabBar.backgroundImage = UIImage()
        bottomTabBar.shadowImage = UIImage()

        bottomTabBar.delegate = self

        let homeItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let teamsItem = UITabBarItem(title: "Teams", image: UIImage(systemName: "person.3"), tag: 1)
        let scheduleItem = UITabBarItem(title: "Schedule", image: UIImage(systemName: "calendar"), tag: 2)
        let standingsItem = UITabBarItem(title: "Leaderboard", image: UIImage(systemName: "trophy"), tag: 3)
        let profileItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 4)

        bottomTabBar.items = [homeItem, teamsItem, scheduleItem, standingsItem, profileItem]
        bottomTabBar.selectedItem = profileItem

        view.addSubview(bottomTabBar)

        NSLayoutConstraint.activate([
            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            bottomTabBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let selectedIndex = items.firstIndex(of: item) else { return }
        
        switch selectedIndex {
        case 0: // Home
            navigateToDashboard()
        case 1: // Teams
            navigateToTeams()
        case 2: // Schedule
            navigateToSchedule()
        case 3: // Standings
            navigateToStandings()
        case 4: // Profile
            // Already on profile, do nothing
            return
        default:
            break
        }
    }
    
    private func navigateToTeams() {
        guard let navController = navigationController else { return }
        
        // Check if CaptainTeamViewController is already in the stack
        if let teamsVC = navController.viewControllers.first(where: { $0 is CaptainTeamViewController }) {
            navController.popToViewController(teamsVC, animated: true)
        } else {
            // Instantiate and push directly
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let teamsVC = storyboard.instantiateViewController(withIdentifier: "CaptainTeamViewController") as? CaptainTeamViewController {
                navController.pushViewController(teamsVC, animated: true)
            }
        }
    }
    
    private func navigateToSchedule() {
        guard let navController = navigationController else { return }
        
        // Check if ScheduleViewController is already in the stack
        if let scheduleVC = navController.viewControllers.first(where: { $0 is ScheduleViewController }) {
            navController.popToViewController(scheduleVC, animated: true)
        } else {
            // Instantiate and push directly
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let scheduleVC = storyboard.instantiateViewController(withIdentifier: "ScheduleViewController") as? ScheduleViewController {
                navController.pushViewController(scheduleVC, animated: true)
            }
        }
    }
    
    private func navigateToStandings() {
        guard let navController = navigationController else { return }
        
        // Check if StandingsViewController is already in the stack
        if let standingsVC = navController.viewControllers.first(where: { $0 is StandingsViewController }) {
            navController.popToViewController(standingsVC, animated: true)
        } else {
            // Instantiate and push directly
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let standingsVC = storyboard.instantiateViewController(withIdentifier: "StandingsViewController") as? StandingsViewController {
                navController.pushViewController(standingsVC, animated: true)
            }
        }
    }
    
    private func navigateToDashboard() {
        guard let navController = navigationController else { return }
        
        // Check if DashboardViewController is already in the stack (should be root)
        if let dashboardVC = navController.viewControllers.first(where: { $0 is DashboardViewController }) {
            navController.popToViewController(dashboardVC, animated: true)
        } else {
            // If for some reason Dashboard is not in stack, instantiate and set as root
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
                navController.setViewControllers([dashboardVC], animated: true)
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

    /// Sets up the select sports Dropdown Menu
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


    /// Loads current users data to autofill the name, selected sports, gender, free agent , etc fields.
    private func loadUserData() {
        if let imageURL = user.profileImageURL,
           !imageURL.isEmpty,
           let url = URL(string: imageURL) {
           
           URLSession.shared.dataTask(with: url) { data, _, error in
               DispatchQueue.main.async {
                   if let data = data, let image = UIImage(data: data) {
                       self.profileImageView.image = image
                   } else {
                       self.profileImageView.image = UIImage(systemName: "person.crop.circle")
                       if let error = error {
                           print("⚠️ Failed to load profile image: \(error.localizedDescription)")
                       }
                   }
               }
           }.resume()
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

    // Division Buttons, called when tapped.
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
    
    /// Updates the UI of the division button that has been selected/unselected
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
    
    /// When change photo button is tapped, opens Gallery Image Selection
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
    
    /// When saved, validates user data and calls helper to save data to firebase
    @IBAction func saveTapped(_ sender: Any) {
        guard let nameText = nameTextField.text, let gender = selectedGender else {
            showAlert(title: "Missing Info", message: "Please fill all required fields.")
            return
        }
        
        if let division = selectedDivision {
            if (division == "Men's" && gender == "Female") ||
               (division == "Women's" && gender == "Male") {
                showAlert(title: "Division Mismatch", message: "Please select a division that matches your gender.")
                return
            }
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
    
    /// Helper function updates the user's data in firestore
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
    
    /// Helper function updates profile image in firebase storage.
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        // upload image to storage
        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Upload error: \(error)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
    
    ///Helper functions for permissions
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
    
    /// When user signs out, sign out in firestore and direct user to login page.
    @IBAction func signOutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()

                // Clear any locally cached user info
                UserDefaults.standard.removeObject(forKey: "partialUserData")

                // Go back to login screen
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController")
                    sceneDelegate.window?.rootViewController = loginVC
                }
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
                let failAlert = UIAlertController(title: "Error", message: "Failed to sign out. Please try again.", preferredStyle: .alert)
                failAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(failAlert, animated: true)
            }
        })
        present(alert, animated: true)
    }

    /// Helper function to show alert messages
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
