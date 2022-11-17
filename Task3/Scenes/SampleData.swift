//
//  ChatScreenInterfaces.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import AVFoundation
import CoreLocation
import MessageKit
import UIKit

final class SampleData {
    private init() {}

    static let shared = SampleData()

    let system = User(senderId: "000000", displayName: "System")
    let nathan = User(senderId: "000001", displayName: "Nathan Tannar")
    let steven = User(senderId: "000002", displayName: "Steven Deutsch")
    let wu = User(senderId: "000003", displayName: "Wu Zhong")

    lazy var senders = [nathan, steven, wu]
    var currentSender: User {
        steven
    }

    func getAvatarFor(sender: SenderType) -> Avatar {
        return Avatar(image: nil, initials: "IK")
    }
}
