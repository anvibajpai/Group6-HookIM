//
//  ScheduleViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 10/21/25.
//

// ScheduleViewController.swift
import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // placeholder for database
    var allGames: [LeagueGame] = [
        LeagueGame(sport: .basketball, teamA: "Longhorns", teamB: "Aggies", teamAScore: 0, teamBScore: 0, gameTime: Date().addingTimeInterval(172800), location: "Gregory Gym"),
        LeagueGame(sport: .basketball, teamA: "Bevo Ballers", teamB: "Dunks Inc.", teamAScore: 0, teamBScore: 0, gameTime: Date().addingTimeInterval(172800), location: "Gregory Gym"),
        LeagueGame(sport: .flagFootball, teamA: "Speedsters", teamB: "Arch and Friends", teamAScore: 0, teamBScore: 0, gameTime: Date().addingTimeInterval(172800), location: "Caven Fields"),
        LeagueGame(sport: .volleyball, teamA: "Spikers", teamB: "The Volleys", teamAScore: 0, teamBScore: 0, gameTime: Date().addingTimeInterval(172800), location: "Bellmont Hall"),
        LeagueGame(sport: .basketball, teamA: "Team 1", teamB: "Team 2", teamAScore: 0, teamBScore: 0, gameTime: Date().addingTimeInterval(86400), location: "Gregory Gym"),
    ]
    
    var upcomingGames: [LeagueGame] = []
    private var filteredGames: [LeagueGame] = []
    
    private let sportSegmentedControl: UISegmentedControl = {
        // show all sports or filter
        let items = ["All"] + Sport.allCases.map { $0.rawValue }
        
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0 // default all
        control.translatesAutoresizingMaskIntoConstraints = false
        
        // make scrollable to robustly add more sports in the future
        if items.count > 5 {
            control.isSpringLoaded = true
            control.apportionsSegmentWidthsByContent = true
        }
        return control
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(GameScheduleTableViewCell.self, forCellReuseIdentifier: GameScheduleTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "League Schedules"
        view.backgroundColor = .systemBackground

        view.addSubview(sportSegmentedControl)
        view.addSubview(tableView)

        sportSegmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapDone)
        )

        NSLayoutConstraint.activate([
            sportSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            sportSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            sportSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            tableView.topAnchor.constraint(equalTo: sportSegmentedControl.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        sortAndFilterGames()
    }
    
    @objc private func didTapDone() {
        dismiss(animated: true)
    }

    // 6. LOGIC
    @objc private func didChangeSegment() {
        updateDataSource()
    }

    private func updateDataSource() {
        let selectedIndex = sportSegmentedControl.selectedSegmentIndex
        
        if selectedIndex == 0 {
            filteredGames = upcomingGames
        } else {
            let selectedSport = Sport.allCases[selectedIndex - 1]
            
            filteredGames = upcomingGames.filter { $0.sport == selectedSport }
        }
        
        tableView.reloadData()
    }

    private func sortAndFilterGames() {
        let allUpcoming = allGames.filter { $0.isUpcoming }
        
        upcomingGames = allUpcoming.sorted { $0.gameTime < $1.gameTime }
        
        updateDataSource()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sportSegmentedControl.selectedSegmentIndex == 0 {
            return upcomingGames.count
        } else {
            return filteredGames.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameScheduleTableViewCell.identifier, for: indexPath) as? GameScheduleTableViewCell else {
            return UITableViewCell()
        }

        let game: LeagueGame
        if sportSegmentedControl.selectedSegmentIndex == 0 {
            game = upcomingGames[indexPath.row]
        } else {
            game = filteredGames[indexPath.row]
        }

        cell.configure(with: game)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
