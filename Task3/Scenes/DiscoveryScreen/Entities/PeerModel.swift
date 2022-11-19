//
//  PeerModel.swift
//  Task1
//
//  Created by Игорь Клюжев on 14.11.2022.
//

import Foundation
import MultipeerConnectivity

struct PeerModel: Hashable {
    let id = UUID()
    let mcPeer: MCPeerID

    var name: String {
        mcPeer.displayName
    }

    var isTreePeer: Bool {
        name == TreeService.treePeerName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(mcPeer)
        hasher.combine(id)
    }
}
