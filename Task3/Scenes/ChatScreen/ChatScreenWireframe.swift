//
//  ChatScreenWireframe.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import UIKit

final class ChatScreenWireframe: BaseWireframe<ChatScreenViewController> {

    // MARK: - Private properties -

    // MARK: - Module setup -

    init(peer: PeerModel) {
        let moduleViewController = ChatScreenViewController()
        super.init(viewController: moduleViewController)

        let presenter = ChatScreenPresenter(view: moduleViewController, wireframe: self, peer: peer)
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension ChatScreenWireframe: ChatScreenWireframeInterface {
    func showARViewScreen(for image: UIImage) {
        navigationController?.pushViewController(ARViewScreenViewController(image: image), animated: true)
    }
}
