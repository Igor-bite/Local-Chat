//
//  ConnectionManager.swift
//  Task1
//
//  Created by Игорь Клюжев on 09.11.2022.
//

import Foundation
import MultipeerConnectivity
import SPIndicator
import CoreLocation
import MessageKit

protocol ConnectionManagerDiscoveryDelegate: AnyObject {
    func peerFound(_ peer: PeerModel)
    func peerLost(_ peer: PeerModel)
    func connectedToPeer(_ peer: PeerModel)
    func disconnectedFromPeer(_ peer: PeerModel)
}

protocol ConnectionManagerSessionDelegate: AnyObject {
    func receivedMessages(_ messages: [Message], from peer: PeerModel)
    func requestsHistory(peer: PeerModel)
    func connectedPeersCountUpdated(_ count: Int)
}

final class ConnectionManager: NSObject {
    private enum Constants {
        enum Flags: String {
            case history
        }

        static let service = "sosna-chat"
    }

    static let shared = ConnectionManager()

    static let peerNameKey = "PeerNameKey"
    private var myPeerId = MCPeerID(displayName: UserDefaults.standard.string(forKey: ConnectionManager.peerNameKey) ?? UIDevice.current.name)
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    private var nearbyServiceBrowser: MCNearbyServiceBrowser?
    private var session: MCSession?
    weak var discoveryDelegate: ConnectionManagerDiscoveryDelegate?
    weak var sessionDelegate: ConnectionManagerSessionDelegate?

    private var isAdvertising = false
    private var isBrowsing = false
    private var isGettingVoice = false

    private var connectedPeersCount = 0 {
        didSet {
            self.sessionDelegate?.connectedPeersCountUpdated(connectedPeersCount)
        }
    }
    
    private override init() {
        super.init()
        session = .init(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self

        advertiserAssistant = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: nil,
            serviceType: Constants.service
        )
        advertiserAssistant?.delegate = self

        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: Constants.service)
        nearbyServiceBrowser?.delegate = self
    }

    func startAdvertising() {
        advertiserAssistant?.startAdvertisingPeer()
        isAdvertising = true
    }

    func stopAdvertising() {
        advertiserAssistant?.stopAdvertisingPeer()
        isAdvertising = false
    }

    func startBrowsingForPeers() {
        nearbyServiceBrowser?.startBrowsingForPeers()
        isBrowsing = true
    }

    func stopBrowsingForPeers() {
        nearbyServiceBrowser?.stopBrowsingForPeers()
        isBrowsing = false
    }

    func changePeerName(to name: String) {
        if name == UIDevice.current.name {
            UserDefaults.standard.removeObject(forKey: ConnectionManager.peerNameKey)
        } else {
            UserDefaults.standard.set(name, forKey: ConnectionManager.peerNameKey)
        }

        session?.disconnect()
        nearbyServiceBrowser?.stopBrowsingForPeers()
        advertiserAssistant?.stopAdvertisingPeer()
        session = nil
        nearbyServiceBrowser = nil
        advertiserAssistant = nil

        myPeerId = .init(displayName: name)

        session = .init(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self

        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: Constants.service)
        nearbyServiceBrowser?.delegate = self
        if isBrowsing {
            startBrowsingForPeers()
        }

        advertiserAssistant = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: nil,
            serviceType: Constants.service
        )
        advertiserAssistant?.delegate = self
        if isAdvertising {
            startAdvertising()
        }
    }

    func connectTo(_ peer: PeerModel) {
        guard let session = session else { return }
        nearbyServiceBrowser?.invitePeer(peer.mcPeer, to: session, withContext: nil, timeout: 5)
    }

    func sendMessageToAll(mes: Message) -> Bool {
        do {
            let encoder = JSONEncoder()
            try session?.send(try encoder.encode([MessageDTO(message: mes)]), toPeers: session!.connectedPeers, with: .reliable)
            return true
        } catch {
            DispatchQueue.main.async {
                SPIndicator.present(title: error.localizedDescription, preset: .error)
            }
            return false
        }
    }

    func sendMessages(mes: [Message], to peer: PeerModel) -> Bool {
        do {
            let encoder = JSONEncoder()
            let messages = mes.compactMap { message in
                MessageDTO(message: message)
            }
            try session?.send(try encoder.encode(messages), toPeers: [peer.mcPeer], with: .reliable)
            return true
        } catch {
            DispatchQueue.main.async {
                SPIndicator.present(title: error.localizedDescription, preset: .error)
            }
            return false
        }
    }

    func getHistory(from peer: PeerModel) {
        do {
            try session?.send(Constants.Flags.history.rawValue.data(using: .utf8)!, toPeers: [peer.mcPeer], with: .reliable)
        } catch {
            DispatchQueue.main.async {
                SPIndicator.present(title: error.localizedDescription, preset: .error)
            }
        }
    }

    func disconnect() {
        session?.disconnect()
    }

    func connectedPeers() -> [PeerModel] {
        session?.connectedPeers.map { PeerModel(mcPeer: $0) } ?? []
    }
}

extension ConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let str = String(data: data, encoding: .utf8),
           let flag = Constants.Flags(rawValue: str)
        {
            switch flag {
            case .history:
                sessionDelegate?.requestsHistory(peer: .init(mcPeer: peerID))
            }
            return
        }

        decodeMessages(fromData: data, peer: .init(mcPeer: peerID))
    }

    private func decodeMessages(fromData data: Data, peer: PeerModel) {
        let decoder = JSONDecoder()
        do {
            let messages = try decoder.decode([MessageDTO].self, from: data)
            sessionDelegate?.receivedMessages(messages.map({ message in
                Message(messageDTO: message)
            }), from: peer)
        } catch {
            DispatchQueue.main.async {
                SPIndicator.present(title: error.localizedDescription, preset: .error)
            }
        }
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            discoveryDelegate?.disconnectedFromPeer(.init(mcPeer: peerID))
            connectedPeersCount -= 1
        case .connecting:
            break
        case .connected:
            discoveryDelegate?.connectedToPeer(.init(mcPeer: peerID))
            connectedPeersCount += 1
        @unknown default:
            break
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        DispatchQueue.main.async {
            SPIndicator.present(title: error.localizedDescription, preset: .error)
        }
    }
}

extension ConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        discoveryDelegate?.peerFound(.init(mcPeer: peerID))
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        discoveryDelegate?.peerLost(.init(mcPeer: peerID))
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        DispatchQueue.main.async {
            SPIndicator.present(title: error.localizedDescription, preset: .error)
        }
    }
}
