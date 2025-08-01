//
//  UIImage+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 03/02/2023 - 16:20.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit

public extension UIImage {
    func resizeImage(to size: CGSize, onlyIfGreaterThanTargetSize: Bool = false) -> UIImage {
        guard let orientedImage: UIImage = fixOrientationOfImage() else { return self }
        guard (onlyIfGreaterThanTargetSize && (self.size.width > size.width || self.size.height > size.height)) || !onlyIfGreaterThanTargetSize else { return self }
        return orientedImage.resizePreservingAspectRatio(targetSize: size)
    }

    func fixOrientationOfImage() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = .identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(.pi / 2.0))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -CGFloat(.pi / 2.0))
        default:
            break
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue) else {
            return nil
        }

        context.concatenate(transform)

        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            context.draw(self.cgImage!, in: CGRect(origin: .zero, size: self.size))
        }

        // And now we just create a new UIImage from the drawing context
        guard let CGImage = context.makeImage() else { return nil }

        return UIImage(cgImage: CGImage)
    }

    func resizePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let widthRatio: CGFloat = targetSize.width / size.width
        let heightRatio: CGFloat = targetSize.height / size.height

        let scaleFactor: CGFloat = min(widthRatio, heightRatio)
        let scaledImageSize: CGSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        let renderer: UIGraphicsImageRenderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage: UIImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
}
