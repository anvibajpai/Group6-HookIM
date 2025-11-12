//
//  HistoryInviteCell.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 11/11/25.
//

import UIKit

class HistoryInviteCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    func configure(with invite: Invite) {
        let dateString = dateFormatter.string(from: invite.createdAt)
        let statusString = invite.status
                
        infoLabel.text = "Sent invite for \(invite.teamName) to \(invite.recipientName) on \(dateString). Invite was \(statusString)"
        

    }
}
