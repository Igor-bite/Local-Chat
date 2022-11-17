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
    func receivedMessages(_ messages: [Message])
}

final class ConnectionManager: NSObject {
    static let shared = ConnectionManager()

    private static let service = "nature-chat"
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
    
    private override init() {
        super.init()
        session = .init(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self

        advertiserAssistant = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: nil,
            serviceType: ConnectionManager.service
        )
        advertiserAssistant?.delegate = self

        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ConnectionManager.service)
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

        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ConnectionManager.service)
        nearbyServiceBrowser?.delegate = self
        if isBrowsing {
            startBrowsingForPeers()
        }

        advertiserAssistant = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: nil,
            serviceType: ConnectionManager.service
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

    func sendMessage(mes: Message, to peer: PeerModel) -> Bool {
        do {
            let encoder = JSONEncoder()
            try session?.send(try encoder.encode([MessageDTO(message: mes)]), toPeers: [peer.mcPeer], with: .reliable)
            return true
        } catch {
            DispatchQueue.main.async {
                SPIndicator.present(title: error.localizedDescription, preset: .error)
            }
            return false
        }
    }

    func disconnect() {
        session?.disconnect()
    }
}

extension ConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder = JSONDecoder()
        do {
            let messages = try decoder.decode([MessageDTO].self, from: data)
            sessionDelegate?.receivedMessages(messages.compactMap({ message in
                return Message(messageDTO: message)
            }))
        } catch {
            DispatchQueue.main.async {
                SPIndicator.present(title: error.localizedDescription, preset: .error)
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            discoveryDelegate?.disconnectedFromPeer(.init(mcPeer: peerID))
        case .connecting:
            break
        case .connected:
            discoveryDelegate?.connectedToPeer(.init(mcPeer: peerID))
        @unknown default:
            break
        }
    }
}

extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
}

extension ConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        discoveryDelegate?.peerFound(.init(mcPeer: peerID))
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        discoveryDelegate?.peerLost(.init(mcPeer: peerID))
    }
}

struct MessageDTO: Codable {
    enum Kind: Codable {
        case text(String)
    }
    let messageId: String
    let sentDate: Date
    let kind: Kind
    let user: User

    init?(message: Message) {
        messageId = message.messageId
        sentDate = message.sentDate
        switch message.kind {
        case .text(let text):
            kind = .text(text)
        default:
            return nil
        }
        user = message.user
    }
}
