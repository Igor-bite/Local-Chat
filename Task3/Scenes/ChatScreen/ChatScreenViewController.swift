//
//  ChatScreenViewController.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import InputBarAccessoryView
import MessageKit
import UIKit

final class ChatScreenViewController: MessagesViewController {
    private enum Constants {
        enum Cell {
            static let topLabelHeight = 15.0
            static let bottomLabelHeight = 0.0
        }

        enum Message {
            static let topLabelHeight = 20.0
            static let bottomLabelHeight = 16.0
        }

        enum InputBar {
            enum Paddings {
                static let bottom = 8.0
                static let middleContentRight = -38.0
                static let textContainerBottom = 8.0
            }

            static let readyStatePlaceholder = " Message"
            static let sendingStatePlaceholder = "Sending..."
            static let loadingHistoryStatePlaceholder = "Loading history..."
        }
    }

    // MARK: - Public properties -

    // swiftlint:disable:next implicitly_unwrapped_optional
    var presenter: ChatScreenPresenterInterface!

    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never

        configureMessageCollectionView()
        configureMessageInputBar()
        messagesCollectionView.reloadData()
        updateTitle()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewWillDisappear()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        showMessageTimestampOnSwipeLeft = true
    }

    private func configureMessageInputBar() {
        messageInputBar = CameraInputBarAccessoryView()
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted)

        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        configureInputBarItems()
        inputBarType = .custom(messageInputBar)
        updateInputBarState()
    }

    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16

        configureInputBarPadding()

        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .primaryColor
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
            }
    }

    private func configureInputBarPadding() {
        messageInputBar.padding.bottom = Constants.InputBar.Paddings.bottom
        messageInputBar.middleContentViewPadding.right = Constants.InputBar.Paddings.middleContentRight
        messageInputBar.inputTextView.textContainerInset.bottom = Constants.InputBar.Paddings.textContainerBottom
    }
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

    func updateInputBarState() {
        switch presenter.getInputBarState() {
        case .ready:
            messageInputBar.sendButton.stopAnimating()
            messageInputBar.inputTextView.placeholder = Constants.InputBar.readyStatePlaceholder
            messageInputBar.isUserInteractionEnabled = true
        case .sending:
            messageInputBar.inputTextView.placeholder = Constants.InputBar.sendingStatePlaceholder
            messageInputBar.inputTextView.text = nil
            messageInputBar.sendButton.startAnimating()
            messageInputBar.inputTextView.resignFirstResponder()
            messageInputBar.isUserInteractionEnabled = false
        case .loadingHistory:
            messageInputBar.inputTextView.placeholder = Constants.InputBar.loadingHistoryStatePlaceholder
            messageInputBar.sendButton.startAnimating()
            messageInputBar.isUserInteractionEnabled = false
        }
    }

    func updateTitle() {
        let onlineUsersCount = presenter.onlineUsersCount()
        if onlineUsersCount >= 0 {
            configureTitleView(title: "Chat", subtitle: "\(onlineUsersCount) Online")
        }
    }
}
