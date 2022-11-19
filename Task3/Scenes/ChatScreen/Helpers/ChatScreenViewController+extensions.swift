//
//  ChatScreenViewController+extensions.swift
//  Task3
//
//  Created by Игорь Клюжев on 19.11.2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

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
        presenter.cellTopLabel(for: message, at: indexPath)
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        presenter.messageTopLabel(for: message, at: indexPath)
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        presenter.messageBottomLabel(for: message, at: indexPath)
    }
}

extension ChatScreenViewController: InputBarAccessoryViewDelegate, CameraInputBarAccessoryViewDelegate {
    @objc
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        guard let text = messageInputBar.inputTextView.text else { return }
        presenter.sendMessage(withKind: .text(text))
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        for item in attachments {
            if case .image(let image) = item {
                self.presenter.sendMessage(withKind: .photo(ImageMediaItem(image: image)))
            }
        }
        inputBar.invalidatePlugins()
    }
}

extension ChatScreenViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }

    func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .photo:
            return .clear
        default:
            return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
        }
    }

    func messageStyle(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
        let (avatar, bgColor) = AvatarGenerator.getAvatar(forSender: message.sender)
        avatarView.set(avatar: avatar)
        avatarView.backgroundColor = bgColor
    }

    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView)
    {
        var curImage = imageView.image
        curImage = curImage?.blurredImage()
        let arImage = UIImage(named: "view_in_ar")!
        imageView.image = .imageByMergingImages(badgeImage: arImage, bgImage: curImage!, badgeScale: 1.2)
    }
}

extension ChatScreenViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        presenter.didTapImage(at: indexPath)
    }
}

extension ChatScreenViewController: MessagesLayoutDelegate {
    private enum Constants {
        enum Cell {
            static let topLabelHeight = 15.0
            static let bottomLabelHeight = 0.0
        }

        enum Message {
            static let topLabelHeight = 20.0
            static let bottomLabelHeight = 16.0
        }
    }
    
    func cellTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        Constants.Cell.topLabelHeight
    }

    func cellBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        Constants.Cell.bottomLabelHeight
    }

    func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        Constants.Message.topLabelHeight
    }

    func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        Constants.Message.bottomLabelHeight
    }
}
