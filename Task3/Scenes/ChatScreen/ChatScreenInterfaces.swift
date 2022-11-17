//
//  ChatScreenInterfaces.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import UIKit
import MessageKit

protocol ChatScreenWireframeInterface: WireframeInterface {}

protocol ChatScreenViewInterface: ViewInterface {
    func reloadData()
    func insertSections(_ sections: IndexSet, completion: @escaping (Bool) -> Void)
    func scrollToLastItem()
    func setInputBarState(_ state: InputBarState)
}

protocol ChatScreenPresenterInterface: PresenterInterface {
    var currentSender: User { get }
    func numberOfItems() -> Int
    func messageForItem(at indexPath: IndexPath) -> MessageType
    func sendMessage(with text: String)
}

extension UIColor {
    static let primaryColor = UIColor(red: 69 / 255, green: 193 / 255, blue: 89 / 255, alpha: 1)
}
