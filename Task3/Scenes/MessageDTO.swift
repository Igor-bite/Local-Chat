//
//  MessageDTO.swift
//  Task3
//
//  Created by Игорь Клюжев on 19.11.2022.
//

import Foundation

struct MessageDTO: Codable {
    enum Kind: Codable {
        case text(String)
        case image(Data)
    }
    let messageId: String
    let sentDate: Date
    let kind: Kind
    let user: User

    init?(message: Message) {
        messageId = message.messageId
        sentDate = message.sentDate
        switch message.kind {
        case .text(let text):
            kind = .text(text)
        case .photo(let item):
            guard let image = item.image,
                  let imageData = image.pngData()
            else { return nil }
            kind = .image(imageData)
        default:
            return nil
        }
        user = message.user
    }
}
