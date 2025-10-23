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


class CaptainTeamViewController: UIViewController {
    
    struct Player { let name: String }
    struct Team {
        let name: String
        let sport: String
        let category: String
        var roster: [Player]
        var wins: Int
        var losses: Int
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rosterTableView.dataSource = self
        rosterTableView.delegate   = self
        rosterTableView.tableFooterView = UIView()
    }
}

extension CaptainTeamViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        team.roster.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RosterCell", for: indexPath) as! RosterCell
        let player = team.roster[indexPath.row]
        cell.nameLabel.text = player.name
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
