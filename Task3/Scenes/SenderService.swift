//
//  ChatScreenInterfaces.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import MessageKit
import UIKit

final class SenderService {
    static let shared = SenderService()

    var currentSender: User {
        let name = UserDefaults.standard.string(forKey: ConnectionManager.peerNameKey) ?? UIDevice.current.name
        return .init(senderId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString, displayName: name)
    }
    
    private init() {}
}
