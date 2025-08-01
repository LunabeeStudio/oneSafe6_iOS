//
//  UseCase+WebSiteInformation.swift
//  UseCases
//
//  Created by Lunabee Studio (François Combe) on 18/11/2022 - 14:56.
//  Copyright © 2022 Lunabee Studio. All rights reserved.
//

import UIKit
import Model
import Repositories
import RegexBuilder

public extension UseCase {
    static func initializeTopLevelDomainsCache() {
        Task {
            await favIconRepository.initializeTopLevelDomainsCache()
        }
    }

    static func fetchWebSiteInformation(for url: String?) async throws -> WebsiteInfo? {
        guard let url else { return nil }
        try Task.checkCancellation()
        return try await getWebsiteInfo(urlString: url.lowercased())
    }
}

private extension UseCase {
    static func getWebsiteInfo(urlString: String) async throws -> WebsiteInfo? {
        guard let url = URL(string: urlString.updatingToSecuredUrlStringIfNeeded()) else { return nil }
        guard await isUrlWellFormed(url) else { return nil }

        try Task.checkCancellation()

        let htmlMatch: (html: String, url: URL)? = try await favIconRepository.getHtmlForUrl(url)

        try Task.checkCancellation()

        guard let htmlMatch else { return nil }

        let htmlString: String = htmlMatch.html.replacingOccurrences(of: "><", with: ">\n<")
        guard let htmlHeaders = htmlString.getHtmlHeaders() else { return nil }

        try Task.checkCancellation()
        let matchingUrl: String = htmlMatch.url.absoluteString
        let websiteUrl: String = try parseWebsiteUrl(htmlString: htmlHeaders, htmlUrl: matchingUrl) ?? matchingUrl
        let websiteTitle: String = try parseWebsiteTitle(htmlString: htmlHeaders, websiteUrl: websiteUrl) ?? defaultTitleFrom(urlString: matchingUrl)
        let websiteIconUrl: String? = try await parseWebsiteIcon(htmlString: htmlHeaders, websiteUrl: websiteUrl)
        var icon: UIImage?
        if let urlString = websiteIconUrl {
            if let iconUrl = URL(string: urlString) {
                let data: Data = try await favIconRepository.getData(at: iconUrl)
                let image: UIImage? = UIImage(data: data)
                let resizedImageData: Data? = image?.resizeImage(to: Constant.FavIcon.finalSize).jpegData(compressionQuality: 1.0)
                icon = resizedImageData.flatMap { UIImage(data: $0) }
            }
        }

        try Task.checkCancellation()

        return .init(url: websiteUrl, title: websiteTitle, icon: icon)
    }

    static func isUrlWellFormed(_ url: URL) async -> Bool {
        let urlComponents: [String] = url.absoluteString
            .components(separatedBy: "//")
            .last?
            .components(separatedBy: "/")
            .first?
            .components(separatedBy: ".") ?? []
        guard let topLevelDomain = urlComponents.last else { return false }
        let existingTopLevelDomains: [String] = await favIconRepository.getExistingTopLevelDomains()
        guard existingTopLevelDomains.contains(topLevelDomain) else { return false }
        guard urlComponents.count > 2 || urlComponents.first != "www" else { return false }
        return true
    }
}

// MARK: - Parsing functions -
private extension UseCase {
    struct ImageMetadata {
        let url: String
        let size: CGSize

        var isSquare: Bool { size.width == size.height }
    }

    static func parseWebsiteTitle(htmlString: String, websiteUrl: String) throws -> String? {
        let defaultEndBound: Regex = /".*?>/
        let bounds: [RegexBounds] = [
            .init(start: /<meta.*?property="og:site_name".*?content="/, end: defaultEndBound),
            .init(start: /<meta\s*?content="/, end: /".*?property="og:site_name".*?>/),
            .init(start: /<meta.*?property="og:title".*?content="/, end: defaultEndBound),
            .init(start: /<meta\s*?content="/, end: /".*?property="og:title".*?>/),
            .init(start: /<meta.*?name="title".*?content="/, end: defaultEndBound),
            .init(start: /<meta.*?name="application-name".*?content="/, end: defaultEndBound),
            .init(start: /<meta.*?property="al:ios:app_name".*?content="/, end: defaultEndBound),
            .init(start: /<meta.*?property="al:android:app_name".*?content="/, end: defaultEndBound),
            .init(start: /<title.*?>/, end: /<\/title>/)
        ]
        let foundTitles: [String] = bounds.reduce([]) { $0 + extractValues(from: htmlString, bounds: $1) }.map { $0.cleaningAsWebsiteTitle(websiteUrl: websiteUrl) }
        let titlesMatchingUrls: [String] = foundTitles.filter {
            let stringToTest: String = $0.lowercased()
            let canBeUrlHost: Bool = URLComponents(string: "https://\(stringToTest)")?.host != nil && stringToTest.components(separatedBy: ".").count > 1
            return websiteUrl.lowercased().contains(stringToTest) && !canBeUrlHost
        }
        return foundTitles
            .filter { titlesMatchingUrls.count == 0 ? !$0.isEmpty : !$0.isEmpty && titlesMatchingUrls.contains($0) }
            .min { $0.count < $1.count }
    }

    static func defaultTitleFrom(urlString: String) -> String {
        guard let urlComponents = URLComponents(string: urlString) else { return urlString }
        guard let host = urlComponents.host else { return urlString }
        let hostComponents: [String] = host.components(separatedBy: ".")
        return hostComponents.suffix(3).joined(separator: ".").replacingOccurrences(of: "www.", with: "")
    }

    static func parseWebsiteUrl(htmlString: String, htmlUrl: String) throws -> String? {
        let defaultEndBound: Regex = /".*?>/
        let bounds: [RegexBounds] = [
            .init(start: /<meta.*?property="og:url".*?content="/, end: defaultEndBound),
            .init(start: /<link.*?rel="canonical".*?href="/, end: defaultEndBound),
            .init(start: /<meta.*?property="al:ios:url".*?content="/, end: defaultEndBound),
            .init(start: /<meta.*?property="al:android:url".*?content="/, end: defaultEndBound),
            .init(start: /<meta.*?name="twitter:domain".*?content="/, end: defaultEndBound),
            .init(start: /<link.*?href="/, end: /".*?rel="canonical".*?>/),
            .init(start: /<link.*?rel="alternate".*?href="/, end: defaultEndBound)
        ]
        let foundUrls: [String] = bounds.reduce([]) { $0 + extractValues(from: htmlString, bounds: $1) }
        let filteredUrl: [String] = foundUrls
            .compactMap {
                guard let urlComponents = URLComponents(string: $0) else { return nil }
                guard let scheme = urlComponents.scheme else { return nil }
                guard scheme.hasPrefix("http") else { return nil }
                var updatedComponents: URLComponents = urlComponents
                updatedComponents.host = urlComponents.host ?? urlComponents.path
                updatedComponents.path = ""
                updatedComponents.query = nil
                return updatedComponents.string
            }
            .sorted { $0.count < $1.count }

        let htmlUrlExtension: String = htmlUrl.components(separatedBy: ".").last ?? ""
        let matchingExtensionUrl: String? = filteredUrl.first { $0.hasSuffix(".\(htmlUrlExtension)") }
        return matchingExtensionUrl ?? filteredUrl.first { $0.hasSuffix(".com") } ?? filteredUrl.first
    }

    static func parseWebsiteIcon(htmlString: String, websiteUrl: String) async throws -> String? {
        var foundIconsUrls: [String] = Constant.FavIcon.supportedFavIconsExtensions.reduce([]) { $0 + extractFilesUrls(from: htmlString, fileExtension: $1) }

        if foundIconsUrls.isEmpty {
            let defaultEndBound: Regex = /".*?>/
            let bounds: [RegexBounds] = [
                .init(start: /<link.*?rel="shortcut icon".*?href="/, end: defaultEndBound),
                .init(start: /<link.*?rel="icon".*?href="/, end: defaultEndBound),
                .init(start: /<link.*?rel=icon.*?href=/, end: />/),
                .init(start: /<link.*?rel="apple-touch-icon".*?href="/, end: defaultEndBound),
                .init(start: /<meta.*?property="og:image".*?content="/, end: defaultEndBound),
                .init(start: /<meta.*?property="twitter:image".*?content="/, end: defaultEndBound),
                .init(start: /<link.*?id="favicon".*?href="/, end: defaultEndBound),
                .init(start: /<link.*?rel="alternate icon".*?href="/, end: defaultEndBound),
                .init(start: /<link.*?type="image.*?href="/, end: /".*?rel="shortcut icon".*?>/)
            ]
            foundIconsUrls += bounds.reduce([]) { $0 + extractValues(from: htmlString, bounds: $1) }
        }

        let urlsByPath: [String: [String]] = .init(grouping: foundIconsUrls) {
            URL(fileURLWithPath: $0).deletingLastPathComponent().relativeString
        }
        let fileNamesByPath: [String: [String]] = .init(uniqueKeysWithValues: urlsByPath.map { key, paths in
            var filenames: [String] = paths.map { URL(fileURLWithPath: $0).lastPathComponent }
            filenames = [String](Set(filenames)).sorted { $0.compare($1, options: .numeric) == .orderedAscending }
            var sizesByFilenamePrefix: [String: [String]] = [:]
            filenames.forEach {
                if let sizePart = $0.matches(of: /\d+x\d+\..*$/).first?.output {
                    let filenamePrefix: String = $0.replacingOccurrences(of: sizePart, with: "")
                    sizesByFilenamePrefix[filenamePrefix] = (sizesByFilenamePrefix[filenamePrefix] ?? []) + [String(sizePart)]
                } else {
                    sizesByFilenamePrefix[""] = (sizesByFilenamePrefix[""] ?? []) + [$0]
                }
            }
            let sizeByFilenamePrefix: [String: [String]] = .init(uniqueKeysWithValues: sizesByFilenamePrefix.compactMap { `prefix`, suffixes in
                if `prefix`.isEmpty {
                    return (`prefix`, suffixes)
                } else if let suffix = suffixes.last {
                    return (`prefix`, [suffix])
                } else {
                    return nil
                }
            })
            let paths: [String] = sizeByFilenamePrefix
                .map { filenamePrefix, value in
                    value.map { "\(filenamePrefix)\($0)" }
                }
                .reduce([], +)
            return (key, paths)
        })
        let cleanedUrls: [String] = fileNamesByPath
            .map { key, paths in
                let urlPrefix: String = key.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: ":/", with: "://")
                return paths.map { "\(urlPrefix)\($0)" }
            }
            .reduce([], +)

        var imagesMetadata: [ImageMetadata] = cleanedUrls
            .compactMap {
                let iconUrlString: String
                let fixedUrlString: String = $0.components(separatedBy: "?")[0].injectingUrlSchemeIfPossible()
                guard URL(string: fixedUrlString) != nil else { return nil }
                if fixedUrlString.hasPrefix("http") {
                    iconUrlString = fixedUrlString
                } else {
                    let urlPrefix: String = websiteUrl.updatingToSecuredUrlStringIfNeeded().deletingTrailingSlashIfNeeded()
                    let urlSuffix: String = fixedUrlString.deletingLeadingSlashIfNeeded()
                    iconUrlString = "\(urlPrefix)/\(urlSuffix)"
                }
                guard let url = URL(string: iconUrlString) else { return nil }
                guard let size = sizeOfImageAt(url: url) else { return nil }
                return .init(url: iconUrlString, size: size)
            }
            .sorted { $0.size.height < $1.size.height }

        let squaredImages: [ImageMetadata] = imagesMetadata.filter { $0.isSquare }
        if squaredImages.count > 0 {
            imagesMetadata = squaredImages
        }

        if imagesMetadata.count > 1 {
            // Doing this we remove the lowest icon quality which, most of the time, is 16x16.
            // We can do this only if we have at least 2 icons otherwise we have to keep this lowest quality image to return an icon in any cases.
            imagesMetadata.removeFirst()
        }
        while imagesMetadata.last?.size.height ?? 0.0 > 512 && imagesMetadata.count > 1 {
            imagesMetadata.removeLast()
        }

        let matchingImageMetadata: ImageMetadata? = imagesMetadata.last
        let matchingImageUrlString: String?
        if matchingImageMetadata?.size.width ?? 0.0 <= 32.0 {
            let gstaticUrlString: String = "https://t2.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=\(websiteUrl)&size=256"
            if let gstaticSize = URL(string: gstaticUrlString).flatMap({ sizeOfImageAt(url: $0) }), gstaticSize.width > 32.0 {
                matchingImageUrlString = gstaticUrlString
            } else if let url = URL(string: "https://logo.clearbit.com/\(websiteUrl)"), sizeOfImageAt(url: url) != nil {
                matchingImageUrlString = url.absoluteString
            } else {
                matchingImageUrlString = imagesMetadata.last?.url
            }
        } else {
            matchingImageUrlString = imagesMetadata.last?.url
        }

        return matchingImageUrlString
    }

    static func sizeOfImageAt(url: URL) -> CGSize? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let propertiesOptions: CFDictionary = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else { return nil }
        return (properties[kCGImagePropertyPixelWidth] as? CGFloat).flatMap { width in
            (properties[kCGImagePropertyPixelHeight] as? CGFloat).map { height in
                CGSize(width: width, height: height)
            }
        }
    }
}

// MARK: - Regex functions -
private extension UseCase {
    struct RegexBounds {
        let start: Regex<Substring>
        let end: Regex<Substring>
    }

// swiftlint:disable closure_end_indentation
    static func extractValues(from text: String, bounds: RegexBounds) -> [String] {
        let ref: Reference = .init(Substring.self)
        let regex: Regex = .init {
            bounds.start
            Capture(as: ref) { OneOrMore(/[^">]/, .reluctant) }
            bounds.end
        }
        return text.matches(of: regex).map { String($0[ref]) }
    }

    static func extractFilesUrls(from text: String, fileExtension: String) -> [String] {
        let fileExtension: String = ".\(fileExtension.replacingOccurrences(of: ".", with: ""))"
        let ref: Reference = .init(Substring.self)
        let regex: Regex = .init {
            /=\s*"/
            Capture(as: ref) { ZeroOrMore(/[^"]/, .reluctant) }
            fileExtension
        }
        return text.matches(of: regex).map { String($0[ref]) + fileExtension }
    }
// swiftlint:enable closure_end_indentation
}

// MARK: - String HTML utils -
private extension String {
    var decodedHtmlString: String? { String(htmlEncodedString: self) }

    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        do {
            let attributedString: NSAttributedString = try .init(data: data, options: options, documentAttributes: nil)
            self.init(attributedString.string)
        } catch {
            return nil
        }
    }

    func updatingToSecuredUrlStringIfNeeded() -> String {
        hasPrefix("http") ? replacingOccurrences(of: "http://", with: "https://") : "https://\(self)"
    }

    func deletingLeadingSlashIfNeeded() -> String {
        hasPrefix("/") ? String(suffix(from: index(startIndex, offsetBy: 1))) : self
    }

    func deletingTrailingSlashIfNeeded() -> String {
        hasSuffix("/") ? String(prefix(upTo: index(endIndex, offsetBy: -1))) : self
    }

    func cleaningAsWebsiteTitle(websiteUrl: String) -> String {
        let pipeComponents: [String] = components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let matchingPipeComponent: String = pipeComponents.filter {
            $0.components(separatedBy: " ").reduce(false) { $0 || websiteUrl.lowercased().contains($1.lowercased()) }
        }.first ?? pipeComponents[0]
        let dashComponents: [String] = matchingPipeComponent.components(separatedBy: " - ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let matchingDashComponent: String = dashComponents.filter {
            $0.components(separatedBy: " ").reduce(false) { $0 || websiteUrl.lowercased().contains($1.lowercased()) }
        }.first ?? dashComponents[0]
        let punctuationComponents: [String] = matchingDashComponent.components(separatedBy: CharacterSet(charactersIn: "–:,;"))
        let matchingPunctuationComponents: String = punctuationComponents[0]
        return matchingPunctuationComponents
            .components(separatedBy: CharacterSet(charactersIn: "_ "))
            .prefix(3)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func injectingUrlSchemeIfPossible() -> String {
        hasPrefix("//") ? "https:\(self)" : self
    }

    func getHtmlHeaders() -> String? {
        let headCloseTag: String = "</head>"
        let header: String = components(separatedBy: headCloseTag)[0]
        let headersLines: [String] = header.components(separatedBy: "\n").filter { $0.count < 1000 && !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return headersLines.joined(separator: "\n")
    }
}
