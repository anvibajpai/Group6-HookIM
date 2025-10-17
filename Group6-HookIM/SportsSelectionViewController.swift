//
//  SportsSelectionViewController.swift
//  Hook IM'
//
//  Created by Anvi Bajpai on 10/15/25.
//

import UIKit

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
        loadExistingUserData()
        updateDivisionButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }

    private func setupTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sportCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = true
    }

    private func loadExistingUserData() {
        selectedSports = Set(user.interestedSports)
        selectedDivision = user.division
        freeAgentSwitch.isOn = user.isFreeAgent
    }

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
        let mapping = ["Men's": menButton, "Women's": womenButton, "Co-Ed": coedButton]
        for (key, button) in mapping {
            button?.alpha = (selectedDivision == key) ? 1.0 : 0.5
        }
    }

    @IBAction func finishTapped(_ sender: Any) {
        user.interestedSports = Array(selectedSports)
        user.division = selectedDivision
        user.isFreeAgent = freeAgentSwitch.isOn

        if user.isFreeAgent && (user.interestedSports.isEmpty || user.division == nil) {
            showAlert(title: "Profile Incomplete", message: "You turned Free Agent ON — please select at least one sport and a division before finishing.")
            return
        }

        // Save user
        UserManager.shared.save(user)

        // SEGUE to dashboard and pass user in prepare
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// UITableView
extension SportsSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { allSports.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sport = allSports[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "sportCell", for: indexPath)
        cell.textLabel?.text = sport
        cell.accessoryType = selectedSports.contains(sport) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sport = allSports[indexPath.row]
        if selectedSports.contains(sport) { selectedSports.remove(sport) } else { selectedSports.insert(sport) }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
