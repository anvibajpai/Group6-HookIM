//
//  CaptainTeamViewController.swift
//  Group6-HookIM
//
//  Created by Shriya Danam on 10/22/25.
//

import UIKit

final class RosterCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var onPlus: (() -> Void)?

    @IBAction func plusTapped(_ sender: UIButton) { onPlus?() }
}


class CaptainTeamViewController: UIViewController, UITabBarDelegate {
    @IBOutlet weak var winsLabel: UILabel!
    
    @IBOutlet weak var lossLabel: UILabel!
    
    private var bottomTabBar: UITabBar!
    
    struct Player { let name: String }
    struct Team {
        let name: String
        let sport: String
        let category: String
        var roster: [Player]
        var wins: Int
        var losses: Int
    }
    
    var wins = 3
    var losses = 2
    
    
    func updateLabels() {
            winsLabel.text = "\(wins)"
            lossLabel.text = "\(losses)"
        }
    
    @IBOutlet weak var teamNameSelector: UIButton!
    @IBOutlet weak var rosterTableView: UITableView!
    
    var team = Team(
            name: "My Team",
            sport: "Basketball",
            category: "Co-ed",
            roster: [
                Player(name: "John Doe"),
                Player(name: "Jane Doe"),
                Player(name: "Jared Doe"),
                Player(name: "Jenny Doe"),
                Player(name: "Jamie Doe")
            ],
            wins: 3, losses: 1
    )
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        // Set Teams tab as selected
        if let items = bottomTabBar?.items, items.count > 1 {
            bottomTabBar.selectedItem = items[1] // Teams item
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rosterTableView.dataSource = self
        rosterTableView.delegate   = self
        rosterTableView.tableFooterView = UIView()
        
        setupTabBar()
    }
    
    private func setupTabBar() {
        bottomTabBar = UITabBar()
        bottomTabBar.translatesAutoresizingMaskIntoConstraints = false
        bottomTabBar.backgroundColor = UIColor(red: 0.7490196078, green: 0.3411764706, blue: 0.0, alpha: 0.7)
        bottomTabBar.delegate = self
        
        let homeItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let teamsItem = UITabBarItem(title: "Teams", image: UIImage(systemName: "person.3"), tag: 1)
        let scheduleItem = UITabBarItem(title: "Schedule", image: UIImage(systemName: "calendar"), tag: 2)
        let standingsItem = UITabBarItem(title: "Leaderboard", image: UIImage(systemName: "trophy"), tag: 3)
        let profileItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 4)
        
        bottomTabBar.items = [homeItem, teamsItem, scheduleItem, standingsItem, profileItem]
        bottomTabBar.selectedItem = teamsItem
        
        view.addSubview(bottomTabBar)
        
        NSLayoutConstraint.activate([
            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Adjust table view bottom constraint
        rosterTableView.translatesAutoresizingMaskIntoConstraints = false
        // Find and deactivate existing bottom constraints
        let constraintsToDeactivate = view.constraints.filter { constraint in
            (constraint.firstItem === rosterTableView && constraint.firstAttribute == .bottom) ||
            (constraint.secondItem === rosterTableView && constraint.secondAttribute == .bottom)
        }
        NSLayoutConstraint.deactivate(constraintsToDeactivate)
        // Add new constraint to tab bar
        rosterTableView.bottomAnchor.constraint(equalTo: bottomTabBar.topAnchor).isActive = true
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items, let selectedIndex = items.firstIndex(of: item) else { return }
        
        switch selectedIndex {
        case 0: // Home
            navigateToDashboard()
        case 1: // Teams
            // Already on teams, do nothing
            return
        case 2: // Schedule
            navigateToSchedule()
        case 3: // Standings
            navigateToStandings()
        case 4: // Profile
            navigateToProfile()
        default:
            break
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
    
    private func navigateToProfile() {
        guard let navController = navigationController else { return }
        
        // Check if UserProfileViewController is already in the stack
        if let profileVC = navController.viewControllers.first(where: { $0 is UserProfileViewController }) {
            navController.popToViewController(profileVC, animated: true)
        } else {
            // Instantiate and push directly
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let profileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
                navController.pushViewController(profileVC, animated: true)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "editRecordSegue" {
                if let destinationVC = segue.destination as? EditRecordViewController {
                    destinationVC.wins = wins
                    destinationVC.losses = losses
                    
                    // Setup callback
                    destinationVC.onSave = { [weak self] updatedWins, updatedLosses in
                        self?.wins = updatedWins
                        self?.losses = updatedLosses
                        self?.updateLabels()
                    }
                }
            }
        }
}

extension CaptainTeamViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        team.roster.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RosterCell", for: indexPath) as! RosterCell
        let player = team.roster[indexPath.row]
        cell.nameLabel.text = "Jane Doe"
        cell.onPlus = { [weak self] in
            guard let self else { return }
            // demo action for the small "+" inside each row
            let alert = UIAlertController(title: "Added", message: "\(player.name) tapped +", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        return cell
    }
    
    // swipe to delete (just edits the in-memory list)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_,done in
            self?.team.roster.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
