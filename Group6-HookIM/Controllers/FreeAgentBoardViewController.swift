//
//  FreeAgentBoardViewController.swift
//  Group6-HookIM
//
//  Created by Shriya Danam on 10/22/25.
//

import UIKit
import FirebaseFirestore

class FreeAgentBoardViewController: UIViewController {
    
    
    @IBOutlet weak var sportCategroy: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var sportText: String?
    var teamId: String?
    
    // Firestore + data backing the table
    private let db = Firestore.firestore()
    private var candidates: [UserLite] = []
    
    struct UserLite {
           let id: String
           let name: String
       }

    
    override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let s = sportText, !s.isEmpty {
                sportCategroy.setTitle(s, for: .normal)
                fetchInterestedUsers(for: s)
            } else {
                candidates = []
                tableView.reloadData()
            }
        }

        private func fetchInterestedUsers(for sport: String) {
            db.collection("users")
                .whereField("interestedSports", arrayContains: sport)
                .getDocuments { [weak self] snap, err in
                    guard let self = self else { return }
                    if let err = err {
                        print("🔥 fetchInterestedUsers error:", err)
                        self.candidates = []
                        self.tableView.reloadData()
                        return
                    }
                    let docs = snap?.documents ?? []
                    self.candidates = docs.map { d in
                        let data = d.data()
                        let first = data["firstName"] as? String ?? ""
                        let last  = data["lastName"]  as? String ?? ""
                        let name = [first, last].joined(separator: " ").trimmingCharacters(in: .whitespaces)
                        return UserLite(id: d.documentID, name: name.isEmpty ? "Unnamed" : name)
                    }
                    self.tableView.reloadData()
                }
        }
}

extension FreeAgentBoardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return candidates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reuse the cell with identifier "PlayerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        
        // Configure the cell
        let playerName = candidates[indexPath.row]
        cell.textLabel?.text = playerName.name
        
        // Add a "+" button on the right
        let addButton = UIButton(type: .contactAdd)
        addButton.tag = indexPath.row
        addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
        cell.accessoryView = addButton
        
        return cell
    }
    
    @objc func addButtonTapped(_ sender: UIButton) {
        let user =  candidates[sender.tag]
        showPlayerInvitedPopup(for: user)
    }
    
    func showPlayerInvitedPopup(for user: UserLite) {
            let alert = UIAlertController(
                title: "Player Invited!",
                message: "\(user.name) has been added to your team.",
                preferredStyle: .alert
            )
            
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let self = self, let teamId = self.teamId else { return }

                // --- 1. Add the player to the team’s roster ---
                let teamRef = self.db.collection("teams").document(teamId)
                teamRef.updateData([
                    "memberUids": FieldValue.arrayUnion([user.id])
                ]) { err in
                    if let err = err {
                        print("Failed to add user to team: \(err)")
                        return
                    }

                    // --- 2. Add the team to the player’s 'teams' list ---
                    let userRef = self.db.collection("users").document(user.id)
                    userRef.updateData([
                        "teams": FieldValue.arrayUnion([teamId])
                    ]) { err in
                        if let err = err {
                            print("Failed to add team to user's list: \(err)")
                        } else {
                            print("Added \(user.id) to team \(teamId) and vice versa")
                        }

                        // --- 3. Pop back to the team page ---
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })

            present(alert, animated: true)
        
        }
}
