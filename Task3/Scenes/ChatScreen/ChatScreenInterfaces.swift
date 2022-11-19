//
//  ChatScreenInterfaces.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import UIKit
import MessageKit

protocol ChatScreenWireframeInterface: WireframeInterface {
    func showARViewScreen(for image: UIImage)
}

protocol ChatScreenViewInterface: ViewInterface {
    func reloadData()
    func insertSections(_ sections: IndexSet, completion: @escaping (Bool) -> Void)
    func scrollToLastItem()
    func setInputBarState(_ state: InputBarState)
    func updateTitle()
}

protocol ChatScreenPresenterInterface: PresenterInterface {
    var currentSender: User { get }
    func numberOfItems() -> Int
    func messageForItem(at indexPath: IndexPath) -> MessageType
    func cellTopLabel(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString?
    func messageTopLabel(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString?
    func messageBottomLabel(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString?
    func sendMessage(withKind kind: MessageKind)
    func didTapImage(at indexPath: IndexPath)
    func onlineUsersCount() -> Int
    func viewWillDisappear()
}

extension UIColor {
    static let primaryColor = UIColor(red: 69 / 255, green: 193 / 255, blue: 89 / 255, alpha: 1)
}
