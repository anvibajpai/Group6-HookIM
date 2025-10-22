//
//  SportsSelectionViewController.swift
//  Hook IM'
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit

/// View controller responsible for selecting user sports and division.
/// Handles Free Agent toggle, gender/division validation, and passes selected data to the dashboard.
class SportsSelectionViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var freeAgentSwitch: UISwitch!
    @IBOutlet weak var menButton: UIButton!
    @IBOutlet weak var womenButton: UIButton!
    @IBOutlet weak var coedButton: UIButton!

    var user: User!  // User object passed from previous screen
    private var allSports = ["Basketball", "Soccer", "Volleyball", "Softball", "Tennis", "Ultimate", "Pickleball"]
    private var selectedSports = Set<String>()
    private var selectedDivision: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Profile Set-Up"
        navigationItem.backButtonTitle = ""
        
        setupTable()
        updateDivisionButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }

    /// Configures the table view
    private func setupTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sportCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = true
    }

    /// Triggered when "Men's" button is tapped
    @IBAction func menTapped(_ sender: Any) {
        selectedDivision = "Men's"
        updateDivisionButtons()
    }

    /// Triggered when "Women's" button is tapped
    @IBAction func womenTapped(_ sender: Any) {
        selectedDivision = "Women's"
        updateDivisionButtons()
    }

    /// Triggered when "Co-ed" button is tapped
    @IBAction func coedTapped(_ sender: Any) {
        selectedDivision = "Co-Ed"
        updateDivisionButtons()
    }

    /// Updates the division buttons' appearance based on selection
    private func updateDivisionButtons() {
        let buttons: [(UIButton, String)] = [
            (menButton, "Men's"),
            (womenButton, "Women's"),
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
               
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.masksToBounds = true
            button.layer.borderWidth = 1
        }
    }

    /// Triggered when "Finish" button is tapped. Validates selections and saves user
    @IBAction func finishTapped(_ sender: Any) {
        user.interestedSports = Array(selectedSports)
        user.division = selectedDivision
        user.isFreeAgent = freeAgentSwitch.isOn

        if user.isFreeAgent && (user.interestedSports.isEmpty || user.division == nil) {
            showAlert(title: "Profile Incomplete", message: "You turned Free Agent ON — please select at least one sport and a division before finishing.")
            return
        }
        
        if let selected = selectedDivision {
            if (selected == "Men's" && user.gender.lowercased() == "female") ||
               (selected == "Women's" && user.gender.lowercased() == "male") {
                showAlert(title: "Division Mismatch", message: "The selected division does not match your gender. Please select an appropriate division.")
            }
        }

        // Save user
        UserManager.shared.save(user)

        performSegue(withIdentifier: "finishCreateAccountSegue", sender: user)
    }
    
    /// Prepares data before navigating to DashboardViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishCreateAccountSegue",
           let destinationVC = segue.destination as? DashboardViewController,
           let user = sender as? User {
            destinationVC.user = user
        }
    }
    
    /// Displays an alert with a title and message
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// UITableView
extension SportsSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    /// Returns the number of sports
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allSports.count
    }

    /// Configures each cell with sport name and checkmark if selected
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sport = allSports[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "sportCell", for: indexPath)
        cell.textLabel?.text = sport
        cell.accessoryType = selectedSports.contains(sport) ? .checkmark : .none
        return cell
    }

    /// Handles selecting or deselecting a sport
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sport = allSports[indexPath.row]
        if selectedSports.contains(sport) { selectedSports.remove(sport) } else { selectedSports.insert(sport) }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
