//
//  OutgoingInviteCell.swift
//  Group6-HookIM
//
//  Created by Arnav Chopra on 11/11/25.
//

import UIKit

protocol OutgoingInviteCellDelegate: AnyObject {
    func didTapCancel(for invite: Invite)
}

class OutgoingInviteCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: OutgoingInviteCellDelegate?
    private var invite: Invite?
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        guard let invite = invite else { return }
        delegate?.didTapCancel(for: invite)
    }
    
    func configure(with invite: Invite) {
        self.invite = invite
        infoLabel.text = "Sent invite to \(invite.recipientName) for \(invite.teamName)."
        
        cancelButton.setTitleColor(.systemRed, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
}
