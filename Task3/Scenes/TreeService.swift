//
//  TreeService.swift
//  Task3
//
//  Created by Игорь Клюжев on 19.11.2022.
//

import UIKit
import SPIndicator

final class TreeService {
    static let treePeerName = "TreePeer"
    private static let messagesFileName = "MessagesFile"
    
    private let connectionManager = ConnectionManager.shared
    private var messages = [Message]()
    private let messagesAccessQueue = DispatchQueue(label: "MessagesChangeQueue")
    private let filesManager = FilesManager()

    init() {
        do {
            let data = try filesManager.read(fileNamed: TreeService.messagesFileName)
            messages = (try? JSONDecoder().decode([MessageDTO].self, from: data))?.map({ dto in
                Message(messageDTO: dto)
            }) ?? []
        } catch {
            SPIndicator.present(title: error.localizedDescription, preset: .error)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(saveMessages), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    func start() {
        connectionManager.changePeerName(to: TreeService.treePeerName)
        connectionManager.sessionDelegate = self
        connectionManager.startAdvertising()
    }

    @objc
    private func saveMessages() {
        guard let data = try? JSONEncoder().encode(
            messages.map({ message in
                MessageDTO(message: message)
            })
        ) else { return }
        do {
            try filesManager.save(fileNamed: TreeService.messagesFileName, data: data)
        } catch {
            SPIndicator.present(title: error.localizedDescription, preset: .error)
        }
    }
}

extension TreeService: ConnectionManagerSessionDelegate {
    func connectedPeersCountUpdated(_ count: Int) {}

    func receivedMessages(_ messages: [Message], from peer: PeerModel) {
        DebugLogger.log(type: .info, message: "\(#function) peer = \(peer.name), messages = \(messages)")
        messagesAccessQueue.async {
            self.messages += messages
        }
    }

    func requestsHistory(peer: PeerModel) {
        DebugLogger.log(type: .info, message: "\(#function) peer = \(peer.name)")
        messagesAccessQueue.async {
            let isSuccess = self.connectionManager.sendMessages(mes: self.messages, to: peer)
            if !isSuccess {
                DebugLogger.log(type: .error, message: "\(#function): Can't send messages")
            }
        }
    }
}
