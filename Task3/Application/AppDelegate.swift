//
//  AppDelegate.swift
//  AvitoInternship2022
//
//  Created by Игорь Клюжев on 18.10.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else {
            return false
        }

        let initialController = UINavigationController()
        if SettingsBundleHelper.isTree {
            initialController.setViewControllers([UIViewController()], animated: false)
        } else {
            initialController.setRootWireframe(DiscoveryScreenWireframe())
        }

        window.rootViewController = initialController
        window.makeKeyAndVisible()

        return true
    }
}
