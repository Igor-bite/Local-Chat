//
//  DiscoveryScreenInterfaces.swift
//  Task1
//
//  Created by Игорь Клюжев on 14.11.2022.
//

import UIKit

protocol DiscoveryScreenWireframeInterface: WireframeInterface {
    func openChatScreen(withPeer peer: PeerModel)
    func dismissChatScreen()
}

protocol DiscoveryScreenViewInterface: ViewInterface {
    func updateJoinChatState(animated: Bool)
}

protocol DiscoveryScreenPresenterInterface: PresenterInterface {
    func joinChatButtonTapped()
    func joinChatButtonState() -> JoinChatButtonState
    func changePeerName(to name: String)
}
