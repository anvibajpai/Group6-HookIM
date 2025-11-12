//
//  IncomingInviteCell.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 11/11/25.
//

import UIKit

protocol IncomingInviteCellDelegate: AnyObject {
    func didTapAccept(for invite: Invite)
    func didTapDecline(for invite: Invite)
}

class IncomingInviteCell: UITableViewCell {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    weak var delegate: IncomingInviteCellDelegate?
    private var invite: Invite?
    
    func configure(with invite: Invite) {
        self.invite = invite
        infoLabel.text = "\(invite.senderName) invited you to join \(invite.teamName) (\(invite.sport))."
        
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 8
        
        declineButton.setTitleColor(.white, for: .normal)
        declineButton.layer.cornerRadius = 8
    }
    
    @IBAction func acceptTapped(_ sender: UIButton) {
        guard let invite = invite else { return }
        delegate?.didTapAccept(for: invite)
    }
    
    @IBAction func declineTapped(_ sender: UIButton) {
        guard let invite = invite else { return }
        delegate?.didTapDecline(for: invite)
    }
}
