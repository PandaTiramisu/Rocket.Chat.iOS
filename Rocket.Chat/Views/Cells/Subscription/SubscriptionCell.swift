//
//  SubscriptionCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/4/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class SubscriptionCell: UITableViewCell {

    static let identifier = "CellSubscription"

    internal let labelSelectedTextColor = UIColor(rgb: 0xFFFFFF, alphaVal: 1)
    internal let labelReadTextColor = UIColor(rgb: 0x9ea2a4, alphaVal: 1)
    internal let labelUnreadTextColor = UIColor(rgb: 0xFFFFFF, alphaVal: 1)

    internal let defaultBackgroundColor = UIColor.clear
    internal let selectedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.18)
    internal let highlightedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.27)

    var subscription: Subscription? {
        didSet {
            updateSubscriptionInformatin()
        }
    }

    @IBOutlet weak var viewStatus: UIView! {
        didSet {
            viewStatus.layer.masksToBounds = true
            viewStatus.layer.cornerRadius = 4.5
            viewStatus.layer.borderColor = UIColor.white.cgColor
            viewStatus.layer.borderWidth = 1
        }
    }

    weak var avatarView: AvatarView!
    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarViewContainer.layer.cornerRadius = 4
            avatarViewContainer.layer.masksToBounds = true

            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = avatarViewContainer.bounds
                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLastMessage: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUnread: UILabel! {
        didSet {
            labelUnread.layer.cornerRadius = 4
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarView.prepareForReuse()

        labelName.text = ""
        labelLastMessage.text = ""
        labelUnread.text = ""
        labelUnread.alpha = 0
    }

    func updateSubscriptionInformatin() {
        guard let subscription = self.subscription else { return }
        guard let user = AuthManager.currentUser() else { return }

        updateStatus()

        if let user = subscription.directMessageUser {
            avatarView.subscription = nil
            avatarView.user = user
        } else {
            avatarView.user = nil
            avatarView.subscription = subscription
        }

        labelName.text = subscription.displayName()
        labelLastMessage.text = subscription.lastMessageText()

        if subscription.displayName() == user.username {
            labelName.text?.append(" (" + localized("subscriptions.you") + ")")
        }

        let nameFontSize = labelName.font.pointSize
        let lastMessageFontSize = labelLastMessage.font.pointSize

        if let roomUpdatedAt = subscription.roomUpdatedAt {
            labelDate.text = dateFormatted(date: roomUpdatedAt)
        }

        if subscription.unread > 0 {
            labelName.font = UIFont.boldSystemFont(ofSize: nameFontSize)
            labelLastMessage.font = UIFont.boldSystemFont(ofSize: lastMessageFontSize)
            labelDate.textColor = .RCBlue()

            labelUnread.alpha = 1
            labelUnread.text =  "\(subscription.unread)"
        } else {
            labelName.font = UIFont.systemFont(ofSize: nameFontSize)
            labelLastMessage.font = UIFont.systemFont(ofSize: lastMessageFontSize)
            labelDate.textColor = .RCGray()

            labelUnread.alpha = 0
            labelUnread.text =  ""
        }
    }

    func updateStatus() {
        guard let subscription = self.subscription else { return }

        if subscription.type == .directMessage {
            viewStatus.isHidden = false

            if let user = subscription.directMessageUser {
                switch user.status {
                case .online: viewStatus.backgroundColor = .RCOnline()
                case .busy: viewStatus.backgroundColor = .RCBusy()
                case .away: viewStatus.backgroundColor = .RCAway()
                case .offline: viewStatus.backgroundColor = .RCInvisible()
                }
            }
        } else {
            viewStatus.isHidden = true
        }
    }

    // Need to localize this formatting
    func dateFormatted(date: Date) -> String {
        let calendar = NSCalendar.current

        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }

        if calendar.isDateInToday(date) {
            return RCDateFormatter.time(date)
        }

        return RCDateFormatter.date(date, dateStyle: .short)
    }

}

extension SubscriptionCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        let transition = {
            switch selected {
            case true:
                self.backgroundColor = self.selectedBackgroundColor
            case false:
                self.backgroundColor = self.defaultBackgroundColor
            }
        }

        if animated {
            UIView.animate(withDuration: 0.18, animations: transition)
        } else {
            transition()
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let transition = {
            switch highlighted {
            case true:
                self.backgroundColor = self.highlightedBackgroundColor
            case false:
                self.backgroundColor = self.defaultBackgroundColor
            }
        }

        if animated {
            UIView.animate(withDuration: 0.18, animations: transition)
        } else {
            transition()
        }
    }
}
