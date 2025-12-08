//
//  CreateTeamViewController.swift
//  Group6-HookIM
//
//  Created by Shriya Danam on 11/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateTeamViewController: UIViewController {
    
    
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var sportButton: UIButton!
    @IBOutlet weak var divisionButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    // Options
    let sports = ["Basketball", "Soccer", "Volleyball", "Softball", "Tennis", "Ultimate", "Pickleball"]
    let divisions = ["Men's", "Women's", "Co-Ed"]
    
    // Selections
    private var selectedSport: String?
    private var selectedDivision: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for dark mode
        view.backgroundColor = UIColor(named: "AppBackground")
            
        teamNameTextField.backgroundColor = UIColor(named: "CardBackground")
        teamNameTextField.textColor = .label
        
        sportButton.backgroundColor = UIColor(named: "CardBackground")
        sportButton.setTitleColor(.label, for: .normal)
        
        divisionButton.backgroundColor = UIColor(named: "CardBackground")
        divisionButton.setTitleColor(.label, for: .normal)
        
        setupMenus()
        sportButton.setTitleColor(.black, for: .normal)
        divisionButton.setTitleColor(.black, for: .normal)
        if sportButton.title(for: .normal)?.isEmpty ?? true {
                   sportButton.setTitle("Select Sport", for: .normal)
               }
               if divisionButton.title(for: .normal)?.isEmpty ?? true {
                   divisionButton.setTitle("Select Division", for: .normal)
               }
    }
    
    /// Sets up the sports selection menu and the division button actions
    private func setupMenus() {
        // Sports menus
        let sportActions = sports.map { sport in
                UIAction(title: sport, state: (sport == selectedSport ? .on : .off)) { [weak self] _ in
                    self?.selectedSport = sport
                    self?.sportButton.setTitle(sport, for: .normal)
                    self?.setupMenus()
                }
            }
            sportButton.menu = UIMenu(title: "Select Sport", children: sportActions)
            sportButton.showsMenuAsPrimaryAction = true

            // Division buttons
            let divisionActions = divisions.map { div in
                UIAction(title: div, state: (div == selectedDivision ? .on : .off)) { [weak self] _ in
                    self?.selectedDivision = div
                    self?.divisionButton.setTitle(div, for: .normal)
                    self?.setupMenus()
                }
            }
            divisionButton.menu = UIMenu(title: "Select Category", children: divisionActions)
            divisionButton.showsMenuAsPrimaryAction = true
        }
    
    /// When create profile button is pressed, conducts through data validation and saves data to user firestore
    @IBAction func createPressed(_ sender: Any) {
        // Validate that all data is completely filled in
        let name = teamNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !name.isEmpty else {
                    showAlert("Missing Info", "Please enter a team name.")
                    return
                }
                guard let sport = selectedSport else {
                    showAlert("Missing Info", "Please select a sport.")
                    return
                }
                guard let division = selectedDivision else {
                    showAlert("Missing Info", "Please select a division.")
                    return
                }
                guard let ownerUid = Auth.auth().currentUser?.uid else {
                    showAlert("Not Logged In", "Please sign in to create a team.")
                    return
                }

                // Build doc
                let data: [String: Any] = [
                    "name": name,
                    "sport": sport,
                    "division": division,
                    "ownerUid": ownerUid,
                    "memberUids": [ownerUid],
                    "wins": 0,
                    "losses": 0,
                    "points": 0,
                    "createdAt": FieldValue.serverTimestamp()
                ]

        createButton.isEnabled = false

        // save the data to the firestore
        let db = Firestore.firestore()
        let docRef = db.collection("teams").document()

        docRef.setData(data) { [weak self] error in
            guard let self = self else { return }
            self.createButton.isEnabled = true

            if let error = error {
                self.showAlert("Error", "Failed to create team: \(error.localizedDescription)")
                return
            }

            // Add the team ID to the user's teams array
            db.collection("users").document(ownerUid).updateData([
                "teams": FieldValue.arrayUnion([docRef.documentID])
            ]) { _ in
                self.showAlert("Success", "Team created successfully!") {
                    self.navigationController?.popViewController(animated: true)
                }
            } 
        }
        
    }
    
    private func showAlert(_ title: String, _ message: String, _ completion: (() -> Void)? = nil) {
            let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
            present(a, animated: true)
        }
    
}
