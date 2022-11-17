//
//  ChatScreenPresenter.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import Foundation
import MessageKit

final class ChatScreenPresenter {

    // MARK: - Private properties -

    private unowned let view: ChatScreenViewInterface
    private let wireframe: ChatScreenWireframeInterface
    private var messageList = [Message]()

    private let connectionManager = ConnectionManager.shared
    private let peer: PeerModel

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
    }
}

// MARK: - Extensions -

extension ChatScreenPresenter: ChatScreenPresenterInterface {
    var currentSender: User {
        SampleData.shared.currentSender
    }

    func numberOfItems() -> Int {
        messageList.count
    }

    func messageForItem(at indexPath: IndexPath) -> MessageKit.MessageType {
        messageList[indexPath.section]
    }

    func sendMessage(with text: String) {
        view.setInputBarState(.sending)
        let message = Message(text: text, user: currentSender, messageId: UUID().uuidString, date: Date())
        let isSuccess = connectionManager.sendMessage(mes: message, to: peer)
        view.setInputBarState(.ready)
        guard isSuccess else { return }
        messageList.append(message)
        view.insertSections([messageList.count - 1]) { _ in
            self.view.scrollToLastItem()
        }
    }
}

extension ChatScreenPresenter: ConnectionManagerSessionDelegate {
    func receivedMessages(_ messages: [Message]) {
        messageList += messages
        DispatchQueue.main.async {
            let sections = IndexSet(integersIn: (self.messageList.count - messages.count)..<self.messageList.count)
            self.view.insertSections(sections) { _ in
                self.view.scrollToLastItem()
            }
        }
    }
}
