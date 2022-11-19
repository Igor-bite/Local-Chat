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
        case .image(let imageData):
            let image = UIImage(data: imageData)
            kind = .photo(ImageMediaItem(image: image))
        }
    }

    init(image: UIImage, user: User, messageId: String = UUID().uuidString, date: Date = .init()) {
        self.init(kind: .photo(ImageMediaItem(image: image)), user: user, messageId: messageId, date: date)
    }

    init(text: String, user: User, messageId: String = UUID().uuidString, date: Date = .init()) {
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

struct ImageMediaItem: MediaItem {
    let url: URL?
    let image: UIImage?
    let placeholderImage: UIImage
    let size: CGSize

    init(image: UIImage?) {
        self.image = image
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage(named: "image_message_placeholder")!
        url = nil
    }
}
