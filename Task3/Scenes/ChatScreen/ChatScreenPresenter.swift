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
    private var messageList = [Message(text: "Hello world!", user: .init(senderId: UUID().uuidString, displayName: "Igor"), messageId: UUID().uuidString, date: Date()),
                               Message(text: "Hello world!", user: .init(senderId: UUID().uuidString, displayName: "Igor"), messageId: UUID().uuidString, date: Date())]

    // MARK: - Lifecycle -

    init(
        view: ChatScreenViewInterface,
        wireframe: ChatScreenWireframeInterface
    ) {
        self.view = view
        self.wireframe = wireframe
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
        messageList.append(message)
        view.setInputBarState(.ready)
        view.insertSections([messageList.count - 1]) { _ in
            self.view.scrollToLastItem()
        }
    }
}
