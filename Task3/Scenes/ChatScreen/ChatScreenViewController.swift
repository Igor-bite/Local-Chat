//
//  ChatScreenViewController.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import InputBarAccessoryView
import MessageKit
import UIKit
import MapKit

final class ChatScreenViewController: MessagesViewController {

    // MARK: - Public properties -

	// swiftlint:disable:next implicitly_unwrapped_optional
    var presenter: ChatScreenPresenterInterface!

    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Chat"

        configureMessageCollectionView()
        configureMessageInputBar()
        messagesCollectionView.reloadData()
    }

    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        showMessageTimestampOnSwipeLeft = true
    }

    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted
        )
    }

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Extensions -

extension ChatScreenViewController: ChatScreenViewInterface {
    func reloadData() {
        messagesCollectionView.reloadData()
    }

    func insertSections(_ sections: IndexSet, completion: @escaping (Bool) -> Void) {
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections(sections)
        }, completion: completion)
    }

    func scrollToLastItem() {
        if isLastSectionVisible() {
            messagesCollectionView.scrollToLastItem(animated: true)
        }
    }

    private func isLastSectionVisible() -> Bool {
        messagesCollectionView.indexPathsForVisibleItems.contains(IndexPath(item: 0, section: presenter.numberOfItems() - 1))
    }

    func setInputBarState(_ state: InputBarState) {
        switch state {
        case .ready:
            messageInputBar.sendButton.stopAnimating()
            messageInputBar.inputTextView.placeholder = "Message"
        case .sending:
            messageInputBar.inputTextView.placeholder = "Sending..."
            messageInputBar.inputTextView.text = nil
            messageInputBar.sendButton.startAnimating()
            messageInputBar.inputTextView.resignFirstResponder()
        }
    }
}

extension ChatScreenViewController: MessagesDataSource {
    var currentSender: SenderType {
        presenter.currentSender
    }

    func numberOfSections(in _: MessagesCollectionView) -> Int {
        presenter.numberOfItems()
    }

    func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
        presenter.messageForItem(at: indexPath)
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray
                ]
            )
        }
        return nil
    }

    func messageTopLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]
        )
    }

    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(
            string: dateString,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)]
        )
    }
}


enum InputBarState {
    case ready
    case sending
}

extension ChatScreenViewController: InputBarAccessoryViewDelegate {
    @objc
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        guard let text = messageInputBar.inputTextView.text else { return }
        presenter.sendMessage(with: text)
    }
}

extension ChatScreenViewController: MessagesDisplayDelegate {
    // MARK: - Text Messages

    func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }

    // MARK: - All Messages

    func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    }

    func messageStyle(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
        avatarView.backgroundColor = isFromCurrentSender(message: message) ? .blue : .gray
    }

    // MARK: - Location Messages

    func annotationViewForLocation(message _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }

    func animationBlockForLocation(
        message _: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView
    ) -> ((UIImageView) -> Void)? {
        { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    view.layer.transform = CATransform3DIdentity
                },
                completion: nil
            )
        }
    }

    func snapshotOptionsForLocation(
        message _: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView
    )
        -> LocationMessageSnapshotOptions
    {
        LocationMessageSnapshotOptions(
            showsBuildings: true,
            showsPointsOfInterest: true,
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    }

    // MARK: - Audio Messages

    func audioTintColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
    }
}

extension ChatScreenViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        18
    }

    func cellBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        17
    }

    func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        20
    }

    func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        16
    }
}
