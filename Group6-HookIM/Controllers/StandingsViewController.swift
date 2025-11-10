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

class StandingsViewController: UIViewController {

    @IBOutlet weak var sportButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

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
        navigationController?.setNavigationBarHidden(false, animated: animated)
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

        setupSportDropdown()
        selectedSport = sports.first
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
        header.backgroundColor = .systemGray6

        let labels = ["Team", "W", "L", "Pts"].map { text -> UILabel in
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.textAlignment = .center
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
        
        // Alternate background colors
       if indexPath.row % 2 == 0 {
           cell.backgroundColor = UIColor.systemGray6
       } else {
           cell.backgroundColor = UIColor.white
       }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
