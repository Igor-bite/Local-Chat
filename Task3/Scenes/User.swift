//
//  ChatScreenInterfaces.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import Foundation
import MessageKit

struct User: SenderType, Equatable, Codable {
    var senderId: String
    var displayName: String
}
