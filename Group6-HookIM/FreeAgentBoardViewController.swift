//
//  FreeAgentBoardViewController.swift
//  Group6-HookIM
//
//  Created by Shriya Danam on 10/22/25.
//

import UIKit

class FreeAgentBoardViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // Hardcoded (for now)
        let players = ["John Doe", "Jane Doe", "Jared Doe", "Jenny Doe", "Jamie Doe"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension FreeAgentBoardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reuse the cell with identifier "PlayerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        
        // Configure the cell
        let playerName = players[indexPath.row]
        cell.textLabel?.text = playerName
        
        // Add a "+" button on the right
        let addButton = UIButton(type: .contactAdd)
        addButton.tag = indexPath.row
        addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        cell.accessoryView = addButton
        
        return cell
    }
    
    @objc func addButtonTapped(_ sender: UIButton) {
        let playerName = players[sender.tag]
        showPlayerInvitedPopup(for: playerName)
    }
    
    func showPlayerInvitedPopup(for playerName: String) {
            let alert = UIAlertController(
                title: "Player Invited!",
                message: "\(playerName) has been invited to your team. Should they accept, they will be added to the roster. You will be notified of their decision when they make it.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
}
