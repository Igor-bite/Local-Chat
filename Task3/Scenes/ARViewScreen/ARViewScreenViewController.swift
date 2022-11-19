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

    var augmentedRealityView = ARSCNView(frame: .zero)

    let configuration = ARWorldTrackingConfiguration()
    let augmentedRealitySession = ARSession()
    let selectedImage: UIImage

    var isPlaced = false

    init(image: UIImage) {
        self.selectedImage = image
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        setupARSession()
    }

    func setup() {
        view.addSubview(augmentedRealityView)

        augmentedRealityView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupARSession() {
        augmentedRealityView.session = augmentedRealitySession
        augmentedRealityView.delegate = self
        configuration.planeDetection = .vertical
        augmentedRealitySession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension ARViewScreenViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !isPlaced else { return }

        isPlaced = true
        //1. Check We Have Detected An ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        //2. Get The Size Of The ARPlaneAnchor
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)

        //3. Create An SCNPlane Which Matches The Size Of The ARPlaneAnchor
        let imageHolder = SCNNode(geometry: SCNPlane(width: width, height: height))

        //4. Rotate It
        imageHolder.eulerAngles.x = -.pi/2

        //5. Set It's Colour To Red
        imageHolder.geometry?.firstMaterial?.diffuse.contents = selectedImage

        //4. Add It To Our Node & Thus The Hiearchy
        node.addChildNode(imageHolder)
    }
}
