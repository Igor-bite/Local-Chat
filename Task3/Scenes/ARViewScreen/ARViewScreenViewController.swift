//
//  ARController.swift
//  Task3
//
//  Created by Игорь Клюжев on 18.11.2022.
//

import UIKit
import ARKit
import SnapKit

class ARViewScreenViewController: UIViewController, UINavigationControllerDelegate {

    private let augmentedRealityView = ARSCNView(frame: .zero)

    let configuration = ARWorldTrackingConfiguration()
    let augmentedRealitySession = ARSession()
    let selectedImage: UIImage

    var isPlaced = false

    private lazy var closeButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "xmark.circle.fill")?.scalePreservingAspectRatio(targetSize: .init(width: 50, height: 50)), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()

    init(image: UIImage) {
        self.selectedImage = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        augmentedRealitySession.pause()
        augmentedRealityView.stop(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        setupARSession()
    }

    func setup() {
        view.addSubview(augmentedRealityView)
        view.addSubview(closeButton)

        augmentedRealityView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().inset(20)
            make.width.height.equalTo(50)
        }
    }

    func setupARSession() {
        augmentedRealityView.session = augmentedRealitySession
        augmentedRealityView.delegate = self
        configuration.planeDetection = .vertical
        augmentedRealitySession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    @objc
    private func close() {
        dismiss(animated: true)
    }
}

extension ARViewScreenViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !isPlaced else { return }
        isPlaced = true
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let imageHolder = SCNNode(geometry: SCNPlane(width: width, height: height))
        imageHolder.eulerAngles.x = -.pi/2
        imageHolder.geometry?.firstMaterial?.diffuse.contents = selectedImage
        node.addChildNode(imageHolder)
    }
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }

        return scaledImage
    }
}
