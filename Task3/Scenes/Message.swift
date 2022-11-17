//
//  ChatScreenInterfaces.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import MessageKit
import UIKit

// MARK: - Message

struct Message: MessageType {
    private init(kind: MessageKind, user: User, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        sentDate = date
    }

    init(messageDTO: MessageDTO) {
        user = messageDTO.user
        messageId = messageDTO.messageId
        sentDate = messageDTO.sentDate
        switch messageDTO.kind {
        case .text(let text):
            kind = .text(text)
        }
    }

    init(custom: Any?, user: User, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }

    init(text: String, user: User, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }

    var messageId: String
    var sentDate: Date
    var kind: MessageKind

    var user: User

    var sender: SenderType {
        user
    }
}
