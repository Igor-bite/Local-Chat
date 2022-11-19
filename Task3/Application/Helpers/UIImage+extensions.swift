//
//  UIImage+extensions.swift
//  Task3
//
//  Created by Игорь Клюжев on 19.11.2022.
//

import UIKit
import CoreImage

extension UIImage {
    func blurredImage(with context: CIContext = .init()) -> UIImage? {
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: self)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(60, forKey: kCIInputRadiusKey)

        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")

        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        return processedImage
    }

    static func imageByMergingImages(badgeImage: UIImage, bgImage: UIImage, badgeScale: CGFloat = 1.0) -> UIImage {
        let size = bgImage.size
        let container = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        UIGraphicsGetCurrentContext()!.interpolationQuality = .high
        bgImage.draw(in: container)

        let badgeImageSize = badgeImage.size
        var badgeResultingSize = badgeImageSize
        if size.width > size.height {
            badgeResultingSize = CGSize(width: size.height / 8 / badgeImageSize.height * badgeImageSize.width, height: size.height / 8)
        } else {
            badgeResultingSize = CGSize(width: size.width / 2, height: size.width / 2 / badgeImageSize.width * badgeImageSize.height)
        }
        let badgeWidth = badgeResultingSize.width * badgeScale
        let badgeHeight = badgeResultingSize.height * badgeScale
        let topX = (size.width / 2.0) - (badgeWidth / 2.0)
        let topY = (size.height / 2.0) - (badgeHeight / 2.0)

        badgeImage.draw(in: CGRect(x: topX, y: topY, width: badgeWidth, height: badgeHeight), blendMode: .normal, alpha: 1.0)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
