//
//  DiscoveryScreenViewController.swift
//  Task1
//
//  Created by Игорь Клюжев on 14.11.2022.
//

import UIKit
import SnapKit

final class DiscoveryScreenViewController: UIViewController {

	// swiftlint:disable:next implicitly_unwrapped_optional
    var presenter: DiscoveryScreenPresenterInterface!

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = UIDevice.current.name
        textField.text = UserDefaults.standard.string(forKey: ConnectionManager.peerNameKey)
        return textField
    }()

    private lazy var saveNameButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue.withAlphaComponent(0.5)
        button.layer.cornerRadius = 10
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveNameTapped), for: .touchUpInside)
        return button
    }()

    private lazy var joinButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue.withAlphaComponent(0.5)
        button.layer.cornerRadius = Double(UIScreen.main.bounds.width - 100) / 2.0
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .boldSystemFont(ofSize: 50)
        button.addTarget(self, action: #selector(joinChatTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Chat for nature lovers"
        setup()
        updateJoinChatState(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    private func setup() {
        view.addSubview(nameTextField)
        view.addSubview(saveNameButton)
        view.addSubview(joinButton)

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(saveNameButton.snp.left).inset(10)
        }

        saveNameButton.snp.makeConstraints { make in
            make.centerY.equalTo(nameTextField)
            make.height.equalTo(40)
            make.right.equalToSuperview().inset(15)
            make.width.equalTo((saveNameButton.titleLabel?.intrinsicContentSize.width ?? 0) + 40)
        }

        joinButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(50)
            make.height.equalTo(joinButton.snp.width)
            make.bottom.equalToSuperview().inset(100)
        }
    }

    @objc
    private func saveNameTapped() {
        if let text = nameTextField.text,
           !text.isEmpty
        {
            presenter.changePeerName(to: text)
        } else {
            presenter.changePeerName(to: UIDevice.current.name)
        }
        view.endEditing(true)
    }

    @objc
    private func joinChatTapped() {
        presenter.joinChatButtonTapped()
    }
}

// MARK: - Extensions -

extension DiscoveryScreenViewController: DiscoveryScreenViewInterface {
    func updateJoinChatState(animated: Bool) {
        let state = presenter.joinChatButtonState()
        DispatchQueue.main.async {
            UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0) {
                self.joinButton.backgroundColor = state.bgColor()
                self.joinButton.setTitle(state.buttonTitle(), for: .normal)
            }
        }
    }
}
