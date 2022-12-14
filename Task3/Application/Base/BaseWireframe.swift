import UIKit
import SPIndicator

protocol WireframeInterface: AnyObject {
    func showIndicator(withTitle title: String, message: String?, preset: SPIndicatorIconPreset)
}

extension WireframeInterface {
    func showIndicator(withTitle title: String,
                       message: String? = nil,
                       preset: SPIndicatorIconPreset) {
        SPIndicator.present(title: title, message: message, preset: preset)
    }
}

class BaseWireframe<ViewController> where ViewController: UIViewController {
    private weak var _viewController: ViewController?

    // We need it in order to retain the view controller reference upon first access
    private var temporaryStoredViewController: ViewController?

    init(viewController: ViewController) {
        temporaryStoredViewController = viewController
        _viewController = viewController
    }
}

extension BaseWireframe: WireframeInterface {}

extension BaseWireframe {
    var viewController: ViewController {
        defer { temporaryStoredViewController = nil }
        guard let viewController = _viewController else {
            assertionFailure("Incorrect state: _viewController must be initialized")
            return ViewController()
        }
        return viewController
    }

    var navigationController: UINavigationController? {
        viewController.navigationController
    }
}

extension UIViewController {
    func presentWireframe<ViewController>(_ wireframe: BaseWireframe<ViewController>,
                                          animated: Bool = true, completion: (() -> Void)? = nil)
    {
        present(wireframe.viewController, animated: animated, completion: completion)
    }
}

extension UINavigationController {
    func pushWireframe<ViewController>(_ wireframe: BaseWireframe<ViewController>, animated: Bool = true) {
        pushViewController(wireframe.viewController, animated: animated)
    }

    func setRootWireframe<ViewController>(_ wireframe: BaseWireframe<ViewController>, animated: Bool = true) {
        setViewControllers([wireframe.viewController], animated: animated)
    }
}
