import Foundation

enum ImageEncodingProfile: String, Codable, CaseIterable {
    case photo
    case graphic
    case lineArt = "line-art"
    case lossless
}

struct ImageOptimizationConfiguration: Decodable, Equatable {
    let overrides: [String: ImageEncodingProfile]

    static let empty = ImageOptimizationConfiguration(overrides: [:])

    static func load(from url: URL) throws -> ImageOptimizationConfiguration {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ImageOptimizationConfiguration.self, from: data)
    }
}

struct ImageMetadata: Equatable {
    let pixelWidth: Int
    let pixelHeight: Int
    let format: String
    let channels: String

    var hasAlpha: Bool {
        channels.lowercased().contains("a")
    }
}

struct ImageDerivative: Equatable {
    let pixelWidth: Int
    let webPath: String
    let fileURL: URL
}

struct OptimizedImageAsset: Equatable {
    let sourcePath: String
    let metadata: ImageMetadata
    let profile: ImageEncodingProfile
    let derivatives: [ImageDerivative]
}

private struct ImageOptimizationWorkResult {
    let asset: OptimizedImageAsset
    let originalBytes: Int64
    let derivativeBytes: Int64
}

private final class ImageOptimizationAccumulator: @unchecked Sendable {
    private let lock = NSLock()
    private var storedResults: [ImageOptimizationWorkResult] = []
    private var storedError: Error?

    var hasFailed: Bool {
        lock.lock()
        defer { lock.unlock() }
        return storedError != nil
    }

    var firstError: Error? {
        lock.lock()
        defer { lock.unlock() }
        return storedError
    }

    var results: [ImageOptimizationWorkResult] {
        lock.lock()
        defer { lock.unlock() }
        return storedResults
    }

    func append(_ result: ImageOptimizationWorkResult) -> Int {
        lock.lock()
        defer { lock.unlock() }
        storedResults.append(result)
        return storedResults.count
    }

    func record(error: Error) {
        lock.lock()
        defer { lock.unlock() }
        if storedError == nil {
            storedError = error
        }
    }
}

enum ImageOptimizationError: LocalizedError {
    case missingTool(String, installation: String)
    case commandFailed(command: String, output: String)
    case invalidMetadata(path: String, output: String)
    case missingSource(String)
    case invalidGeneratedHTML(path: String, problem: String)
    case missingGeneratedAsset(String)

    var errorDescription: String? {
        switch self {
        case let .missingTool(tool, installation):
            "Missing required image optimisation tool '\(tool)'. \(installation) "
                + "Set SKIP_IMAGE_OPTIMIZATION=1 only for an intentionally unoptimised local build."
        case let .commandFailed(command, output):
            "Image optimisation command failed: \(command)\n\(output)"
        case let .invalidMetadata(path, output):
            "Could not read image metadata for \(path). identify returned: \(output)"
        case let .missingSource(path):
            "Generated HTML references a local image that does not exist: \(path)"
        case let .invalidGeneratedHTML(path, problem):
            "Image validation failed in \(path): \(problem)"
        case let .missingGeneratedAsset(path):
            "Generated HTML references a missing optimised image: \(path)"
        }
    }
}

struct ImageOptimizationToolchain {
    let cwebp: URL
    let identify: URL
    let convert: URL

    static func locate(environment: [String: String] = ProcessInfo.processInfo.environment) throws -> Self {
        let pathEntries = environment["PATH", default: ""]
            .split(separator: ":")
            .map(String.init)

        func executable(named name: String) -> URL? {
            for directory in pathEntries {
                let candidate = URL(fileURLWithPath: directory).appendingPathComponent(name)
                if FileManager.default.isExecutableFile(atPath: candidate.path) {
                    return candidate
                }
            }
            return nil
        }

        guard let cwebp = executable(named: "cwebp") else {
            throw ImageOptimizationError.missingTool(
                "cwebp",
                installation: "Install WebP tools with 'brew install webp' on macOS or 'apt-get install webp' on Ubuntu."
            )
        }

        guard let identify = executable(named: "identify"),
              let convert = executable(named: "convert") else {
            throw ImageOptimizationError.missingTool(
                "ImageMagick",
                installation: "Install it with 'brew install imagemagick' on macOS or 'apt-get install imagemagick' on Ubuntu."
            )
        }

        return Self(cwebp: cwebp, identify: identify, convert: convert)
    }
}

enum ImageOptimizationPolicy {
    static let appFeatureImageClass = "app-feature-image"
    static let standardWidths = [400, 800, 1200, 1440]
    static let appIconWidths = [96, 192, 264, 396]
    static let navigationLogoWidths = [64, 128]
    static let footerLogoWidths = [32, 64]

    static func profile(
        for sourcePath: String,
        metadata: ImageMetadata,
        configuration: ImageOptimizationConfiguration
    ) -> ImageEncodingProfile {
        if let override = configuration.overrides[sourcePath] {
            return override
        }

        let lowercasedPath = sourcePath.lowercased()
        if isLineArt(sourcePath) {
            return .lineArt
        }

        if isNavigationLogo(sourcePath)
            || isAppIcon(sourcePath)
            || lowercasedPath.hasSuffix("/swift-for-swifts-small.png")
            || (metadata.hasAlpha && sourcePath.contains("/Images/Site/Global/")) {
            return .lossless
        }

        switch metadata.format.uppercased() {
        case "JPEG", "JPG", "WEBP":
            return .photo
        default:
            return .graphic
        }
    }

    static func cwebpArguments(for profile: ImageEncodingProfile) -> [String] {
        let encodingArguments: [String]
        switch profile {
        case .photo:
            encodingArguments = ["-q", "95", "-sharp_yuv"]
        case .graphic:
            encodingArguments = ["-near_lossless", "90"]
        case .lineArt:
            encodingArguments = ["-lossless", "-z", "6", "-exact"]
        case .lossless:
            encodingArguments = ["-lossless", "-z", "9", "-exact"]
        }

        // ICC is the only source metadata retained. It is required for wide-gamut
        // photographs, while EXIF and XMP remain excluded from public derivatives.
        return encodingArguments + ["-metadata", "icc"]
    }

    static func targetWidths(for sourcePath: String, sourceWidth: Int) -> [Int] {
        let proposedWidths: [Int]
        if isNavigationLogo(sourcePath) {
            proposedWidths = navigationLogoWidths
        } else if isAppIcon(sourcePath) {
            proposedWidths = appIconWidths
        } else if sourcePath.lowercased().hasSuffix("/swift-for-swifts-small.png") {
            proposedWidths = footerLogoWidths
        } else {
            proposedWidths = standardWidths
        }

        var widths = proposedWidths.filter { $0 <= sourceWidth }
        if widths.isEmpty {
            widths = [sourceWidth]
        } else if let largest = widths.last, largest < sourceWidth, sourceWidth < (proposedWidths.last ?? sourceWidth) {
            widths.append(sourceWidth)
        }
        return Array(Set(widths)).sorted()
    }

    static func isNavigationLogo(_ sourcePath: String) -> Bool {
        let filename = URL(fileURLWithPath: sourcePath).lastPathComponent.lowercased()
        return sourcePath.contains("/Images/Site/Global/")
            && ["logo.png", "logo-dark.png", "logodarkmode.png"].contains(filename)
    }

    static func isAppIcon(_ sourcePath: String) -> Bool {
        let filename = URL(fileURLWithPath: sourcePath).lastPathComponent.lowercased()
        return sourcePath.contains("/Images/Site/Apps/") && filename.hasSuffix("icon.png")
    }

    static func isLineArt(_ sourcePath: String) -> Bool {
        let path = sourcePath.lowercased()
        return path.hasPrefix("/images/365daysiosaccessibility/")
            || path.hasPrefix("/images/posts/2021-01-21-01/")
            || path.hasPrefix("/images/posts/2024-12-06-01/")
            || path == "/images/posts/2026-02-22-01/retrorapidwatch.png"
    }
}

struct ImageHTMLRewriter {
    static let imagePattern = try! NSRegularExpression(
        pattern: #"<img\b[^>]*>"#,
        options: [.caseInsensitive]
    )
    private static let linkPattern = try! NSRegularExpression(
        pattern: #"<link\b[^>]*>"#,
        options: [.caseInsensitive]
    )
    private static let bodyPattern = try! NSRegularExpression(
        pattern: #"<body\b[^>]*>"#,
        options: [.caseInsensitive]
    )

    let assets: [String: OptimizedImageAsset]
    let faviconPath: String
    let searchFaviconPath: String
    let appleTouchIconPath: String

    func rewrite(_ html: String) throws -> String {
        var result = html
        let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
        let matches = Self.imagePattern.matches(in: html, range: fullRange)
        let mainContentLocation: Int
        if let mainContentIndex = html.range(of: #"id="main-content""#)?.lowerBound {
            mainContentLocation = html.distance(from: html.startIndex, to: mainContentIndex)
        } else {
            mainContentLocation = 0
        }
        let pagePath = Self.currentPagePath(in: html)
        let isPostContentPage = pagePath.hasPrefix("/post/")
            || pagePath.range(of: #"^/365-days-ios-accessibility/day-[0-9]+$"#, options: .regularExpression) != nil

        let meaningfulMatch: NSTextCheckingResult?
        if isPostContentPage {
            meaningfulMatch = nil
        } else {
            meaningfulMatch = matches.first { match in
                guard match.range.location > mainContentLocation,
                      let range = Range(match.range, in: html) else { return false }
                let tag = String(html[range])
                guard let source = Self.attributeValue("src", in: tag), Self.isLocalImagePath(source) else {
                    return false
                }
                return !Self.isNavigationLogoTag(tag)
                    && !source.lowercased().hasSuffix("/swift-for-swifts-small.png")
            }
        }

        for match in matches.reversed() {
            guard let range = Range(match.range, in: html) else { continue }
            let tag = String(html[range])
            guard !tag.contains("data-image-optimized=\"true\""),
                  let source = Self.attributeValue("src", in: tag),
                  Self.isLocalImagePath(source) else { continue }

            let canonicalPath = Self.canonicalImagePath(source)
            guard let asset = assets[canonicalPath] else {
                throw ImageOptimizationError.missingSource(canonicalPath)
            }

            let isMeaningful = meaningfulMatch?.range == match.range
            let replacement = optimizedMarkup(
                for: tag,
                asset: asset,
                isMeaningful: isMeaningful,
                isPostContentPage: isPostContentPage
            )
            guard let resultRange = Range(match.range, in: result) else { continue }
            result.replaceSubrange(resultRange, with: replacement)
        }

        return rewriteIconLinks(in: result)
    }

    private func optimizedMarkup(
        for originalTag: String,
        asset: OptimizedImageAsset,
        isMeaningful: Bool,
        isPostContentPage: Bool
    ) -> String {
        var imageTag = originalTag
        imageTag = Self.settingAttribute("width", value: String(asset.metadata.pixelWidth), in: imageTag)
        imageTag = Self.settingAttribute("height", value: String(asset.metadata.pixelHeight), in: imageTag)
        imageTag = Self.settingAttribute("decoding", value: "async", in: imageTag)
        imageTag = Self.settingAttribute("data-image-optimized", value: "true", in: imageTag)

        let sourcePath = asset.sourcePath.lowercased()
        let isNavigationLogo = Self.isNavigationLogoTag(imageTag)
        let isFooterLogo = sourcePath.hasSuffix("/swift-for-swifts-small.png")

        if isMeaningful {
            imageTag = Self.settingAttribute("loading", value: "eager", in: imageTag)
            imageTag = Self.settingAttribute("fetchpriority", value: "high", in: imageTag)
        } else if isNavigationLogo || isFooterLogo {
            imageTag = Self.settingAttribute("loading", value: "eager", in: imageTag)
            imageTag = Self.removingAttribute("fetchpriority", in: imageTag)
        } else {
            imageTag = Self.settingAttribute("loading", value: "lazy", in: imageTag)
            imageTag = Self.settingAttribute("fetchpriority", value: "low", in: imageTag)
        }

        let sizes = Self.sizesValue(
            for: imageTag,
            sourcePath: asset.sourcePath,
            isPostContentPage: isPostContentPage
        )
        let sourceSet = asset.derivatives
            .sorted { $0.pixelWidth < $1.pixelWidth }
            .map { "\($0.webPath) \($0.pixelWidth)w" }
            .joined(separator: ", ")

        var pictureClasses = "responsive-picture"
        let imageClasses = Self.attributeTokens("class", in: imageTag)
        if imageClasses.contains("logo-light") {
            pictureClasses += " logo-light-picture"
        } else if imageClasses.contains("logo-dark") {
            pictureClasses += " logo-dark-picture"
        }
        for layoutClass in imageClasses where Self.shouldPropagateToPicture(layoutClass) {
            pictureClasses += " \(layoutClass)"
        }

        return "<picture class=\"\(pictureClasses)\" data-image-source=\"\(asset.sourcePath)\">"
            + "<source type=\"image/webp\" srcset=\"\(sourceSet)\" sizes=\"\(sizes)\" />"
            + imageTag
            + "</picture>"
    }

    private func rewriteIconLinks(in html: String) -> String {
        var result = html
        let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
        let matches = Self.linkPattern.matches(in: html, range: fullRange)

        for match in matches.reversed() {
            guard let range = Range(match.range, in: html) else { continue }
            let tag = String(html[range])
            let relationTokens = Self.attributeTokens("rel", in: tag).map { $0.lowercased() }
            let isAppleTouchIcon = relationTokens.contains("apple-touch-icon")
                || relationTokens.contains("apple-touch-icon-precomposed")
            let isIcon = relationTokens.contains("icon")
            guard isAppleTouchIcon || isIcon else { continue }

            if isIcon, Self.attributeValue("href", in: tag) == searchFaviconPath {
                continue
            }

            var replacement = tag
            if isAppleTouchIcon {
                replacement = Self.settingAttribute("href", value: appleTouchIconPath, in: replacement)
                replacement = Self.settingAttribute("sizes", value: "180x180", in: replacement)
            } else {
                replacement = Self.settingAttribute("href", value: faviconPath, in: replacement)
                replacement = Self.settingAttribute("sizes", value: "32x32", in: replacement)
            }
            replacement = Self.settingAttribute("type", value: "image/png", in: replacement)

            guard let resultRange = Range(match.range, in: result) else { continue }
            result.replaceSubrange(resultRange, with: replacement)
        }

        if !result.contains(searchFaviconPath), let headEnd = result.range(of: "</head>", options: .caseInsensitive) {
            let searchLink = "<link rel=\"icon\" href=\"\(searchFaviconPath)\" sizes=\"96x96\" type=\"image/png\" />"
            result.insert(contentsOf: searchLink, at: headEnd.lowerBound)
        }
        return result
    }

    static func sizesValue(for tag: String, sourcePath: String, isPostContentPage: Bool = false) -> String {
        if isNavigationLogoTag(tag) {
            return "64px"
        }
        if sourcePath.lowercased().hasSuffix("/swift-for-swifts-small.png") {
            return "32px"
        }
        if ImageOptimizationPolicy.isAppIcon(sourcePath) {
            if let style = attributeValue("style", in: tag),
               let width = firstPixelWidth(in: style) {
                return "\(width)px"
            }
            return "132px"
        }
        let imageClasses = attributeTokens("class", in: tag)
        if imageClasses.contains("card-img-top") || imageClasses.contains(ImageOptimizationPolicy.appFeatureImageClass) {
            return "(min-width: 1400px) 416px, (min-width: 768px) 33vw, calc(100vw - 40px)"
        }
        if isPostContentPage {
            return "(min-width: 744px) 720px, calc(100vw - 24px)"
        }
        return "(min-width: 768px) 50vw, calc(100vw - 40px)"
    }

    static func attributeValue(_ name: String, in tag: String) -> String? {
        let escapedName = NSRegularExpression.escapedPattern(for: name)
        let regex = try! NSRegularExpression(
            pattern: #"\s+"# + escapedName + #"\s*=\s*(?:\"([^\"]*)\"|'([^']*)'|([^\s>]+))"#,
            options: [.caseInsensitive]
        )
        let range = NSRange(tag.startIndex..<tag.endIndex, in: tag)
        guard let match = regex.firstMatch(in: tag, range: range) else { return nil }
        for captureIndex in 1...3 where match.range(at: captureIndex).location != NSNotFound {
            if let valueRange = Range(match.range(at: captureIndex), in: tag) {
                return String(tag[valueRange])
            }
        }
        return nil
    }

    static func attributeTokens(_ name: String, in tag: String) -> [String] {
        attributeValue(name, in: tag)?
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init) ?? []
    }

    static func canonicalImagePath(_ source: String) -> String {
        let withoutFragment = source.split(separator: "#", maxSplits: 1).first.map(String.init) ?? source
        let withoutQuery = withoutFragment.split(separator: "?", maxSplits: 1).first.map(String.init) ?? withoutFragment
        return withoutQuery.removingPercentEncoding ?? withoutQuery
    }

    static func isLocalImagePath(_ source: String) -> Bool {
        canonicalImagePath(source).hasPrefix("/Images/")
            && !canonicalImagePath(source).hasPrefix("/Images/Optimized/")
    }

    static func isNavigationLogoTag(_ tag: String) -> Bool {
        let classes = attributeTokens("class", in: tag)
        return classes.contains("site-logo") || classes.contains("logo-light") || classes.contains("logo-dark")
    }

    private static func currentPagePath(in html: String) -> String {
        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        guard let match = bodyPattern.firstMatch(in: html, range: range),
              let bodyRange = Range(match.range, in: html) else { return "" }
        return attributeValue("data-current-page", in: String(html[bodyRange])) ?? ""
    }

    static func settingAttribute(_ name: String, value: String, in tag: String) -> String {
        let result = removingAttribute(name, in: tag)
        let insertion: String.Index
        if let selfClosing = result.range(of: "/>", options: .backwards) {
            insertion = selfClosing.lowerBound
        } else if let closing = result.range(of: ">", options: .backwards) {
            insertion = closing.lowerBound
        } else {
            return result
        }
        let prefix = result[..<insertion].trimmingCharacters(in: .whitespaces)
        let suffix = result[insertion...]
        return prefix + " \(name)=\"\(value)\"" + suffix
    }

    static func removingAttribute(_ name: String, in tag: String) -> String {
        let escapedName = NSRegularExpression.escapedPattern(for: name)
        let regex = try! NSRegularExpression(
            pattern: #"\s+"# + escapedName + #"(?:\s*=\s*(?:\"[^\"]*\"|'[^']*'|[^\s>]+))?"#,
            options: [.caseInsensitive]
        )
        let range = NSRange(tag.startIndex..<tag.endIndex, in: tag)
        return regex.stringByReplacingMatches(in: tag, range: range, withTemplate: "")
    }

    private static func firstPixelWidth(in style: String) -> Int? {
        let regex = try! NSRegularExpression(pattern: #"\bwidth\s*:\s*([0-9]+)px"#, options: [.caseInsensitive])
        let range = NSRange(style.startIndex..<style.endIndex, in: style)
        guard let match = regex.firstMatch(in: style, range: range),
              let widthRange = Range(match.range(at: 1), in: style) else { return nil }
        return Int(style[widthRange])
    }

    private static func shouldPropagateToPicture(_ className: String) -> Bool {
        className.hasPrefix("align-self-")
            || ["mx-auto", "ms-auto", "me-auto"].contains(className)
    }
}

enum GeneratedImageValidator {
    private static let picturePattern = try! NSRegularExpression(
        pattern: #"<picture\b[^>]*>[\s\S]*?</picture>"#,
        options: [.caseInsensitive]
    )
    private static let sourcePattern = try! NSRegularExpression(
        pattern: #"<source\b[^>]*>"#,
        options: [.caseInsensitive]
    )
    private static let linkPattern = try! NSRegularExpression(
        pattern: #"<link\b[^>]*>"#,
        options: [.caseInsensitive]
    )

    static func validate(htmlFiles: [URL], buildDirectory: URL) throws {
        for htmlFile in htmlFiles {
            let html = try String(contentsOf: htmlFile, encoding: .utf8)
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            let imageMatches = ImageHTMLRewriter.imagePattern.matches(in: html, range: range)
            let localImageMatches = imageMatches.filter { match in
                guard let tagRange = Range(match.range, in: html) else { return false }
                let tag = String(html[tagRange])
                guard let source = ImageHTMLRewriter.attributeValue("src", in: tag) else { return false }
                return ImageHTMLRewriter.canonicalImagePath(source).hasPrefix("/Images/")
            }
            let responsivePictures = picturePattern.matches(in: html, range: range).filter { match in
                guard let pictureRange = Range(match.range, in: html),
                      let openingEnd = html[pictureRange].firstIndex(of: ">") else { return false }
                let openingTag = String(html[pictureRange.lowerBound...openingEnd])
                return ImageHTMLRewriter.attributeTokens("class", in: openingTag).contains("responsive-picture")
            }

            for match in localImageMatches {
                guard let tagRange = Range(match.range, in: html) else { continue }
                let tag = String(html[tagRange])
                guard let source = ImageHTMLRewriter.attributeValue("src", in: tag) else { continue }
                let canonicalSource = ImageHTMLRewriter.canonicalImagePath(source)

                guard let widthValue = ImageHTMLRewriter.attributeValue("width", in: tag),
                      let width = Int(widthValue), width > 0,
                      let heightValue = ImageHTMLRewriter.attributeValue("height", in: tag),
                      let height = Int(heightValue), height > 0 else {
                    throw invalid(htmlFile, "local image has invalid intrinsic dimensions: \(tag)")
                }
                guard ImageHTMLRewriter.attributeValue("decoding", in: tag)?.lowercased() == "async" else {
                    throw invalid(htmlFile, "local image must use decoding=async: \(tag)")
                }
                guard ImageHTMLRewriter.attributeValue("data-image-optimized", in: tag)?.lowercased() == "true" else {
                    throw invalid(htmlFile, "local image is not marked as optimised: \(tag)")
                }
                guard let loading = ImageHTMLRewriter.attributeValue("loading", in: tag)?.lowercased(),
                      ["eager", "lazy"].contains(loading) else {
                    throw invalid(htmlFile, "local image has invalid loading behavior: \(tag)")
                }
                if ImageHTMLRewriter.attributeValue("fetchpriority", in: tag)?.lowercased() == "high",
                   loading != "eager" {
                    throw invalid(htmlFile, "high-priority image must load eagerly: \(tag)")
                }
                if loading == "lazy",
                   ImageHTMLRewriter.attributeValue("fetchpriority", in: tag)?.lowercased() != "low" {
                    throw invalid(htmlFile, "lazy image must use low fetch priority: \(tag)")
                }

                let originalFile = buildFileURL(for: canonicalSource, buildDirectory: buildDirectory)
                guard FileManager.default.fileExists(atPath: originalFile.path) else {
                    throw ImageOptimizationError.missingGeneratedAsset(canonicalSource)
                }

                let containers = responsivePictures.filter { picture in
                    picture.range.location <= match.range.location
                        && NSMaxRange(picture.range) >= NSMaxRange(match.range)
                }
                guard containers.count == 1,
                      let pictureRange = Range(containers[0].range, in: html) else {
                    throw invalid(htmlFile, "local image must belong to exactly one responsive picture: \(tag)")
                }

                let pictureMarkup = String(html[pictureRange])
                guard let openingEnd = pictureMarkup.firstIndex(of: ">") else {
                    throw invalid(htmlFile, "responsive picture has no opening tag")
                }
                let openingTag = String(pictureMarkup[...openingEnd])
                guard let dataSource = ImageHTMLRewriter.attributeValue("data-image-source", in: openingTag),
                      ImageHTMLRewriter.canonicalImagePath(dataSource) == canonicalSource else {
                    throw invalid(htmlFile, "responsive picture source does not match its fallback: \(tag)")
                }

                let pictureNSRange = NSRange(pictureMarkup.startIndex..<pictureMarkup.endIndex, in: pictureMarkup)
                let nestedLocalImages = ImageHTMLRewriter.imagePattern
                    .matches(in: pictureMarkup, range: pictureNSRange)
                    .filter { nestedMatch in
                        guard let nestedRange = Range(nestedMatch.range, in: pictureMarkup),
                              let nestedSource = ImageHTMLRewriter.attributeValue(
                                "src",
                                in: String(pictureMarkup[nestedRange])
                              ) else { return false }
                        return ImageHTMLRewriter.canonicalImagePath(nestedSource).hasPrefix("/Images/")
                    }
                guard nestedLocalImages.count == 1 else {
                    throw invalid(htmlFile, "responsive picture must contain exactly one local fallback image")
                }

                let webPSources = sourcePattern.matches(in: pictureMarkup, range: pictureNSRange).compactMap { sourceMatch -> String? in
                    guard let sourceRange = Range(sourceMatch.range, in: pictureMarkup) else { return nil }
                    let sourceTag = String(pictureMarkup[sourceRange])
                    return ImageHTMLRewriter.attributeValue("type", in: sourceTag)?.lowercased() == "image/webp"
                        ? sourceTag
                        : nil
                }
                guard webPSources.count == 1,
                      let sourceSet = ImageHTMLRewriter.attributeValue("srcset", in: webPSources[0]),
                      !sourceSet.isEmpty,
                      let sizes = ImageHTMLRewriter.attributeValue("sizes", in: webPSources[0]),
                      !sizes.isEmpty else {
                    throw invalid(htmlFile, "responsive picture must contain one WebP source with srcset and sizes")
                }
                try validateSourceSet(sourceSet, htmlFile: htmlFile, buildDirectory: buildDirectory)
            }

            guard responsivePictures.count == localImageMatches.count else {
                throw invalid(
                    htmlFile,
                    "found \(localImageMatches.count) local images but \(responsivePictures.count) responsive pictures"
                )
            }

            try validateIconLinks(in: html, htmlFile: htmlFile, buildDirectory: buildDirectory)

            if html.contains("https://swiftforswifts.org/downloads/swift-for-swifts-icon.png") {
                throw invalid(htmlFile, "footer image still points at the third-party asset")
            }
        }
    }

    private static func validateSourceSet(
        _ sourceSet: String,
        htmlFile: URL,
        buildDirectory: URL
    ) throws {
        var widths = Set<Int>()
        for entry in sourceSet.split(separator: ",") {
            let components = entry.split(whereSeparator: { $0.isWhitespace })
            guard components.count == 2,
                  components[1].hasSuffix("w"),
                  let width = Int(components[1].dropLast()),
                  width > 0,
                  widths.insert(width).inserted else {
                throw invalid(htmlFile, "invalid WebP srcset entry: \(entry)")
            }
            let path = String(components[0])
            guard path.hasPrefix("/Images/Optimized/"), path.lowercased().hasSuffix(".webp") else {
                throw invalid(htmlFile, "unexpected WebP source path: \(path)")
            }
            let file = buildFileURL(for: path, buildDirectory: buildDirectory)
            guard FileManager.default.fileExists(atPath: file.path) else {
                throw ImageOptimizationError.missingGeneratedAsset(path)
            }
        }
        guard !widths.isEmpty else {
            throw invalid(htmlFile, "WebP srcset is empty")
        }
    }

    private static func validateIconLinks(
        in html: String,
        htmlFile: URL,
        buildDirectory: URL
    ) throws {
        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        let links = linkPattern.matches(in: html, range: range).compactMap { match -> String? in
            guard let linkRange = Range(match.range, in: html) else { return nil }
            return String(html[linkRange])
        }

        let requiredIcons = [
            (relation: "icon", path: ImageOptimizationPublisher.faviconOutputPath, sizes: "32x32"),
            (relation: "icon", path: ImageOptimizationPublisher.searchFaviconOutputPath, sizes: "96x96"),
            (relation: "apple-touch-icon", path: ImageOptimizationPublisher.appleTouchIconOutputPath, sizes: "180x180"),
        ]
        for required in requiredIcons {
            let matches = links.filter { tag in
                let relations = ImageHTMLRewriter.attributeTokens("rel", in: tag).map { $0.lowercased() }
                return relations.contains(required.relation)
                    && ImageHTMLRewriter.attributeValue("href", in: tag) == required.path
                    && ImageHTMLRewriter.attributeValue("sizes", in: tag)?.lowercased() == required.sizes
                    && ImageHTMLRewriter.attributeValue("type", in: tag)?.lowercased() == "image/png"
            }
            guard matches.count == 1 else {
                throw invalid(htmlFile, "expected exactly one \(required.sizes) \(required.relation) link")
            }
            let file = buildFileURL(for: required.path, buildDirectory: buildDirectory)
            guard FileManager.default.fileExists(atPath: file.path) else {
                throw ImageOptimizationError.missingGeneratedAsset(required.path)
            }
        }
    }

    private static func buildFileURL(for webPath: String, buildDirectory: URL) -> URL {
        let decodedPath = webPath.removingPercentEncoding ?? webPath
        return buildDirectory.appendingPathComponent(String(decodedPath.drop(while: { $0 == "/" })))
    }

    private static func invalid(_ htmlFile: URL, _ problem: String) -> ImageOptimizationError {
        .invalidGeneratedHTML(path: htmlFile.path, problem: problem)
    }
}

enum RepresentativeImageTransferValidator {
    static let minimumReduction = 0.70
    static let viewportWidth = 390
    static let devicePixelRatio = 2.0
    static let representativePaths = [
        "index.html",
        "blog/index.html",
        "365-days-ios-accessibility/index.html",
        "365-days-ios-accessibility/day-233/index.html",
        "post/2024-12-06-01/index.html",
        "about/index.html",
        "apps/xarra/index.html",
        "apps/retrorapid/index.html",
    ]

    private static let picturePattern = try! NSRegularExpression(
        pattern: #"<picture\b[^>]*class\s*=\s*(?:\"[^\"]*responsive-picture[^\"]*\"|'[^']*responsive-picture[^']*')[^>]*>[\s\S]*?</picture>"#,
        options: [.caseInsensitive]
    )
    private static let sourcePattern = try! NSRegularExpression(
        pattern: #"<source\b[^>]*>"#,
        options: [.caseInsensitive]
    )

    static func validate(buildDirectory: URL) throws -> Double {
        var originalBytes: Int64 = 0
        var optimizedBytes: Int64 = 0

        for relativePath in representativePaths {
            let htmlFile = buildDirectory.appendingPathComponent(relativePath)
            guard FileManager.default.fileExists(atPath: htmlFile.path) else {
                throw ImageOptimizationError.invalidGeneratedHTML(
                    path: htmlFile.path,
                    problem: "representative transfer page is missing"
                )
            }
            let html = try String(contentsOf: htmlFile, encoding: .utf8)
            let htmlRange = NSRange(html.startIndex..<html.endIndex, in: html)
            let pictures = picturePattern.matches(in: html, range: htmlRange)
            var pageOriginals = Set<String>()
            var pageOptimized = Set<String>()

            for pictureMatch in pictures {
                guard let htmlPictureRange = Range(pictureMatch.range, in: html) else { continue }
                let picture = String(html[htmlPictureRange])
                let pictureNSRange = NSRange(picture.startIndex..<picture.endIndex, in: picture)
                guard let imageMatch = ImageHTMLRewriter.imagePattern.firstMatch(in: picture, range: pictureNSRange),
                      let imageRange = Range(imageMatch.range, in: picture),
                      let originalPath = ImageHTMLRewriter.attributeValue("src", in: String(picture[imageRange])) else {
                    continue
                }

                let webPSource = sourcePattern.matches(in: picture, range: pictureNSRange).compactMap { match -> String? in
                    guard let range = Range(match.range, in: picture) else { return nil }
                    let tag = String(picture[range])
                    return ImageHTMLRewriter.attributeValue("type", in: tag)?.lowercased() == "image/webp" ? tag : nil
                }.first
                guard let webPSource,
                      let sourceSet = ImageHTMLRewriter.attributeValue("srcset", in: webPSource),
                      let sizes = ImageHTMLRewriter.attributeValue("sizes", in: webPSource),
                      let selectedPath = selectedCandidatePath(sourceSet: sourceSet, sizes: sizes) else {
                    throw ImageOptimizationError.invalidGeneratedHTML(
                        path: htmlFile.path,
                        problem: "could not estimate responsive transfer for \(originalPath)"
                    )
                }
                pageOriginals.insert(ImageHTMLRewriter.canonicalImagePath(originalPath))
                pageOptimized.insert(selectedPath)
            }

            for path in pageOriginals {
                originalBytes += try fileSize(for: path, buildDirectory: buildDirectory)
            }
            for path in pageOptimized {
                optimizedBytes += try fileSize(for: path, buildDirectory: buildDirectory)
            }
        }

        guard originalBytes > 0 else {
            throw ImageOptimizationError.commandFailed(
                command: "validate representative image transfer",
                output: "No original image bytes were measured"
            )
        }
        let reduction = 1 - (Double(optimizedBytes) / Double(originalBytes))
        guard reduction >= minimumReduction else {
            throw ImageOptimizationError.commandFailed(
                command: "validate representative image transfer",
                output: String(
                    format: "Estimated 390px @2x reduction is %.1f%%; minimum is %.1f%%",
                    reduction * 100,
                    minimumReduction * 100
                )
            )
        }
        return reduction
    }

    static func selectedCandidatePath(sourceSet: String, sizes: String) -> String? {
        let candidates = sourceSet.split(separator: ",").compactMap { entry -> (path: String, width: Int)? in
            let components = entry.split(whereSeparator: { $0.isWhitespace })
            guard components.count == 2,
                  components[1].hasSuffix("w"),
                  let width = Int(components[1].dropLast()) else { return nil }
            return (String(components[0]), width)
        }.sorted { $0.width < $1.width }
        guard !candidates.isEmpty,
              let cssWidth = renderedCSSWidth(sizes: sizes) else { return nil }
        let requiredWidth = Int(ceil(cssWidth * devicePixelRatio))
        return candidates.first(where: { $0.width >= requiredWidth })?.path ?? candidates.last?.path
    }

    static func renderedCSSWidth(sizes: String) -> Double? {
        let clauses = sizes.split(separator: ",").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        for clause in clauses {
            if clause.hasPrefix("(min-width:"),
               let closingParenthesis = clause.firstIndex(of: ")") {
                let condition = clause[..<closingParenthesis]
                let digits = condition.filter(\.isNumber)
                guard let minimumWidth = Int(digits) else { continue }
                if viewportWidth >= minimumWidth {
                    let length = clause[clause.index(after: closingParenthesis)...]
                        .trimmingCharacters(in: .whitespaces)
                    return cssPixels(length)
                }
            } else {
                return cssPixels(clause)
            }
        }
        return nil
    }

    private static func cssPixels(_ value: String) -> Double? {
        if value.hasSuffix("px"), let pixels = Double(value.dropLast(2)) {
            return pixels
        }
        if value.hasSuffix("vw"), let percentage = Double(value.dropLast(2)) {
            return Double(viewportWidth) * percentage / 100
        }
        let calcPattern = try! NSRegularExpression(pattern: #"^calc\(100vw\s*-\s*([0-9]+)px\)$"#)
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        guard let match = calcPattern.firstMatch(in: value, range: range),
              let subtractionRange = Range(match.range(at: 1), in: value),
              let subtraction = Double(value[subtractionRange]) else { return nil }
        return Double(viewportWidth) - subtraction
    }

    private static func fileSize(for webPath: String, buildDirectory: URL) throws -> Int64 {
        let decodedPath = webPath.removingPercentEncoding ?? webPath
        let file = buildDirectory.appendingPathComponent(String(decodedPath.drop(while: { $0 == "/" })))
        let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
        guard let size = (attributes[.size] as? NSNumber)?.int64Value else {
            throw ImageOptimizationError.missingGeneratedAsset(webPath)
        }
        return size
    }
}

enum ImageOptimizationPublisher {
    static let faviconSourcePath = "/Images/Site/Global/a11yupto11favicon.png"
    static let faviconOutputPath = "/Images/Optimized/Site/Global/a11yupto11favicon-32.png"
    static let searchFaviconOutputPath = "/Images/Optimized/Site/Global/a11yupto11favicon-96.png"
    static let appleTouchIconOutputPath = "/Images/Optimized/Site/Global/a11yupto11favicon-180.png"
    static let maximumFaviconBytes: [Int: Int64] = [32: 5_120, 96: 25_600, 180: 51_200]

    static func preflight(
        projectDirectory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) throws {
        guard environment["SKIP_IMAGE_OPTIMIZATION"] != "1" else { return }
        _ = try ImageOptimizationToolchain.locate(environment: environment)
        let configurationURL = projectDirectory.appendingPathComponent("ImageOptimizationConfig.json")
        _ = try ImageOptimizationConfiguration.load(from: configurationURL)
    }

    /// Ignite clears the build directory before publishing, but its cleanup is best-effort.
    /// Remove the complete generated tree explicitly so a previous optimised build cannot
    /// leave stale assets behind or make Ignite's subsequent asset copy fail.
    static func prepareForPublishing(
        projectDirectory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    ) throws {
        let buildDirectory = projectDirectory.appendingPathComponent("Build", isDirectory: true)
        let normalizedProject = projectDirectory.standardizedFileURL.path + "/"
        let normalizedBuild = buildDirectory.standardizedFileURL.path
        guard normalizedBuild.hasPrefix(normalizedProject), normalizedBuild.hasSuffix("/Build") else {
            throw ImageOptimizationError.commandFailed(
                command: "prepare site publishing",
                output: "Refusing to remove unexpected directory: \(normalizedBuild)"
            )
        }

        if FileManager.default.fileExists(atPath: buildDirectory.path) {
            try FileManager.default.removeItem(at: buildDirectory)
        }
    }

    static func publish(
        projectDirectory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) throws {
        if environment["SKIP_IMAGE_OPTIMIZATION"] == "1" {
            BuildLogger.warning(.imageOptimization, "skipping because SKIP_IMAGE_OPTIMIZATION=1")
            return
        }

        BuildLogger.step(.imageOptimization, "locating image tools")
        let tools = try ImageOptimizationToolchain.locate(environment: environment)
        let buildDirectory = projectDirectory.appendingPathComponent("Build", isDirectory: true)
        let configurationURL = projectDirectory.appendingPathComponent("ImageOptimizationConfig.json")
        let configuration = try ImageOptimizationConfiguration.load(from: configurationURL)
        let htmlFiles = try generatedHTMLFiles(in: buildDirectory)

        BuildLogger.step(.imageOptimization, "discovering local images in \(htmlFiles.count) generated pages")
        let sourcePaths = try discoverSourcePaths(in: htmlFiles)
        let outputDirectory = buildDirectory.appendingPathComponent("Images/Optimized", isDirectory: true)
        try recreateOutputDirectory(outputDirectory, inside: buildDirectory)

        let requestedWorkerCount = environment["IMAGE_OPTIMIZATION_WORKERS"].flatMap(Int.init)
        let workerCount = max(
            1,
            min(
                requestedWorkerCount ?? min(ProcessInfo.processInfo.activeProcessorCount, 6),
                max(sourcePaths.count, 1)
            )
        )
        let queue = OperationQueue()
        queue.name = "com.accessibilityupto11.image-optimization"
        queue.maxConcurrentOperationCount = workerCount
        let accumulator = ImageOptimizationAccumulator()

        BuildLogger.step(
            .imageOptimization,
            "generating responsive WebP variants for \(sourcePaths.count) images using \(workerCount) workers"
        )
        for sourcePath in sourcePaths {
            queue.addOperation {
                guard !accumulator.hasFailed else { return }

                do {
                    let sourceURL = buildFileURL(for: sourcePath, buildDirectory: buildDirectory)
                    guard FileManager.default.fileExists(atPath: sourceURL.path) else {
                        throw ImageOptimizationError.missingSource(sourcePath)
                    }

                    let metadata = try metadata(for: sourceURL, using: tools)
                    let profile = ImageOptimizationPolicy.profile(
                        for: sourcePath,
                        metadata: metadata,
                        configuration: configuration
                    )
                    let widths = ImageOptimizationPolicy.targetWidths(
                        for: sourcePath,
                        sourceWidth: metadata.pixelWidth
                    )
                    let derivatives = try widths.map { width in
                        try generateDerivative(
                            sourceURL: sourceURL,
                            sourcePath: sourcePath,
                            width: width,
                            profile: profile,
                            buildDirectory: buildDirectory,
                            tools: tools
                        )
                    }
                    var derivativeBytes: Int64 = 0
                    for derivative in derivatives {
                        derivativeBytes += try fileSize(derivative.fileURL)
                    }
                    let completedCount = accumulator.append(
                        ImageOptimizationWorkResult(
                            asset: OptimizedImageAsset(
                                sourcePath: sourcePath,
                                metadata: metadata,
                                profile: profile,
                                derivatives: derivatives
                            ),
                            originalBytes: try fileSize(sourceURL),
                            derivativeBytes: derivativeBytes
                        )
                    )

                    if completedCount.isMultiple(of: 50) || completedCount == sourcePaths.count {
                        BuildLogger.detail("Optimised \(completedCount)/\(sourcePaths.count) source images")
                    }
                } catch {
                    accumulator.record(error: error)
                }
            }
        }
        queue.waitUntilAllOperationsAreFinished()

        if let error = accumulator.firstError {
            throw error
        }

        let workResults = accumulator.results
        var assets: [String: OptimizedImageAsset] = [:]
        var originalBytes: Int64 = 0
        var derivativeBytes: Int64 = 0
        var derivativeCount = 0
        var profileCounts: [ImageEncodingProfile: Int] = [:]

        for result in workResults {
            assets[result.asset.sourcePath] = result.asset
            profileCounts[result.asset.profile, default: 0] += 1
            originalBytes += result.originalBytes
            derivativeBytes += result.derivativeBytes
            derivativeCount += result.asset.derivatives.count
        }

        try generateFavicons(buildDirectory: buildDirectory, tools: tools)
        BuildLogger.step(.imageOptimization, "rewriting responsive image markup")
        let rewriter = ImageHTMLRewriter(
            assets: assets,
            faviconPath: faviconOutputPath,
            searchFaviconPath: searchFaviconOutputPath,
            appleTouchIconPath: appleTouchIconOutputPath
        )
        for htmlFile in htmlFiles {
            let html = try String(contentsOf: htmlFile, encoding: .utf8)
            let rewritten = try rewriter.rewrite(html)
            try rewritten.write(to: htmlFile, atomically: true, encoding: .utf8)
        }

        BuildLogger.step(.imageOptimization, "validating generated image markup and files")
        try GeneratedImageValidator.validate(htmlFiles: htmlFiles, buildDirectory: buildDirectory)
        let representativeReduction = try RepresentativeImageTransferValidator.validate(
            buildDirectory: buildDirectory
        )

        let originalMiB = Double(originalBytes) / 1_048_576
        let derivativeMiB = Double(derivativeBytes) / 1_048_576
        let profileSummary = ImageEncodingProfile.allCases
            .map { "\($0.rawValue): \(profileCounts[$0, default: 0])" }
            .joined(separator: ", ")
        BuildLogger.detail(String(format: "Unique source bytes: %.2f MiB", originalMiB))
        BuildLogger.detail(String(format: "Generated bytes: %.2f MiB across %d variants", derivativeMiB, derivativeCount))
        BuildLogger.detail(
            String(format: "Representative 390px @2x transfer reduction: %.1f%%", representativeReduction * 100)
        )
        BuildLogger.detail("Profiles: \(profileSummary)")
        BuildLogger.success(.imageOptimization, "responsive images generated and validated")
    }

    static func metadata(for file: URL, using tools: ImageOptimizationToolchain) throws -> ImageMetadata {
        let output = try run(
            executable: tools.identify,
            arguments: ["-format", "%w|%h|%m|%[channels]", file.path]
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        let components = output.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
        guard components.count == 4,
              let width = Int(components[0]),
              let height = Int(components[1]),
              width > 0,
              height > 0 else {
            throw ImageOptimizationError.invalidMetadata(path: file.path, output: output)
        }
        return ImageMetadata(pixelWidth: width, pixelHeight: height, format: components[2], channels: components[3])
    }

    static func derivativeWebPath(for sourcePath: String, width: Int) -> String {
        let relative = sourcePath.replacingOccurrences(of: "/Images/", with: "", options: [.anchored])
        let rawPath = "/Images/Optimized/\(relative)-w\(width).webp"
        return rawPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? rawPath
    }

    private static func discoverSourcePaths(in htmlFiles: [URL]) throws -> [String] {
        var paths = Set<String>()
        for htmlFile in htmlFiles {
            let html = try String(contentsOf: htmlFile, encoding: .utf8)
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            for match in ImageHTMLRewriter.imagePattern.matches(in: html, range: range) {
                guard let tagRange = Range(match.range, in: html) else { continue }
                let tag = String(html[tagRange])
                guard let source = ImageHTMLRewriter.attributeValue("src", in: tag),
                      ImageHTMLRewriter.isLocalImagePath(source) else { continue }
                paths.insert(ImageHTMLRewriter.canonicalImagePath(source))
            }
        }
        return paths.sorted()
    }

    private static func generatedHTMLFiles(in buildDirectory: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: buildDirectory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return enumerator.compactMap { value -> URL? in
            guard let url = value as? URL, url.pathExtension.lowercased() == "html" else { return nil }
            return url
        }.sorted { $0.path < $1.path }
    }

    private static func recreateOutputDirectory(_ outputDirectory: URL, inside buildDirectory: URL) throws {
        let normalizedOutput = outputDirectory.standardizedFileURL.path
        let normalizedBuild = buildDirectory.standardizedFileURL.path + "/"
        guard normalizedOutput.hasPrefix(normalizedBuild), normalizedOutput.hasSuffix("/Images/Optimized") else {
            throw ImageOptimizationError.commandFailed(
                command: "prepare output directory",
                output: "Refusing to remove unexpected directory: \(normalizedOutput)"
            )
        }

        if FileManager.default.fileExists(atPath: outputDirectory.path) {
            try FileManager.default.removeItem(at: outputDirectory)
        }
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
    }

    private static func generateDerivative(
        sourceURL: URL,
        sourcePath: String,
        width: Int,
        profile: ImageEncodingProfile,
        buildDirectory: URL,
        tools: ImageOptimizationToolchain
    ) throws -> ImageDerivative {
        let webPath = derivativeWebPath(for: sourcePath, width: width)
        let decodedPath = webPath.removingPercentEncoding ?? webPath
        let outputURL = buildFileURL(for: decodedPath, buildDirectory: buildDirectory)
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        var arguments = ["-quiet"]
        arguments += ImageOptimizationPolicy.cwebpArguments(for: profile)
        arguments += [
            "-resize", String(width), "0",
            sourceURL.path,
            "-o", outputURL.path
        ]
        _ = try run(executable: tools.cwebp, arguments: arguments)
        return ImageDerivative(pixelWidth: width, webPath: webPath, fileURL: outputURL)
    }

    private static func generateFavicons(
        buildDirectory: URL,
        tools: ImageOptimizationToolchain
    ) throws {
        let source = buildFileURL(for: faviconSourcePath, buildDirectory: buildDirectory)
        guard FileManager.default.fileExists(atPath: source.path) else {
            throw ImageOptimizationError.missingSource(faviconSourcePath)
        }

        for (size, path) in [
            (32, faviconOutputPath),
            (96, searchFaviconOutputPath),
            (180, appleTouchIconOutputPath),
        ] {
            let output = buildFileURL(for: path, buildDirectory: buildDirectory)
            try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
            _ = try run(
                executable: tools.convert,
                arguments: [
                    source.path,
                    "-resize", "\(size)x\(size)",
                    "-strip",
                    "-define", "png:compression-level=9",
                    output.path
                ]
            )
            let bytes = try fileSize(output)
            if let maximumBytes = maximumFaviconBytes[size], bytes > maximumBytes {
                throw ImageOptimizationError.invalidGeneratedHTML(
                    path: output.path,
                    problem: "\(size)x\(size) favicon is \(bytes) bytes; maximum is \(maximumBytes) bytes"
                )
            }
        }
    }

    private static func buildFileURL(for webPath: String, buildDirectory: URL) -> URL {
        buildDirectory.appendingPathComponent(String(webPath.drop(while: { $0 == "/" })))
    }

    private static func fileSize(_ url: URL) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let size = (attributes[.size] as? NSNumber)?.int64Value else {
            throw ImageOptimizationError.commandFailed(
                command: "measure generated image",
                output: "Could not read the file size for \(url.path)"
            )
        }
        return size
    }

    @discardableResult
    private static func run(executable: URL, arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        let output = Pipe()
        process.standardOutput = output
        process.standardError = output

        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        let message = String(decoding: data, as: UTF8.self)

        guard process.terminationStatus == 0 else {
            let command = ([executable.path] + arguments).joined(separator: " ")
            throw ImageOptimizationError.commandFailed(command: command, output: message)
        }
        return message
    }
}
