//
//  ScheduleViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/28/25.
//

import UIKit

class ScheduleCell: UITableViewCell {
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}

class ScheduleViewController: UIViewController {

    @IBOutlet weak var sportButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    let sports = ["Women's Basketball", "Men's Basketball", "Co-ed Basketball"]
    
    var scheduleData: [String: [Game]] = [
        "Women's Basketball": [
            Game(team: "Hoopers", opponent: "Swish", location: "Gregory Gym", time: "Oct 29, 7PM"),
            Game(team: "Slam Dunks", opponent: "Hoopers", location: "Belmont Hall", time: "Nov 2, 8PM")
        ],
        "Men's Basketball": [
            Game(team: "myTeam", opponent: "Team1", location: "Gregory Gym", time: "Oct 30, 6PM")
        ],
        "Co-ed Basketball": [
            Game(team: "Hoops", opponent: "Swishers", location: "Gregory Gym", time: "Nov 1, 9PM")
        ]
    ]

    var selectedSport: String? {
        didSet {
            sportButton.setTitle(selectedSport ?? "Select Sport", for: .normal)
            tableView.reloadData()
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
    
    @objc private func didTapCalendarButton() {
        performSegue(withIdentifier: "toCalendarSegue", sender: self)
    }
}

/// UITableViewDataSource & UITableViewDelegate
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
        cell.timeLabel.text = game.time
        
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
