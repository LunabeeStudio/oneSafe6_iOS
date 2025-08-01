//
//  String+Extension.swift
//  Extensions
//
//  Created by Lunabee Studio (Nicolas) on 16/03/2023 - 16:48.
//  Copyright © 2023 Lunabee Studio. All rights reserved.
//

import UIKit

// MARK: - Emojis -
public extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }
    var containsEmoji: Bool { contains { $0.isEmoji } }
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    var emojiString: String { emojis.map { String($0) }.reduce("", +) }
    var emojis: [Character] { filter { $0.isEmoji } }
    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
    var isFirstCharacterAnEmoji: Bool { first?.isEmoji ?? false }

    func removingFirstCharacterIfEmoji() -> String {
        isFirstCharacterAnEmoji ? self[1..<count].trimmingCharacters(in: .whitespaces.union(.newlines)) : self
    }

    func removingEmojis() -> String {
        String(filter { !$0.isEmoji }).trimmingCharacters(in: .whitespaces.union(.newlines))
    }

    func makingWhitespacesVisible() -> String {
        replacingOccurrences(of: " ", with: "␣")
    }

    func toImage(height: CGFloat, margin: CGFloat) -> UIImage? {
        let nsString: NSString = (self as NSString)
        let font: UIFont = .systemFont(ofSize: height)
        let stringAttributes: [NSAttributedString.Key: UIFont] = [NSAttributedString.Key.font: font]
        let imageSize: CGSize = nsString.size(withAttributes: stringAttributes)
        let frameSize: CGSize = .init(width: height + 2.0 * margin, height: height + 2.0 * margin)

        UIGraphicsBeginImageContextWithOptions(frameSize, false, 0)
        UIColor.clear.set()
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
        nsString.draw(at: CGPoint(x: (frameSize.width - imageSize.width) / 2.0, y: (frameSize.height - imageSize.height) / 2.0), withAttributes: stringAttributes)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image?.pngData().flatMap { UIImage(data: $0) }
    }
}

// MARK: - Substrings -
public extension String {
    func substring(in range: NSRange) -> String {
        let start: Int = range.lowerBound - 1
        let lowerBound: Int = start >= 0 ? start : 0
        return self[lowerBound..<range.upperBound]
    }

    subscript(_ range: ClosedRange<Int>) -> String {
        let startIndex: Index = index(self.startIndex, offsetBy: range.lowerBound)
        return String(self[startIndex..<index(startIndex, offsetBy: range.count)])
    }

    subscript(_ range: Range<Int>) -> String {
        let startIndex: Index = index(self.startIndex, offsetBy: range.lowerBound)
        return String(self[startIndex..<index(startIndex, offsetBy: range.count)])
    }

    subscript(safe range: ClosedRange<Int>) -> String? {
        guard count > range.upperBound else { return nil }
        let startIndex: Index = index(self.startIndex, offsetBy: range.lowerBound)
        return String(self[startIndex..<index(startIndex, offsetBy: range.count)])
    }

    subscript(safe range: Range<Int>) -> String? {
        guard count > range.upperBound else { return nil }
        let startIndex: Index = index(self.startIndex, offsetBy: range.lowerBound)
        return String(self[startIndex..<index(startIndex, offsetBy: range.count)])
    }
}

// MARK: - Keywords -
public extension String {
    var keywords: [String] {
        components(separatedBy: CharacterSet(charactersIn: ", ")).compactMap {
            guard $0.count > 1 else { return nil }
            return $0.cleanedForSearch
        }
    }

    var cleanedForSearch: String {
        lowercased().folding(options: .diacriticInsensitive, locale: nil)
    }
}
