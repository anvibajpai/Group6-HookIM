//
//  FreeAgentBoardViewController.swift
//  Group6-HookIM
//
//  Created by Shriya Danam on 10/22/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FreeAgentBoardViewController: UIViewController {
    
    
    @IBOutlet weak var sportCategroy: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var sportText: String?
    var teamId: String?
    
    //Firestore + data backing the table
    private let db = Firestore.firestore()
    private var candidates: [UserLite] = []
    private var memberIds: Set<String> = []
    
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
                loadMembersThenCandidates(for: s)
            } else {
                candidates = []
                tableView.reloadData()
            }
        }
    
    private func loadMembersThenCandidates(for sport: String) {
        guard let teamId = teamId else {
            memberIds = []
            fetchInterestedUsers(for: sport, excluding: [])
            return
        }
        db.collection("teams").document(teamId).getDocument { [weak self] snap, _ in
            guard let self = self else { return }
            let ids = (snap?.data()?["memberUids"] as? [String]) ?? []
            self.memberIds = Set(ids)
            self.fetchInterestedUsers(for: sport, excluding: self.memberIds)
        }
    }

        //Fetches only the people that are a part of the same sport/division
        private func fetchInterestedUsers(for sport: String, excluding: Set<String> = []) {
            db.collection("users")
                .whereField("interestedSports", arrayContains: sport)
                .getDocuments { [weak self] snap, err in
                    guard let self = self else { return }
                    if let err = err {
                        print("fetchInterestedUsers error:", err)
                        self.candidates = []
                        self.tableView.reloadData()
                        return
                    }
                    let docs = snap?.documents ?? []
                    self.candidates = docs.compactMap { d -> UserLite? in
                        let id = d.documentID
                        if excluding.contains(id) { return nil }
                        let data  = d.data()
                        let first = data["firstName"] as? String ?? ""
                        let last  = data["lastName"]  as? String ?? ""
                        let name  = [first, last].joined(separator: " ").trimmingCharacters(in: .whitespaces)

                        return UserLite(id: id, name: name.isEmpty ? "Unnamed" : name)
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
            title: "Invite Sent!",
            message: "\(user.name) has been invited to your team.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard
                let self = self,
                let teamId = self.teamId,
                let senderId = Auth.auth().currentUser?.uid,
                let selectedTeam = (self.teamId.flatMap { id in
                    self.db.collection("teams").document(id)
                })
            else { return }

            // Fetch team info to populate invite fields
            self.db.collection("teams").document(teamId).getDocument { snap, _ in
                guard let data = snap?.data() else { return }
                let teamName = data["name"] as? String ?? "Unknown Team"
                let sport = data["sport"] as? String ?? ""
                let division = data["division"] as? String ?? ""

                // Fetch sender name from "users" collection
                self.db.collection("users").document(senderId).getDocument { userSnap, _ in
                    let senderFirst = userSnap?.data()?["firstName"] as? String ?? ""
                    let senderLast  = userSnap?.data()?["lastName"] as? String ?? ""
                    let senderName  = "\(senderFirst) \(senderLast)".trimmingCharacters(in: .whitespaces)

                    let inviteData: [String: Any] = [
                        "team_id": teamId,
                        "team_name": teamName,
                        "sport": sport,
                        "division": division,
                        "sender_id": senderId,
                        "sender_name": senderName,
                        "recipient_id": user.id,
                        "recipient_name": user.name,
                        "status": "pending",
                        "created_at": FieldValue.serverTimestamp()
                    ]

                    self.db.collection("invites").addDocument(data: inviteData) { error in
                        if let error = error {
                            print("Error creating invite: \(error)")
                        } else {
                            print("Invite created!")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        })

        present(alert, animated: true)
    }

}
