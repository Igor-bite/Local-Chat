//
//  AvatarGenerator.swift
//  Task3
//
//  Created by Игорь Клюжев on 19.11.2022.
//

import UIKit
import MessageKit

final class AvatarGenerator {
    static func getAvatar(forSender sender: SenderType) -> (Avatar, UIColor) {
        let name = sender.displayName
        let parts = name.split(separator: " ")
        let first = parts[0].first ?? "?"
        var second = ""
        if parts.count > 1,
           let initial = parts[1].first
        {
            second = String(initial)
        }
        let color = UIColor.generateColorFor(text: name)
        return (Avatar(image: nil, initials: "\(first)\(second)".uppercased()), color)
    }
}
