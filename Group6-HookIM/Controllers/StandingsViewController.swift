//
//  StandingsViewController.swift
//  Group6-HookIM
//
//  Created by Anvi Bajpai on 10/21/25.
//

import UIKit

// Data Model
struct Team {
    let name: String
    let wins: Int
    let losses: Int
    var points: Int { wins * 2 }
}

class StandingsCell: UITableViewCell {
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var lossesLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
}

class StandingsViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var sportButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var bottomTabBar: UITabBar!
    
    // MARK: - Properties
    let sports = ["Women's Basketball", "Men's Basketball", "Co-ed Basketball"]
    
    // Sample standings data
    var standingsData: [String: [Team]] = [
        "Women's Basketball": [
            Team(name: "Hoopers", wins: 8, losses: 2),
            Team(name: "Swish", wins: 6, losses: 4),
            Team(name: "Slam Dunks", wins: 5, losses: 5)
        ],
        "Men's Basketball": [
            Team(name: "Team1", wins: 10, losses: 1),
            Team(name: "myTeam", wins: 7, losses: 4),
            Team(name: "Team2", wins: 3, losses: 8)
        ],
        "Co-ed Basketball": [
            Team(name: "Hoops", wins: 10, losses: 1),
            Team(name: "Swishers", wins: 7, losses: 4),
            Team(name: "Team4", wins: 3, losses: 8)
        ]
    ]

    var selectedSport: String? {
        didSet {
            sportButton.setTitle(selectedSport ?? "Select Sport", for: .normal)
            tableView.reloadData()
        }
    }

    // make nav bar appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(named: "WarmOrange")
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNavigationBarHidden(false, animated: animated)
        if let items = bottomTabBar?.items, items.count > 3 {
            bottomTabBar.selectedItem = items[3]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Standings"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView() // hide empty cells
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()

        //for dark mode
        view.backgroundColor = UIColor(named: "AppBackground")
        tableView.backgroundColor = .clear
        
        sportButton.setTitleColor(.label, for: .normal)
        sportButton.backgroundColor = UIColor(named: "CardBackground")
        
        setupSportDropdown()
        selectedSport = sports.first
        
        if let navController = navigationController {
            navController.navigationBar.backgroundColor = UIColor(named: "WarmOrange")
        }
        
        setupTabBar()
    }
    
    private func setupTabBar() {
        bottomTabBar = UITabBar()
        bottomTabBar.translatesAutoresizingMaskIntoConstraints = false
        bottomTabBar.backgroundColor = UIColor(named: "WarmOrange")
        bottomTabBar.delegate = self
        
        let homeItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let teamsItem = UITabBarItem(title: "Teams", image: UIImage(systemName: "person.3"), tag: 1)
        let scheduleItem = UITabBarItem(title: "Schedule", image: UIImage(systemName: "calendar"), tag: 2)
        let standingsItem = UITabBarItem(title: "Leaderboard", image: UIImage(systemName: "trophy"), tag: 3)
        let profileItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 4)
        
        bottomTabBar.items = [homeItem, teamsItem, scheduleItem, standingsItem, profileItem]
        bottomTabBar.selectedItem = standingsItem
        
        view.addSubview(bottomTabBar)
        
        NSLayoutConstraint.activate([
            bottomTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Adjust table view bottom constraint
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // Find and deactivate existing bottom constraints
        let constraintsToDeactivate = view.constraints.filter { constraint in
            (constraint.firstItem === tableView && constraint.firstAttribute == .bottom) ||
            (constraint.secondItem === tableView && constraint.secondAttribute == .bottom)
        }
        NSLayoutConstraint.deactivate(constraintsToDeactivate)
        // Add new constraint to tab bar
        tableView.bottomAnchor.constraint(equalTo: bottomTabBar.topAnchor).isActive = true
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
            // Already on standings, do nothing
            return
        case 4: // Profile
            navigateToProfile()
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

    /// Setup Sport Selection Dropdown
    private func setupSportDropdown() {
        let actions = sports.map { sport in
            UIAction(title: sport) { _ in
                self.selectedSport = sport
            }
        }
        sportButton.menu = UIMenu(title: "Select Sport", children: actions)
        sportButton.showsMenuAsPrimaryAction = true
    }
}

/// UITableViewDataSource & UITableViewDelegate
extension StandingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Header row
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .secondarySystemBackground

        let labels = ["Team", "W", "L", "Pts"].map { text -> UILabel in
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.textAlignment = .center
            label.textColor = .label
            return label
        }
        labels[0].textAlignment = .left

        let stack = UIStackView(arrangedSubviews: labels)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 8

        header.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: header.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16)
        ])

        return header
    }
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sport = selectedSport else { return 0 }
        return standingsData[sport]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let sport = selectedSport,
              var teams = standingsData[sport] else { return UITableViewCell() }

        // Sort by points descending
        teams.sort { $0.points > $1.points }

        let team = teams[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandingsCell", for: indexPath) as! StandingsCell
        cell.teamLabel.text = team.name
        cell.winsLabel.text = "\(team.wins)"
        cell.lossesLabel.text = "\(team.losses)"
        cell.pointsLabel.text = "\(team.points)"
        
        // wraps team names to not truncate
        cell.teamLabel.numberOfLines = 0
        cell.teamLabel.lineBreakMode = .byWordWrapping
        
        // Alternate background colors 
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(named: "CardBackground")
        } else {
            cell.backgroundColor = UIColor(named: "AppBackground")
        }
      
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
