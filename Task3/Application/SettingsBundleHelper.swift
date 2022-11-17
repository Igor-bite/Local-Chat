//
//  SettingsBundleHelper.swift
//  Task3
//
//  Created by Игорь Клюжев on 17.11.2022.
//

import Foundation

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let isTreeKey = "is_tree"
    }

    static var isTree: Bool {
        UserDefaults.standard.bool(forKey: SettingsBundleKeys.isTreeKey)
    }
}
