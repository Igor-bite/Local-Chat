//
//  DiscoveryScreenPresenter.swift
//  Task1
//
//  Created by Игорь Клюжев on 14.11.2022.
//

import Foundation
import GradientLoadingBar

final class DiscoveryScreenPresenter {

    private unowned let view: DiscoveryScreenViewInterface
    private let wireframe: DiscoveryScreenWireframeInterface
    private var treePeer: PeerModel? {
        didSet {
            view.updateJoinChatState(animated: true)
        }
    }
    
    private let connectionManager = ConnectionManager.shared
    private var isAdvertising = false
    private var isJoined = false
    private let gradientLoadingVar = GradientLoadingBar()

    init(
        view: DiscoveryScreenViewInterface,
        wireframe: DiscoveryScreenWireframeInterface
    ) {
        self.view = view
        self.wireframe = wireframe

        connectionManager.discoveryDelegate = self
        connectionManager.startBrowsingForPeers()
    }
}

// MARK: - Extensions -

extension DiscoveryScreenPresenter: DiscoveryScreenPresenterInterface {
    func joinChatButtonState() -> JoinChatButtonState {
        treePeer == nil ? .inactive : .active
    }

    func joinChatButtonTapped() {
        guard let peer = treePeer else { return }
        connectionManager.connectTo(peer)
        gradientLoadingVar.fadeIn()
    }

    func changePeerName(to name: String) {
        connectionManager.changePeerName(to: name)
    }
}

extension DiscoveryScreenPresenter: ConnectionManagerDiscoveryDelegate {
    func peerFound(_ peer: PeerModel) {
        if peer.isTreePeer {
            treePeer = peer
        }
    }

    func peerLost(_ peer: PeerModel) {
        if peer.isTreePeer {
            treePeer = nil
        }
    }

    func connectedToPeer(_ peer: PeerModel) {
        gradientLoadingVar.fadeOut()
        guard peer.isTreePeer else { return }
        DispatchQueue.main.async {
            self.wireframe.openChatScreen(withPeer: peer)
        }
        connectionManager.stopBrowsingForPeers()
    }

    func disconnectedFromPeer(_ peer: PeerModel) {
        guard peer.isTreePeer else { return }
        connectionManager.startBrowsingForPeers()
        view.updateJoinChatState(animated: false)
        DispatchQueue.main.async {
            self.wireframe.showIndicator(withTitle: "Connection aborted", message: nil, preset: .error)
            self.wireframe.dismissChatScreen()
        }
    }
}

