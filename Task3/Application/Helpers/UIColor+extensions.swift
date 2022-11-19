//
//  UIColor+extensions.swift
//  Task3
//
//  Created by Игорь Клюжев on 19.11.2022.
//

import UIKit

extension UIColor {
    static func generateColorFor(text: String) -> UIColor {
        var hash = 0
        let colorConstant = 131
        let maxSafeValue = Int.max / colorConstant
        for char in text.unicodeScalars {
            if hash > maxSafeValue {
                hash /= colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }
        let finalHash = abs(hash) % (256 * 256 * 256)
        let color = UIColor(hue: CGFloat(finalHash) / 255.0, saturation: 0.5, brightness: 0.75, alpha: 1.0)
        return color
    }
}
