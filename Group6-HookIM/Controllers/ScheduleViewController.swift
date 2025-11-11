//
//  ScheduleViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/28/25.
//

import UIKit

class ScheduleViewController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var sportButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var bottomTabBar: UITabBar!
    
    // MARK: - Properties
    let sports = ["Women's Basketball", "Men's Basketball", "Co-ed Basketball"]
    
    lazy var scheduleData: [String: [Game]] = [
        "Women's Basketball": [
            Game(team: "Hoopers", opponent: "Swish", location: "Gregory Gym", date: makeDate("Oct 29, 7PM")),
            Game(team: "Slam Dunks", opponent: "Hoopers", location: "Belmont Hall", date: makeDate("Nov 2, 8PM"))
        ],
        "Men's Basketball": [
            Game(team: "myTeam", opponent: "Team1", location: "Gregory Gym", date: makeDate("Oct 30, 6PM"))
        ],
        "Co-ed Basketball": [
            Game(team: "Hoops", opponent: "Swishers", location: "Gregory Gym", date: makeDate("Nov 1, 9PM")),
            Game(team: "Hoops", opponent: "TeamX", location: "Gregory Gym", date: makeDate("Nov 1, 10PM"))
        ]
    ]

    var selectedSport: String? {
        didSet {
            sportButton.setTitle(selectedSport ?? "Select Sport", for: .normal)
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        // Set Schedule tab as selected
        if let items = bottomTabBar?.items, items.count > 2 {
            bottomTabBar.selectedItem = items[2] // Schedule item
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendarButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(didTapCalendarButton)
        )
        navigationItem.rightBarButtonItem = calendarButton
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()

        setupSportDropdown()
        selectedSport = sports.first
        
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
        bottomTabBar.selectedItem = scheduleItem
        
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
            // Already on schedule, do nothing
            return
        case 3: // Standings
            navigateToStandings()
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

    // MARK: - Helpers
    private func makeDate(_ dateString: String) -> Date {
        let cal = Calendar.current
        let currentYear = cal.component(.year, from: Date())
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM d, ha, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let fullDateString = "\(dateString), \(currentYear)"
        
        if let date = formatter.date(from: fullDateString) {
            return date
        } else {
            print("ERROR: Failed to parse date string: \(fullDateString).")
            return Date()
        }
    }
    
    private func setupSportDropdown() {
        let actions = sports.map { sport in
            UIAction(title: sport) { _ in
                self.selectedSport = sport
            }
        }
        sportButton.menu = UIMenu(title: "Select Sport", children: actions)
        sportButton.showsMenuAsPrimaryAction = true
    }
    
    @objc private func didTapCalendarButton() {
        performSegue(withIdentifier: "toCalendarSegue", sender: self)
    }
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sport = selectedSport else { return 0 }
        return scheduleData[sport]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let sport = selectedSport,
              let games = scheduleData[sport] else { return UITableViewCell() }
        
        let game = games[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        
        cell.teamLabel.text = game.team
        cell.opponentLabel.text = "vs \(game.opponent)"
        cell.locationLabel.text = game.location
        cell.timeLabel.text = timeFormatter.string(from: game.date)
        
         if indexPath.row % 2 == 0 {
             cell.backgroundColor = UIColor.systemGroupedBackground
         } else {
             cell.backgroundColor = UIColor.secondarySystemGroupedBackground
         }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
