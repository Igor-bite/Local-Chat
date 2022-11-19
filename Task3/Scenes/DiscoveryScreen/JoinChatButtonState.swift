//
//  JoinChatButtonState.swift
//  Task3
//
//  Created by Игорь Клюжев on 19.11.2022.
//

import UIKit

enum JoinChatButtonState {
    case inactive
    case active

    func buttonTitle() -> String {
        switch self {
        case .inactive:
            return "Not Connected"
        case .active:
            return "Join Chat"
        }
    }

    func bgColor() -> UIColor {
        switch self {
        case .inactive:
            return .gray.withAlphaComponent(0.3)
        case .active:
            return .blue.withAlphaComponent(0.5)
        }
    }
    }
