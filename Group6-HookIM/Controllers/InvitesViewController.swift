//
//  InvitesViewController.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 11/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class InvitesViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var incomingInviteView: UIView!
    @IBOutlet weak var outgoingInviteView: UIView!
    @IBOutlet weak var historyView: UIView!
    
    @IBOutlet weak var outgoingTableView: UITableView!
    @IBOutlet weak var incomingTableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!
    
    private var incomingInvites: [Invite] = []
    private var outgoingInvites: [Invite] = []
    private var historyInvites: [Invite] = []
    
    private var currentUserID: String?
    private let db = Firestore.firestore()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: No user logged in.")
            navigationController?.popViewController(animated: true)
            return
        }
        self.currentUserID = uid
        
        view.backgroundColor = UIColor(named: "AppBackground")
        incomingTableView.backgroundColor = .clear
        outgoingTableView.backgroundColor = .clear
        historyTableView.backgroundColor = .clear
        
        incomingTableView.dataSource = self
        incomingTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.delegate = self
        outgoingTableView.dataSource = self
        outgoingTableView.delegate = self
        
        incomingTableView.rowHeight = UITableView.automaticDimension
        incomingTableView.estimatedRowHeight = 80
        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.estimatedRowHeight = 80
        outgoingTableView.rowHeight = UITableView.automaticDimension
        outgoingTableView.estimatedRowHeight = 80
        
        segmentedControl.selectedSegmentIndex = 0
        handleSegmentChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        handleSegmentChange()
    }
    
    private func handleSegmentChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            incomingInviteView.isHidden = false
            outgoingInviteView.isHidden = true
            historyView.isHidden = true
            fetchIncomingInvites()
            
        case 1:
            incomingInviteView.isHidden = true
            outgoingInviteView.isHidden = false
            historyView.isHidden = true
            fetchOutgoingInvites()
            
        case 2:
            incomingInviteView.isHidden = true
            outgoingInviteView.isHidden = true
            historyView.isHidden = false
            fetchHistory()
            
        default:
            break
        }
    }
    
    
    private func fetchIncomingInvites() {
        guard let currentUserID = currentUserID else { return }
        
        db.collection("invites")
            .whereField("recipient_id", isEqualTo: currentUserID)
            .whereField("status", isEqualTo: "pending")
            .order(by: "created_at", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching pending invites: \(error.localizedDescription)")
                    return
                }
                
                self.incomingInvites = querySnapshot?.documents.compactMap {
                    Invite(dictionary: $0.data(), id: $0.documentID)
                } ?? []
                
                self.incomingTableView.reloadData()
            }
    }
    
    private func fetchOutgoingInvites() {
        guard let currentUserID = currentUserID else { return }
        
        db.collection("invites")
            .whereField("sender_id", isEqualTo: currentUserID)
            .whereField("status", isEqualTo: "pending")
            .order(by: "created_at", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching outgoing invites: \(error.localizedDescription)")
                    return
                }
                
                self.outgoingInvites = querySnapshot?.documents.compactMap {
                    Invite(dictionary: $0.data(), id: $0.documentID)
                } ?? []
                
                self.outgoingTableView.reloadData()
            }
    }
    
    private func fetchHistory() {
        guard let currentUserID = currentUserID else { return }
        
        db.collection("invites")
            .whereField("sender_id", isEqualTo: currentUserID)
            .whereField("status", in: ["accepted", "declined", "cancelled"])
            .order(by: "created_at", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching invite history: \(error.localizedDescription)")
                    return
                }
                
                self.historyInvites = querySnapshot?.documents.compactMap {
                    Invite(dictionary: $0.data(), id: $0.documentID)
                } ?? []
                
                self.historyTableView.reloadData()
            }
    }

}

extension InvitesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == incomingTableView {
            return incomingInvites.count
        } else if tableView == outgoingTableView {
            return outgoingInvites.count
        } else if tableView == historyTableView {
            return historyInvites.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == incomingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingInviteCell", for: indexPath) as! IncomingInviteCell
            let invite = incomingInvites[indexPath.row]
            cell.configure(with: invite)
            cell.delegate = self
            return cell
            
        } else if tableView == outgoingTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingInviteCell", for: indexPath) as! OutgoingInviteCell
            let invite = outgoingInvites[indexPath.row]
            cell.configure(with: invite)
            cell.delegate = self
            return cell
            
        } else if tableView == historyTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryInviteCell", for: indexPath) as! HistoryInviteCell
            let invite = historyInvites[indexPath.row]
            cell.configure(with: invite)
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: - Invite Cell Delegates
extension InvitesViewController: IncomingInviteCellDelegate, OutgoingInviteCellDelegate {
    
    func didTapAccept(for invite: Invite) {
        print("Accepting invite...")
        
        db.collection("invites").document(invite.id).updateData([
            "status": "accepted"
        ]) { error in
            if let error = error {
                print("Error updating invite status: \(error.localizedDescription)")
                return
            }
        }
        
        db.collection("teams").document(invite.teamID).updateData([
            "memberUids": FieldValue.arrayUnion([invite.recipientID])
        ]) { error in
            if let error = error {
                print("Error adding user to team: \(error.localizedDescription)")
                return
            }
        }
        
        if let index = incomingInvites.firstIndex(where: { $0.id == invite.id }) {
            incomingInvites.remove(at: index)
            incomingTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    func didTapDecline(for invite: Invite) {
        print("Declining invite...")
        
        db.collection("invites").document(invite.id).updateData([
            "status": "declined"
        ])
        
        if let index = incomingInvites.firstIndex(where: { $0.id == invite.id }) {
            incomingInvites.remove(at: index)
            incomingTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    func didTapCancel(for invite: Invite) {
        print("Cancelling invite...")
        
        db.collection("invites").document(invite.id).updateData([
            "status": "cancelled"
        ])
        
        if let index = outgoingInvites.firstIndex(where: { $0.id == invite.id }) {
            outgoingInvites.remove(at: index)
            outgoingTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}
