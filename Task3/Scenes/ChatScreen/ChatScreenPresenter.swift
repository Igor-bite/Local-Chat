//
//  ChatScreenPresenter.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import Foundation
import MessageKit
import UIKit

final class ChatScreenPresenter {

    // MARK: - Private properties -

    private unowned let view: ChatScreenViewInterface
    private let wireframe: ChatScreenWireframeInterface
    private var messageList = [Message]()

    private let connectionManager = ConnectionManager.shared
    private let peer: PeerModel
    private let messageSendDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    // MARK: - Lifecycle -

    init(
        view: ChatScreenViewInterface,
        wireframe: ChatScreenWireframeInterface,
        peer: PeerModel
    ) {
        self.view = view
        self.wireframe = wireframe
        self.peer = peer
        connectionManager.sessionDelegate = self
        connectionManager.getHistory(from: peer)
    }
}

// MARK: - Extensions -

extension ChatScreenPresenter: ChatScreenPresenterInterface {
    var currentSender: User {
        SenderService.shared.currentSender
    }

    func numberOfItems() -> Int {
        messageList.count
    }

    func messageForItem(at indexPath: IndexPath) -> MessageKit.MessageType {
        messageList[indexPath.section]
    }

    func cellTopLabel(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
            )
        }
        return nil
    }

    func messageTopLabel(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)]
        )
    }

    func messageBottomLabel(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let dateString = messageSendDateFormatter.string(from: message.sentDate)
        return NSAttributedString(
            string: dateString,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2)]
        )
    }

    func sendMessage(withKind kind: MessageKind) {
        view.setInputBarState(.sending)
        var message: Message?//(text: text, user: currentSender, messageId: UUID().uuidString, date: Date())
        switch kind {
        case .text(let text):
            message = Message(text: text, user: currentSender)
        case .photo(let mediaItem):
            guard let image = mediaItem.image else { return }
            message = Message(image: image, user: currentSender)
        default:
            return
        }
        guard let message = message else { return }
        let isSuccess = connectionManager.sendMessageToAll(mes: message)
        view.setInputBarState(.ready)
        guard isSuccess else { return }
        messageList.append(message)
        view.insertSections([messageList.count - 1]) { _ in
            self.view.scrollToLastItem()
        }
    }

    func didTapImage(at indexPath: IndexPath) {
        let message = messageForItem(at: indexPath)
        if case .photo(let media) = message.kind,
           let image = media.image
        {
            wireframe.showARViewScreen(for: image)
        }
    }

    func onlineUsersCount() -> Int {
        return connectionManager.connectedPeers().count - 1
    }

    func viewWillDisappear() {
        connectionManager.disconnect()
    }
}

extension ChatScreenPresenter: ConnectionManagerSessionDelegate {
    func requestsHistory(peer: PeerModel) {
        assertionFailure("History should not be requested from client peer")
    }

    func receivedMessages(_ messages: [Message], from peer: PeerModel) {
        DispatchQueue.main.async {
            self.messageList += messages
            self.messageList = self.messageList.sorted { $0.sentDate < $1.sentDate }
            let sections = IndexSet(integersIn: (self.messageList.count - messages.count)..<self.messageList.count)
            self.view.insertSections(sections) { _ in
                self.view.scrollToLastItem()
            }
        }
    }

    func connectedPeersCountUpdated(_ count: Int) {
        DispatchQueue.main.async {
            self.view.updateTitle()
        }
    }
}
